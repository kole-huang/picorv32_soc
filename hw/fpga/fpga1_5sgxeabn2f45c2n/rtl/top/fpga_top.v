module fpga_top (
//Clocks Inputs
	input				sva_clk_p,		//LVDS
	input				sva_clk_125_p,		//LVDS
	input				sva_clk_50,		//1.8V
	input				clkinbota_ddr3_p,	//LVDS Exteranl Terminate
	input				clkintopa_ddr3_p,	//LVDS Exteranl Terminate
	input				clkintopa_qdr2,		//1.8V CMOS
	input				clkinbota_qdr2_p,	//LVDS
	
	output				clock_scl,		//2.5V Si5338 I2C scl -> Tri-state when notin use.
	inout				clock_sda,		//2.5V Si5338 I2C sda -> Tri-state when notin use.

//OCT Termination
	input				rzq_5,			//1.5V oct.rzqin for DDR3 and QDRII+

//EEPROM
	input				eeprom1_scl,		//2.5V
	inout				eeprom1_sda,		//2.5V

//DDR3
	output	[13:0]			ddr3a_a,		//1.5V
	output	[2:0]			ddr3a_ba,		//1.5V
	output				ddr3a_clk_p,		//1.5V
	output				ddr3a_clk_n,		//1.5V
	output				ddr3a_cke,		//1.5V
	output				ddr3a_csn,		//1.5V
	output	[3:0]			ddr3a_dm,		//1.5V
	output				ddr3a_rasn,		//1.5V
	output				ddr3a_casn,		//1.5V
	output				ddr3a_wen,		//1.5V
	output				ddr3a_resetn,		//1.5V
	inout	[31:0]			ddr3a_dq,		//1.5V
	inout	[3:0]			ddr3a_dqs_p,		//1.5V
	inout	[3:0]			ddr3a_dqs_n,		//1.5V
	output				ddr3a_odt,		//1.5V

	output	[13:0]			ddr3b_a,		//1.5V
	output	[2:0]			ddr3b_ba,		//1.5V
	output				ddr3b_clk_p,		//1.5V
	output				ddr3b_clk_n,		//1.5V
	output				ddr3b_cke,		//1.5V
	output				ddr3b_csn,		//1.5V
	output	[7:0]			ddr3b_dm,		//1.5V
	output				ddr3b_rasn,		//1.5V
	output				ddr3b_casn,		//1.5V
	output				ddr3b_wen,		//1.5V
	output				ddr3b_resetn,		//1.5V
	inout	[63:0]			ddr3b_dq,		//1.5V
	inout	[7:0]			ddr3b_dqs_p,		//1.5V
	inout	[7:0]			ddr3b_dqs_n,		//1.5V
	output				ddr3b_odt,		//1.5V
	
	output	[13:0]			ddr3c_a,		//1.5V
	output	[2:0]			ddr3c_ba,		//1.5V
	output				ddr3c_clk_p,		//1.5V
	output				ddr3c_clk_n,		//1.5V
	output				ddr3c_cke,		//1.5V
	output				ddr3c_csn,		//1.5V
	output	[3:0]			ddr3c_dm,		//1.5V
	output				ddr3c_rasn,		//1.5V
	output				ddr3c_casn,		//1.5V
	output				ddr3c_wen,		//1.5V
	output				ddr3c_resetn,		//1.5V
	inout	[31:0]			ddr3c_dq,		//1.5V
	inout	[3:0]			ddr3c_dqs_p,		//1.5V
	inout	[3:0]			ddr3c_dqs_n,		//1.5V
	output				ddr3c_odt,		//1.5V
	
	output	[13:0]			ddr3d_a,		//1.5V
	output	[2:0]			ddr3d_ba,		//1.5V
	output				ddr3d_clk_p,		//1.5V
	output				ddr3d_clk_n,		//1.5V
	output				ddr3d_cke,		//1.5V
	output				ddr3d_csn,		//1.5V
	output	[7:0]			ddr3d_dm,		//1.5V
	output				ddr3d_rasn,		//1.5V
	output				ddr3d_casn,		//1.5V
	output				ddr3d_wen,		//1.5V
	output				ddr3d_resetn,		//1.5V
	inout	[63:0]			ddr3d_dq,		//1.5V
	inout	[7:0]			ddr3d_dqs_p,		//1.5V
	inout	[7:0]			ddr3d_dqs_n,		//1.5V
	output				ddr3d_odt,		//1.5V

//Chip-to-Chip -----------------------------//xx pins  //--------------------------
	inout	[11:0]			c2c_d,

//User-IO------------------------------//27 pins //--------------------------
	input	[7:0]			fpga1_dipsw,		//1.5V		//User DIP Switches (TR=0)
	output	[7:0]			fpga1_led_g,		//1.5V/2.5V	//User LEDs
	output	[7:0]			fpga1_led_r,		//1.5V		//User LEDs
	input	[2:0]			fpga1_pb,		//HSMB_VAR	//User Pushbuttons (TR=0)
	input				fpga1_cpu_resetn	//2.5V		//CPU Reset Pushbutton (TR=0)
);

parameter RST_N_HOLD_CNT = 50;

wire sys_rst_n;
wire clk_100m, clk_50m, clk_25m, clk_10m, clk_5m, clk_1m;
wire soc_rst; // low active
wire soc_clk;

// BUTTON[0] && BUTTON[1] go to low when pushed, go to high when released
// after done, CPU_RST will be from 0 -> 1
pll_rst_sync #(
	.RST_N_HOLD_CNT(RST_N_HOLD_CNT)
) pll_rst_sync_u0 (
	.clk_i(sva_clk_50),
	.rst_n_i(fpga1_cpu_resetn),
	.sys_rst_n_o(sys_rst_n),
	.clk_c0(clk_100m),
	.clk_c1(clk_50m),
	.clk_c2(clk_25m),
	.clk_c3(clk_10m),
	.clk_c4(clk_5m),
	.clk_c5(clk_1m)
);

// reset synchronizer @ soc_clk domain
reg soc_rst_r;
reg soc_rst_o;
always @(posedge soc_clk)
begin
	if (!sys_rst_n) begin
		// enter reset mode
		soc_rst_r <= 1'b1;
		soc_rst_o <= 1'b1;
	end else begin
		// leave reset mode
		soc_rst_r <= 1'b0;
		soc_rst_o <= soc_rst_r;
	end
end

assign soc_clk = clk_10m;
assign soc_rst = soc_rst_o;
soc_top soc_top0 (
	.clk_i(soc_clk),
	.rst_i(soc_rst),

	// uart interface
	.uart0_rx_i(c2c_d[0]),
	.uart0_tx_o(c2c_d[1])
);

assign clock_scl = 1'bz;
assign clock_sda = 1'bz;

endmodule
