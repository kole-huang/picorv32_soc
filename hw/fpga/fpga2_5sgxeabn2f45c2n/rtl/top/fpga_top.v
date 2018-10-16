module fpga_top (
//Clocks Inputs
	input				svb_clk_p,		//LVDS
	input				svb_clk_125_p,		//LVDS
	input				svb_clk_50,		//1.8V
	input				clkinbotb_ddr3_p,	//LVDS Exteranl Terminate
	input				clkintopb_ddr3_p,	//LVDS Exteranl Terminate

	output				clock_scl,		//2.5V Si5338 I2C scl -> Tri-state when notin use.
	inout				clock_sda,		//2.5V Si5338 I2C sda -> Tri-state when notin use.

//OCT Termination
	input				rzq_5_2,		//1.5V oct.rzqin for DDR3

//EEPROM
	input				eeprom2_scl,		//2.5V
	inout				eeprom2_sda,		//2.5V

//DDR3
	output	[13:0]			ddr3e_a,		//1.5V
	output	[2:0]			ddr3e_ba,		//1.5V
	output				ddr3e_clk_p,		//1.5V
	output				ddr3e_clk_n,		//1.5V
	output				ddr3e_cke,		//1.5V
	output				ddr3e_csn,		//1.5V
	output	[3:0]			ddr3e_dm,		//1.5V
	output				ddr3e_rasn,		//1.5V
	output				ddr3e_casn,		//1.5V
	output				ddr3e_wen,		//1.5V
	output				ddr3e_resetn,		//1.5V
	inout	[31:0]			ddr3e_dq,		//1.5V
	inout	[3:0]			ddr3e_dqs_p,		//1.5V
	inout	[3:0]			ddr3e_dqs_n,		//1.5V
	output				ddr3e_odt,		//1.5V

	output	[13:0]			ddr3f_a,		//1.5V
	output	[2:0]			ddr3f_ba,		//1.5V
	output				ddr3f_clk_p,		//1.5V
	output				ddr3f_clk_n,		//1.5V
	output				ddr3f_cke,		//1.5V
	output				ddr3f_csn,		//1.5V
	output	[7:0]			ddr3f_dm,		//1.5V
	output				ddr3f_rasn,		//1.5V
	output				ddr3f_casn,		//1.5V
	output				ddr3f_wen,		//1.5V
	output				ddr3f_resetn,		//1.5V
	inout	[63:0]			ddr3f_dq,		//1.5V
	inout	[7:0]			ddr3f_dqs_p,		//1.5V
	inout	[7:0]			ddr3f_dqs_n,		//1.5V
	output				ddr3f_odt,		//1.5V

	output	[13:0]			ddr3g_a,		//1.5V
	output	[2:0]			ddr3g_ba,		//1.5V
	output				ddr3g_clk_p,		//1.5V
	output				ddr3g_clk_n,		//1.5V
	output				ddr3g_cke,		//1.5V
	output				ddr3g_csn,		//1.5V
	output	[3:0]			ddr3g_dm,		//1.5V
	output				ddr3g_rasn,		//1.5V
	output				ddr3g_casn,		//1.5V
	output				ddr3g_wen,		//1.5V
	output				ddr3g_resetn,		//1.5V
	inout	[31:0]			ddr3g_dq,		//1.5V
	inout	[3:0]			ddr3g_dqs_p,		//1.5V
	inout	[3:0]			ddr3g_dqs_n,		//1.5V
	output				ddr3g_odt,		//1.5V

	output	[13:0]			ddr3h_a,		//1.5V
	output	[2:0]			ddr3h_ba,		//1.5V
	output				ddr3h_clk_p,		//1.5V
	output				ddr3h_clk_n,		//1.5V
	output				ddr3h_cke,		//1.5V
	output				ddr3h_csn,		//1.5V
	output	[7:0]			ddr3h_dm,		//1.5V
	output				ddr3h_rasn,		//1.5V
	output				ddr3h_casn,		//1.5V
	output				ddr3h_wen,		//1.5V
	output				ddr3h_resetn,		//1.5V
	inout	[63:0]			ddr3h_dq,		//1.5V
	inout	[7:0]			ddr3h_dqs_p,		//1.5V
	inout	[7:0]			ddr3h_dqs_n,		//1.5V
	output				ddr3h_odt,		//1.5V

//HSMC---------------------------------//107pins //--------------------------
	inout	[3:0]			hsmc_d,			//2.5V		//Dedicated CMOS IO

//Chip-to-Chip -----------------------------//xx pins  //--------------------------
	inout	[11:0]			c2c_d,

//User-IO------------------------------//27 pins //--------------------------
	input	[7:0]			fpga2_dipsw,		//1.5V		//User DIP Switches (TR=0)
	output	[7:0]			fpga2_led_g,		//1.5V/2.5V	//User LEDs
	output	[7:0]			fpga2_led_r,		//1.5V		//User LEDs
	input	[2:0]			fpga2_pb,		//		//User Pushbuttons (TR=0)
	input				fpga2_cpu_resetn	//2.5V		//CPU Reset Pushbutton (TR=0)
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
	.clk_i(svb_clk_50),
	.rst_n_i(fpga2_cpu_resetn),
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
	.uart0_tx_o(hsmc_d[2]),
	.uart0_rx_i(hsmc_d[3])
);

assign clock_scl = 1'bZ;
assign clock_sda = 1'bZ;

// UART TX of FPGA1
assign hsmc_d[0] = c2c_d[0];
// UART RX of FPGA1
assign c2c_d[1] = hsmc_d[1];

endmodule
