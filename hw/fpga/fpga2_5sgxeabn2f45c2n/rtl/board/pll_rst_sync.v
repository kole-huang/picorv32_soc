
module pll_rst_sync (
	clk_i,
	rst_n_i,
	sys_rst_n_o,
	clk_c0,
	clk_c1,
	clk_c2,
	clk_c3,
	clk_c4,
	clk_c5
);

parameter	RST_N_HOLD_CNT = 50;

input	clk_i;
input	rst_n_i; // low active
output	sys_rst_n_o; // low active
output	clk_c0;
output	clk_c1;
output	clk_c2;
output	clk_c3;
output	clk_c4;
output	clk_c5;

wire	rst_n_sync; // synced rst_n_i, low active
wire	pll_rst; // high active
wire	pll_locked;
wire	sys_rst_n_o;

// reset synchronizer
// rst_n_i is asynchronous event
// When BUTTON[0] is pressed, rst_n_i is low, this enter reset mode
// When BUTTON[0] is released, rst_n_i is high, after one clk, will leave reset
// mode
rst_n_sync rst_n_sync_u0 (
	.clk_i(clk_i),
	.rst_n_i(rst_n_i),
	.rst_n_o(rst_n_sync)
);

// reset signal extender
// rst_n_sync is synchronous event
// rst_n_sync is low, enter reset mode,
// Also PLL is in reset mode.
// rst_n_sync is high, after one clk, PLL will leave reset mode
// rst_n_hold will remain low during RST_N_HOLD_CNT clk periods after
// pll_locked is high
rst_n_hold #(
	.RST_N_HOLD_CNT(RST_N_HOLD_CNT)
) rst_n_hold_u0 (
	.clk_i(clk_i),
	.rst_n_i(rst_n_sync),
	.pll_locked(pll_locked),
	.rst_n_hold_o(sys_rst_n_o)
);

// pll reset pulse (high active), to reset pll
// when BUTTON[0] is pressed, rst_n_sync is low
// pll_rst will be high
// when BUTTON[0] is released, rst_n_sync is high
// pll_rst will be low
assign pll_rst = ~rst_n_sync;

sys_pll sys_pll_u0 (
	.refclk(clk_i),
	.rst(pll_rst),
	.outclk_0(clk_c0),
	.outclk_1(clk_c1),
	.outclk_2(clk_c2),
	.outclk_3(clk_c3),
	.outclk_4(clk_c4),
	.outclk_5(clk_c5),
	.locked(pll_locked)
);

endmodule
