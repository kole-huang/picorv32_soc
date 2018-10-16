
module sys_mmcm_clk_rst_sync (
	clk_i_p,
	clk_i_n,
	rst_n_i,
	sys_rst_n_o,
	clk_100m,
	clk_50m,
	clk_25m,
	clk_10m,
	clk_5m
);

parameter	RST_N_HOLD_CNT = 50;

input	clk_i_p;
input	clk_i_n;
input	rst_n_i; // low active
output	sys_rst_n_o; // low active
output	clk_100m;
output	clk_50m;
output	clk_25m;
output	clk_10m;
output	clk_5m;

wire	rst_n_sync; // synced rst_n_i, low active
wire	sys_mmcm_clk_rst; // high active
wire	sys_mmcm_clk_locked;
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
	.pll_locked(sys_mmcm_clk_locked),
	.rst_n_hold_o(sys_rst_n_o)
);

assign sys_mmcm_clk_rst = ~rst_n_sync;

sys_mmcm_clk sys_mmcm_clk_u0 (
	.clk_in1_p(clk_i_p),
	.clk_in1_n(clk_i_n),
	.reset(sys_mmcm_clk_rst),
	.locked(sys_mmcm_clk_locked),
	.clk_100m(clk_100m),
	.clk_50m(clk_50m),
	.clk_25m(clk_25m),
	.clk_10m(clk_10m),
	.clk_5m(clk_5m)
);

endmodule
