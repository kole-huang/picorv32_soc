`timescale 1ns/1ps

module top_tb();

	reg		SYS_CLK_P;
	reg		SYS_CLK_N;
	reg	[1:0]	PUSH_BUTTON;
	reg	[3:0]	DIP_SWITCH;
	wire	[2:0]	LED;

	initial begin
		$dumpfile("waveform.vcd");
		$dumpvars(0, top_tb.fpga_top0.soc_top0);
	end

	initial begin
		SYS_CLK_P = 1'b0;
		SYS_CLK_N = 1'b1;
		forever #10 SYS_CLK_P = ~SYS_CLK_P;
		forever #10 SYS_CLK_N = ~SYS_CLK_N;
	end

	initial begin
		DIP_SWITCH[0] = 1'b0;
		DIP_SWITCH[1] = 1'b0;
		DIP_SWITCH[2] = 1'b0;
		DIP_SWITCH[3] = 1'b0;
		PUSH_BUTTON[0] = 1'b0;
		PUSH_BUTTON[1] = 1'b0;
		#50 PUSH_BUTTON[0] = 1'b1;
	end

	fpga_top #(
		.RST_N_HOLD_CNT(100)
	) fpga_top0 (
		////////////////////	Clock Input	 	////////////////////
		.SYS_CLK_P(SYS_CLK_P),				//	On Board 50 MHz
		.SYS_CLK_N(SYS_CLK_N),				//	On Board 50 MHz
		////////////////////	Push Button		////////////////////
		.PUSH_BUTTON(PUSH_BUTTON),			//	Pushbutton
		////////////////////	LED			////////////////////
		.DIP_SWITCH(DIP_SWITCH),			//	DIP Switch
		////////////////////				////////////////////
		.LED(LED),					//	LED
		////////////////////	UART			////////////////////
		.UART_TX(UART_TX),				//	UART Transmitter
		.UART_RX(UART_RX)				//	UART Receiver
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

	// monitor UART TX
	uart_rx_monitor uart_rx_monitor0(
		.reset(~RST),
		.rxclk(baudclk),
		.rx_in(UART_TX)
	);

endmodule
