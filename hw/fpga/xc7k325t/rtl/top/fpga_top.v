//`define FPGA_DEBUG

module fpga_top (
	SYS_CLK_P,
	SYS_CLK_N,
	RST,
	PUSH_BUTTON,
	DIP_SWITCH,
	LED,
	UART_TX,
	UART_RX
);

parameter	RST_N_HOLD_CNT = 50;

input		SYS_CLK_P;
input		SYS_CLK_N;
input		RST;
input  [1:0]	PUSH_BUTTON;
input  [3:0]	DIP_SWITCH;
output [7:0]	LED;
input		UART_RX;
output		UART_TX;

`ifdef FPGA_DEBUG
wire clk_100m /* synthesis keep */;
wire clk_50m /* synthesis keep */;
wire clk_25m /* synthesis keep */;
wire clk_10m /* synthesis keep */;
wire clk_5m /* synthesis keep */;
wire sys_rst_n /* synthesis keep */;
`else
wire clk_100m;
wire clk_50m;
wire clk_25m;
wire clk_10m;
wire clk_5m;
wire sys_rst_n;
`endif

// BUTTON[0] && BUTTON[1] go to low when pushed, go to high when released
// after done, sys_rst_n will be from 0 -> 1
sys_mmcm_clk_rst_sync #(
	.RST_N_HOLD_CNT(RST_N_HOLD_CNT)
) sys_mmcm_clk_rst_sync_u0 (
	.clk_i_p(SYS_CLK_P),
	.clk_i_n(SYS_CLK_N),
	.rst_n_i(RST),
	.sys_rst_n_o(sys_rst_n),
	.clk_100m(clk_100m),
	.clk_50m(clk_50m),
	.clk_25m(clk_25m),
	.clk_10m(clk_10m),
	.clk_5m(clk_5m)
);

wire soc_rst; // low active
wire soc_clk;

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
	.uart0_rx_i(UART_RX),
	.uart0_tx_o(UART_TX)
);

endmodule
