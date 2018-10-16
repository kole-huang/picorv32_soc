
`define HOLD_10CYC	20'd10
`define HOLD_100CYC	20'd100
`define HOLD_1000CYC	20'd1000
`define HOLD_10000CYC	20'd10000
`define HOLD_100000CYC	20'd100000
`define HOLD_1000000CYC	20'd1000000
`define HOLD_MIN	`HOLD_10CYC
`define HOLD_MAX	`HOLD_1000000CYC

module rst_n_hold (
	clk_i,
	rst_n_i,
	pll_locked,
	rst_n_hold_o
);

parameter	RST_N_HOLD_CNT = `HOLD_100CYC;

// synopsys translate_off
initial begin
	if (RST_N_HOLD_CNT < `HOLD_MIN || RST_N_HOLD_CNT > `HOLD_MAX) begin
		$display("%m : ERROR!!! RST_N_HOLD_CNT %d is not in range: %d ~ %d", RST_N_HOLD_CNT, `HOLD_MIN, `HOLD_MAX);
		$stop;
	end
end
// synopsys translate_on

input		clk_i;
input		rst_n_i;
input		pll_locked;	/* 1: pll is ready and stable */
output		rst_n_hold_o;	/* reset output signal */
reg [19:0]	counter;
reg		rst_n_hold_r;
reg		rst_n_hold_o;

always @(posedge clk_i)
begin
	if (!rst_n_i) begin
		counter <= 0;
		rst_n_hold_r <= 1'b0;
		rst_n_hold_o <= 1'b0;
	end else begin
		if (pll_locked) begin
			if ((counter < RST_N_HOLD_CNT)) begin
				rst_n_hold_r	<= 1'b0;
				rst_n_hold_o	<= 1'b0;
				counter		<= counter + 1'b1;
			end else begin
				rst_n_hold_r	<= 1'b1;
				rst_n_hold_o	<= rst_n_hold_r;
				counter		<= counter;
			end
		end
	end
end

endmodule
