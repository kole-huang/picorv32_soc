// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module altera_sync_ram_1p (
	clk_i,
	adr_i,
	be_i,
	wren_i,
	dat_i,
	dat_o
);

	parameter AW = 10;
	parameter DW = 32;
	parameter INIT_MEM_FILE = "";
	localparam DEPTH = (1 << AW);

	input			clk_i;
	input	[AW-1:0]	adr_i;
	input	[(DW/8)-1:0]	be_i;
	input			wren_i;
	input	[DW-1:0]	dat_i;
	output	[DW-1:0]	dat_o;

	// data q is not register output
	// if data q is register output,
	// data is ready after 2T
	altsyncram altsyncram_component (
		.aclr0 (1'b0),
		.aclr1 (1'b0),
		.clock0 (clk_i),
		.clock1 (1'b1),
		.clocken0 (1'b1),
		.clocken1 (1'b1),
		.clocken2 (1'b1),
		.clocken3 (1'b1),
		.address_a (adr_i),
		.address_b (1'b1),
		.addressstall_a (1'b0),
		.addressstall_b (1'b0),
		.byteena_a (be_i),
		.byteena_b (1'b1),
		.data_a (dat_i),
		.data_b (1'b1),
		.q_a (dat_o),
		.q_b (),
		.rden_a (1'b1),
		.rden_b (1'b1),
		.wren_a (wren_i),
		.wren_b (1'b0),
		.eccstatus ());
	defparam
		altsyncram_component.byte_size = 8,
		altsyncram_component.clock_enable_input_a = "BYPASS",
		altsyncram_component.clock_enable_output_a = "BYPASS",
		altsyncram_component.init_file = INIT_MEM_FILE,
		altsyncram_component.intended_device_family = "Cyclone V",
		altsyncram_component.lpm_hint = "ENABLE_RUNTIME_MOD=YES,INSTANCE_NAME=SRAM0",
		altsyncram_component.lpm_type = "altsyncram",
		altsyncram_component.numwords_a = DEPTH,
		altsyncram_component.operation_mode = "SINGLE_PORT",
		altsyncram_component.outdata_aclr_a = "NONE",
		altsyncram_component.outdata_reg_a = "UNREGISTERED",
		altsyncram_component.power_up_uninitialized = "FALSE",
		altsyncram_component.read_during_write_mode_port_a = "NEW_DATA_NO_NBE_READ",
		altsyncram_component.widthad_a = (AW),
		altsyncram_component.width_a = (DW),
		altsyncram_component.width_byteena_a = (DW/8);

endmodule
