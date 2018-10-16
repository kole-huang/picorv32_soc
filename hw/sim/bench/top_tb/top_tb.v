`timescale 1ns/1ps

module top_tb();

reg				CLOCK_100M;
reg				CLOCK_50M;
reg				CLOCK_25M;
reg				CLOCK_10M;
reg				CLOCK_5M;
reg				CLOCK_1M;
reg				RST;
wire				UART0_TX;
wire				UART0_RX;

initial begin
	//$dumpfile("waveform.vcd");
	//$dumpvars(0, top_tb);
end

initial begin
	CLOCK_100M = 1'b0;
	forever #5 CLOCK_100M = ~CLOCK_100M;
end

initial begin
	CLOCK_50M = 1'b0;
	forever #10 CLOCK_50M = ~CLOCK_50M;
end

initial begin
	CLOCK_25M = 1'b0;
	forever #20 CLOCK_25M = ~CLOCK_25M;
end

initial begin
	CLOCK_10M = 1'b0;
	forever #50 CLOCK_10M = ~CLOCK_10M;
end

initial begin
	CLOCK_5M = 1'b0;
	forever #100 CLOCK_5M = ~CLOCK_5M;
end

initial begin
	CLOCK_1M = 1'b0;
	forever #500 CLOCK_1M = ~CLOCK_1M;
end

initial begin
	RST = 1'b1;
	#500 RST = 1'b0;
end

wire soc_rst; // low active
wire soc_clk;

assign soc_clk = CLOCK_10M;
assign soc_rst = RST;
soc_top soc_top0 (
	.clk_i(soc_clk),
	.rst_i(soc_rst),

	// uart interface
	.uart0_rx_i(UART0_RX),
	.uart0_tx_o(UART0_TX)
);

// baud clock half period
// timescale is 1ns
// so clock rate is 10^9 Hz
// (10^9)/(16*baud_rate)/2
`define BAUDCLK_HALF_PERIOD 814

	reg 	baudclk;
	initial begin
		baudclk = 0;
		forever # `BAUDCLK_HALF_PERIOD baudclk = ~baudclk;
	end

	// monitor UART0 TX
	uart_rx_monitor uart_rx_monitor0(
		.reset(RST),
		.rxclk(baudclk),
		.rx_in(UART0_TX)
	);

endmodule
