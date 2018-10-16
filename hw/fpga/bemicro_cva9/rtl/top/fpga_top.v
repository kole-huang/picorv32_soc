module fpga_top (
	////////////////////	Clock Input 	////////////////////
	CLK_24M,				//	On Board 24 MHz
	////////////////////	Push Button	////////////////////
	KEY,					//	Pushbutton
	////////////////////	DPDT Switch	////////////////////
	DIPSW,					//	Toggle Switch
	////////////////////	LED		////////////////////////
	LED,					//	LED
	////////////////////	UART		////////////////////////
	UART0_TX,				//	UART0 Transmitter
	UART0_RX				//	UART0 Receiver
);

parameter	RST_N_HOLD_CNT = 50;

////////////////////////	Clock Input 	////////////////////////
input		CLK_24M;			//	On Board 24 MHz
////////////////////////	Push Button	////////////////////////
input	[1:0]	KEY;				//	Pushbutton
////////////////////////	DPDT Switch	////////////////////////
input	[3:0]	DIPSW;				//	Toggle Switch
////////////////////////////	LED		////////////////////////////
output	[7:0]	LED;				//	LED
////////////////////////////	UART		////////////////////////////
output		UART0_TX;			//	UART0 Transmitter
input		UART0_RX;			//	UART0 Receiver

wire sys_rst_n;
wire clk_100m, clk_50m, clk_25m, clk_10m, clk_5m, clk_1m;
wire soc_rst; // low active
wire soc_clk;

// KEY[0] && KEY[1] go to low when pushed, go to high when released
// after done, sys_rst_n will be from 0 -> 1
pll_rst_sync #(
	.RST_N_HOLD_CNT(RST_N_HOLD_CNT)
) pll_rst_sync0 (
	.clk_i(CLK_24M),
	.rst_n_i(KEY[0]),
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
	.uart0_rx_i(UART0_RX),
	.uart0_tx_o(UART0_TX)
);

endmodule
