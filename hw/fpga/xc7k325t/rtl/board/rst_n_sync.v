
module rst_n_sync (
	clk_i,
	rst_n_i,
	rst_n_o
);

input		clk_i;
input		rst_n_i;
output		rst_n_o;
reg		rst_n_o;
reg		rst_n_r;

// async reset synchronizer
always @(posedge clk_i or negedge rst_n_i)
begin
	if (!rst_n_i) begin
		rst_n_r	<= 1'b0;
		rst_n_o	<= 1'b0;
	end else begin
		rst_n_r	<= 1'b1;
		rst_n_o	<= rst_n_r;
	end
end

endmodule
