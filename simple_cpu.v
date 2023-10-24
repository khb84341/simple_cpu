//////////////////////////////////////////////////////////////////////////
// Course		: Microprocessor & HDL
// Major		: EEE
// Grade		: Senior
// ID			: B535007
// Name			: Hyunbin Kang
// Module name	: Make_control
//////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module make_control #(parameter WIDTH = 16)// Instruction and data width
(
	input clk,			
	input reset,
	input i_wait,

	//control signal
	output reg read_write_bar,
	output reg request,  // To generate wait signal, set reg type

	output reg zero_to_pc, 
	output reg pc_plus_one,
	output reg pc_to_abus, 
	output reg abus_to_mar,
	output reg ir_to_abus, 
	output reg abus_to_pc, 
	output reg mar_to_memory_address_bus, 
	output reg memory_data_bus_to_mbr, 
	output reg mbr_to_memory_data_bus,
	output reg mbr_to_mbus, 
	output reg mbus_to_ir, 
	output reg mbus_to_alub,
	output reg rbus_to_ac, 
	output reg rbus_to_mbr, 
	output reg alu_add, 
	output reg alu_pass_b 
); 

	// local parameter to represent state value of state registers 
	localparam RES = 4'b0000;
	localparam IF0 = 4'b0001;
	localparam IF1 = 4'b0010;
	localparam IF2 = 4'b0011; 

	localparam OD  = 4'b0100;

	localparam LD0 = 4'b0101;
	localparam LD1 = 4'b0110;
	localparam LD2 = 4'b0111;

	localparam AD0 = 4'b1000;
	localparam AD1 = 4'b1001;
	localparam AD2 = 4'b1010;

	// registers in cpu
	reg [WIDTH-3	:0] pc					; // program counter / 14bits (except opcode part)
	reg [WIDTH-3	:0] mar					; // memory address register / same
	reg [WIDTH-1	:0] mbr					; // instruction buffer register
	reg [WIDTH-1	:0] ir					; // instruction register
	reg [WIDTH-1	:0] ac					; // accumulator 

	// buses in cpu
	reg [WIDTH-3	:0]	abus				;
	reg [WIDTH-1	:0]	rbus				;
	reg [WIDTH-1	:0]	mbus				;
	reg [WIDTH-1	:0]	mem_add_bus			;
	reg [WIDTH-1	:0]	mem_dat_bus			; 
	reg [WIDTH-1	:0]	alu_b				; // second source of ALU

	// Current state registers of fsm
	reg [3:0] c_state;
	
	// Next state registers of fsm
	reg [3:0] n_state; 

	// Step 1. Update state by clock and lower control signal
	always @(posedge clk) begin
		c_state <= n_state;

		read_write_bar <= #2 0;
		zero_to_pc <=  #2 0;
		pc_plus_one <= #2 0; 
		pc_to_abus <=  #2 0;
		ir_to_abus <=  #2 0;
		abus_to_mar <= #2 0;
		abus_to_pc <=  #2 0;
		mar_to_memory_address_bus <= #2 0;
		memory_data_bus_to_mbr <= #2 0;
		mbr_to_memory_data_bus <= #2 0;
		mbr_to_mbus <= #2 0;
		mbus_to_ir <= #2 0;
		mbus_to_alub <= #2 0;
		rbus_to_ac  <= #2 0;
		rbus_to_mbr <= #2 0;
		alu_add <= #2 0;
		alu_pass_b <= #2 0; 
	end

	// Handshaking
	always @(negedge i_wait) begin
		request <= #2 0;
	end

	// Step 2. make control signal
	always @(posedge reset) begin
		n_state <= RES ;
		zero_to_pc	<= 1; 
	end

	always @(*) begin
		case (c_state)
		RES:
			if (!reset) begin
				n_state	<= IF0; 
				pc_plus_one <= 1;
				pc_to_abus <= 1;
				abus_to_mar <= 1; 
			end

		IF0:
			if (i_wait) begin
				n_state	<= IF1;
				read_write_bar <= #2 1;
				mar_to_memory_address_bus <= #2 1;
				request <= #2 1;
			end

		IF1:
			if (!i_wait) begin
				n_state	<= IF2; 
				memory_data_bus_to_mbr <= #2 1;
			end else begin
				 n_state	<= IF1;
				read_write_bar <= #2 1;
				mar_to_memory_address_bus <= #2 1;
				request <= #2 1;
			end

		IF2:
			if (i_wait) begin
				n_state <= OD;
				mbr_to_mbus <= #2 1;
				mbus_to_ir <= #2 1;
			end 

		OD :
			if (ir[15:14] == 2'b00) begin	
				n_state <= LD0;
				ir_to_abus <= #2 1; 
				abus_to_mar <= #2 1;
			end else if (ir[15:14] == 2'b10) begin 
				n_state <= AD0;
				ir_to_abus <= #2 1; 
				abus_to_mar <= #2 1; 
			end else begin
				n_state <= OD;
			end

		LD0:
			if (i_wait) begin
				n_state <= LD1;
				read_write_bar <= #2 1;			
				mar_to_memory_address_bus <= #2 1;
				request <= #2 1;
			end 

		LD1:
			if (!i_wait) begin
				n_state <= LD2; 
				memory_data_bus_to_mbr <= #2 1;
			end else begin
				n_state <= OD;
				read_write_bar <= #2 1;			
				mar_to_memory_address_bus <= #2 1;
				request <= #2 1;
			end

		LD2:
			if (i_wait) begin
				n_state <= RES;
				mbr_to_mbus <= #2 1;
				alu_pass_b <= #2 1;			
				mbus_to_alub <= #2 1;
				rbus_to_ac <= #2 1;			
			end

		AD0:
			if (i_wait) begin
				n_state <= AD1;
				read_write_bar <= #2 1;
				mar_to_memory_address_bus <= #2 1;
				request <= #2 1;
			end 

		AD1:
			if (!i_wait) begin
				n_state <= AD2;
				memory_data_bus_to_mbr <= #2 1;
				rbus_to_ac <= #2 1;
			end else begin
				n_state <= AD1;
				read_write_bar <= #2 1;
				mar_to_memory_address_bus <= #2 1;
				request <= #2 1;
			end

		AD2: if (i_wait) begin
				n_state <= RES;
				mbr_to_mbus <= #2 1;
				mbus_to_alub <= #2 1; 
				alu_add <= #2 1;
				rbus_to_ac <= #2 1;
			end

		default:
			n_state = RES; // to prevent latch
		endcase
	end 
	// Step 3. Register tranfers occur at positive edge clock 
	always @(posedge clk) begin
		if (zero_to_pc)
			pc <= 0;
		if (pc_plus_one)
			pc <= pc + 1;
		if (abus_to_mar)
			mar <= abus;
		if (abus_to_pc)
			pc <= abus;

		// 편의상 데이터를 직접 할당해줌으로써 실제 메로리로부터 데이터를 받았다고 가정
		// Instruction memory와 data memory가 하나의 메모리에 있다고 가정
		// mem[0] : Load mem[2] to ac 라는 instruction
		// mem[1] : Add mem[3] and ac 라는 instruction
		// mem[2] : 3 이라는 데이터
		// mem[3] : 5 라는 데이터
		// 메모리에 위와 같이 데이터가 저장되어 있다고  가정
		if (memory_data_bus_to_mbr) begin
			if (mar == 14'd0)	   // memory index = 0
				mbr <= 16'b0000000000000010;  // Load mem[2] to ac <= Instruction
			else if (mar == 14'd1) // memory index = 1
				mbr <= 16'b1000000000000011; // add mem[3] & ac <= Instruction
			else if (mar == 14'd2) // memory index = 2
				mbr <= 16'b0000000000000011; // 16'd3 <= Data
			else if (mar == 14'd3) // memory index = 3
				mbr <= 16'b0000000000000101; // 16'd5 <= Data
		end

		if (mbus_to_ir)
			ir <= mbus;
		if (rbus_to_ac)
			ac <= rbus;
		if (rbus_to_mbr)
			mbr <= rbus;
		if (alu_add) begin
			ac <= rbus; 
		end	
	end 

// Buses change immediately
	always @(*) begin
		if (pc_to_abus)
			abus <= pc;
		if (ir_to_abus)
			abus <= ir[13:0];
		if (mar_to_memory_address_bus)
			mem_add_bus <= mar;
		if (mbr_to_memory_data_bus) 
			mem_dat_bus <= mbr;
		if (mbr_to_mbus)
			mbus <= mbr;
		if (mbus_to_alub)
			alu_b <= mbus; 
		if (alu_add)
			rbus <= alu_b + ac; // alu_a 포트 생략 ac 에서 직접 더한다고 가정
		if (alu_pass_b)
			rbus <= alu_b; 
	end

endmodule
