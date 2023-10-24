//////////////////////////////////////////////////////////////////////////
// Course		: Microprocessor & HDL
// Major		: EEE
// Grade		: Senior
// ID			: B535007
// Name			: Hyunbin Kang
// Module name	: tb_simple_cpu
//////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps 

module tb_simple_cpu;

	reg clk;
	reg reset;
	reg tb_wait;

	wire read_write_bar;
	wire request;  // To generate wait signal, set reg type

	wire zero_to_pc; 
	wire pc_plus_one;
	wire pc_to_abus; 
	wire ir_to_abus; 
	wire abus_to_mar;
	wire abus_to_pc; 
	wire mar_to_memory_address_bus; 
	wire memory_data_bus_to_mbr; 
	wire mbr_to_memory_data_bus;
	wire mbr_to_mbus; 
	wire mbus_to_ir; 
	wire mbus_to_alub;
	wire rbus_to_ac; 
	wire rbus_to_mbr; 
	wire alu_add; 
	wire alu_pass_b;

	always
		#5 clk = ~clk;

	initial begin
	$display("Initialize values [%d]", $time);
		clk = 0;
		reset = 0;
		tb_wait = 1;

	#4
	$display("Reset [%d]", $time);
		reset = 1;

	#5
		reset = 0;
	// fetch sequence
	// handshaking
	wait(request);
	#4
		tb_wait = 0;
	#15 // memory is operating ...
	wait(!request);
	#3
		tb_wait = 1;
	
	//load sequence
	wait(request);
	#4
		tb_wait = 0;
	#15
	wait(!request);
	#3
		tb_wait = 1;

	//add sequence
	wait(request);
	#4
		tb_wait = 0;
	#15
	wait(!request);
	#3
		tb_wait = 1;

	wait(request);
	#4
		tb_wait = 0;
	#15
	wait(!request);
	#3
		tb_wait = 1;

	#100
	$finish;
	end 
	
	make_control DUT
	(
		.clk						(clk						),	
		.reset						(reset						),
		.i_wait						(tb_wait					),

		.read_write_bar				(read_write_bar				),
		.request					(request					),
		.zero_to_pc					(zero_to_pc					),
		.pc_plus_one				(pc_plus_one				),
		.pc_to_abus					(pc_to_abus					),
		.ir_to_abus					(ir_to_abus					),
		.abus_to_mar				(abus_to_mar				),
		.abus_to_pc                 (abus_to_pc					),
		.mar_to_memory_address_bus	(mar_to_memory_address_bus	),
		.memory_data_bus_to_mbr		(memory_data_bus_to_mbr		),
		.mbr_to_memory_data_bus		(mbr_to_memory_data_bus		),
		.mbr_to_mbus				(mbr_to_mbus				),
		.mbus_to_ir					(mbus_to_ir					),
		.mbus_to_alub				(mbus_to_alub				),
		.rbus_to_ac					(rbus_to_ac					),
		.rbus_to_mbr				(rbus_to_mbr				),
		.alu_add					(alu_add					),
		.alu_pass_b					(alu_pass_b					)
	);

endmodule
