//////////////////////////////////////////////////////////////////////
////                                                              ////
////  uart_transmitter.v                                          ////
////                                                              ////
////                                                              ////
////  This file is part of the "UART 16550 compatible" project    ////
////  http://www.opencores.org/cores/uart16550/                   ////
////                                                              ////
////  Documentation related to this project:                      ////
////  - http://www.opencores.org/cores/uart16550/                 ////
////                                                              ////
////  Projects compatibility:                                     ////
////  - WISHBONE                                                  ////
////  RS232 Protocol                                              ////
////  16550D uart (mostly supported)                              ////
////                                                              ////
////  Overview (main Features):                                   ////
////  UART core transmitter logic                                 ////
////                                                              ////
////  Known problems (limits):                                    ////
////  None known                                                  ////
////                                                              ////
////  To Do:                                                      ////
////  Thourough testing.                                          ////
////                                                              ////
////  Author(s):                                                  ////
////      - gorban@opencores.org                                  ////
////      - Jacob Gorban                                          ////
////      - Igor Mohor (igorm@opencores.org)                      ////
////                                                              ////
////  Created:        2001/05/12                                  ////
////  Last Updated:   2001/05/17                                  ////
////                  (See log for the revision history)          ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000, 2001 Authors                             ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.18  2002/07/22 23:02:23  gorban
// Bug Fixes:
//  * Possible loss of sync and bad reception of stop bit on slow baud rates fixed.
//    Problem reported by Kenny.Tung.
//  * Bad (or lack of ) loopback handling fixed. Reported by Cherry Withers.
//
// Improvements:
//  * Made FIFO's as general inferrable memory where possible.
//  So on FPGA they should be inferred as RAM (Distributed RAM on Xilinx).
//  This saves about 1/3 of the Slice count and reduces P&R and synthesis times.
//
//  * Added optional baudrate output (baud_o).
//  This is identical to BAUDOUT* signal on 16550 chip.
//  It outputs 16xbit_clock_rate - the divided clock.
//  It's disabled by default. Define UART_HAS_BAUDRATE_OUTPUT to use.
//
// Revision 1.16  2002/01/08 11:29:40  mohor
// tf_pop was too wide. Now it is only 1 clk cycle width.
//
// Revision 1.15  2001/12/17 14:46:48  mohor
// overrun signal was moved to separate block because many sequential lsr
// reads were preventing data from being written to rx fifo.
// underrun signal was not used and was removed from the project.
//
// Revision 1.14  2001/12/03 21:44:29  gorban
// Updated specification documentation.
// Added full 32-bit data bus interface, now as default.
// Address is 5-bit wide in 32-bit data bus mode.
// Added wb_sel_i input to the core. It's used in the 32-bit mode.
// Added debug interface with two 32-bit read-only registers in 32-bit mode.
// Bits 5 and 6 of LSR are now only cleared on TX FIFO write.
// My small test bench is modified to work with 32-bit mode.
//
// Revision 1.13  2001/11/08 14:54:23  mohor
// Comments in Slovene language deleted, few small fixes for better work of
// old tools. IRQs need to be fix.
//
// Revision 1.12  2001/11/07 17:51:52  gorban
// Heavily rewritten interrupt and LSR subsystems.
// Many bugs hopefully squashed.
//
// Revision 1.11  2001/10/29 17:00:46  gorban
// fixed parity sending and tx_fifo resets over- and underrun
//
// Revision 1.10  2001/10/20 09:58:40  gorban
// Small synopsis fixes
//
// Revision 1.9  2001/08/24 21:01:12  mohor
// Things connected to parity changed.
// Clock devider changed.
//
// Revision 1.8  2001/08/23 16:05:05  mohor
// Stop bit bug fixed.
// Parity bug fixed.
// WISHBONE read cycle bug fixed,
// OE indicator (Overrun Error) bug fixed.
// PE indicator (Parity Error) bug fixed.
// Register read bug fixed.
//
// Revision 1.6  2001/06/23 11:21:48  gorban
// DL made 16-bit long. Fixed transmission/reception bugs.
//
// Revision 1.5  2001/06/02 14:28:14  gorban
// Fixed receiver and transmitter. Major bug fixed.
//
// Revision 1.4  2001/05/31 20:08:01  gorban
// FIFO changes and other corrections.
//
// Revision 1.3  2001/05/27 17:37:49  gorban
// Fixed many bugs. Updated spec. Changed FIFO files structure. See CHANGES.txt file.
//
// Revision 1.2  2001/05/21 19:12:02  gorban
// Corrected some Linter messages.
//
// Revision 1.1  2001/05/17 18:34:18  gorban
// First 'stable' release. Should be sythesizable now. Also added new header.
//
// Revision 1.0  2001-05-17 21:27:12+02  jacob
// Initial revision
//
//

`include "uart_defines.v"

module uart_transmitter(
	clk,
	rst,
	lcr,
	tf_push,
	tf_push_data,
	baud_pulse,
	stx_pad_o,
	tstate,
	tf_count,
	tx_reset,
	lsr_mask
);

input					clk;
input					rst;
input	[7:0]				lcr; // line control register
input					tf_push; // one clk pulse
input	[7:0]				tf_push_data;
input					baud_pulse; // 1 when at baud sample stage
input					tx_reset;
input					lsr_mask; // reset overrun of tfifo
output					stx_pad_o;
output	[2:0]				tstate;
output	[`UART_FIFO_COUNTER_W-1:0]	tf_count; // tx fifo ready bytes

reg	[2:0]				tstate;
reg	[4:0]				tcounter;
reg	[2:0]				bit_counter; // counts the bits to be sent
reg	[6:0]				shift_out; // output shift register (hold tx fifo data bits)
reg					stx_o_tmp; // the bit(data, parity, start stop bit) to be output to TX pad
reg					parity_xor; // parity of the word
reg					tf_pop; // 1 clk pulse
reg					bit_out; // data bit, parity bit

// TX FIFO instance
//
// Transmitter FIFO signals
// UART_FIFO_WIDTH: 8
wire	[`UART_FIFO_WIDTH-1:0]		tf_data_in;
wire	[`UART_FIFO_WIDTH-1:0]		tf_data_out;
wire					tf_push;
wire					tf_overrun; // this signal is not handled
wire	[`UART_FIFO_COUNTER_W-1:0]	tf_count; // current fifo count

assign					tf_data_in = tf_push_data;

uart_tfifo fifo_tx
(	// error bit signal is not used in transmitter FIFO
	.clk		(	clk		),
	.rst		(	rst		),
	.data_in	(	tf_data_in	),
	.data_out	(	tf_data_out	),
	.push		(	tf_push		),
	.pop		(	tf_pop		),
	.overrun	(	tf_overrun	),
	.count		(	tf_count	),
	.fifo_reset	(	tx_reset	),
	.reset_status	(	lsr_mask	)
);

// TRANSMITTER FINITE STATE MACHINE
parameter s_idle	= 3'd0;
parameter s_pop_byte	= 3'd1;
parameter s_send_start	= 3'd2;
parameter s_send_byte	= 3'd3;
parameter s_send_parity	= 3'd4;
parameter s_send_stop	= 3'd5;

always @(posedge clk or posedge rst)
begin
	if (rst)
	begin
		tstate		<= s_idle;
		stx_o_tmp	<= 1'b1;
		tcounter	<= 5'b0;
		shift_out	<= 7'b0;
		bit_out		<= 1'b0;
		parity_xor	<= 1'b0;
		tf_pop		<= 1'b0;
		bit_counter	<= 3'b0;
	end
	else
	// baud_pulse is 1 when divisor latch counter == 0
	// at every clk/(16*baud)
	// baud_pulse width is one clk period
	if (baud_pulse)
	begin
		case (tstate)
		s_idle:
		begin
			if (~|tf_count) // if tf_count == 0, TX FIFO is empty
			begin
				tstate <= s_idle;
				stx_o_tmp <= 1'b1;
			end
			else // tf_count > 0, the TX FIFO is not empty
			begin
				// at T+0, detect TX data available
				tf_pop <= 1'b0;
				stx_o_tmp <= 1'b1;
				tstate <= s_pop_byte;
			end
		end
		// at (T+1), enter this state
		// tf_data_out is already ready (combinational out)
		s_pop_byte:
		begin
			// tf_data_out is already ready
			tf_pop <= 1'b1; // do this makes tx fifo get status updated at next clk
			// word length
			// bit_counter = word length - 1
			case (lcr[/*`UART_LC_BITS*/1:0])  // number of bits in a word
			2'b00 : begin // 5bits
				bit_counter <= 3'b100; // 4
				parity_xor  <= ^tf_data_out[4:0];
			end
			2'b01 : begin // 6bits
				bit_counter <= 3'b101; // 5
				parity_xor  <= ^tf_data_out[5:0];
			end
			2'b10 : begin // 7bits
				bit_counter <= 3'b110; // 6
				parity_xor  <= ^tf_data_out[6:0];
			end
			2'b11 : begin // 8bits
				bit_counter <= 3'b111; // 7
				parity_xor  <= ^tf_data_out[7:0];
			end
			endcase
			// for 8bit data, {D7,D6,...,D0}, D7 is MSB, D0 is LSB
			// shift_out[6]: D7
			// shift_out[5]: D6
			// ...
			// shift_out[0]: D1
			// bit_out:      D0
			{shift_out[6:0], bit_out} <= tf_data_out;
			tstate <= s_send_start;
		end
		// at (T+2),    enter this state
		// at (T+2+d),  tcounter is 15,
		//              stx_o_tmp and stx_pad_o are assigned to 0
		// at (T+3+d),  tcounter is 14
		// at (T+4+d),  tcounter is 13
		// at (T+5+d),  tcounter is 12
		// at (T+6+d),  tcounter is 11
		// at (T+7+d),  tcounter is 10
		// at (T+8+d),  tcounter is 9
		// at (T+9+d),  tcounter is 8
		// at (T+10+d), tcounter is 7
		// at (T+11+d), tcounter is 6
		// at (T+12+d), tcounter is 5
		// at (T+13+d), tcounter is 4
		// at (T+14+d), tcounter is 3
		// at (T+15+d), tcounter is 2
		// at (T+16+d), tcounter is 1
		// at (T+17),   tcounter is sampled as 1
		// total 16 periods in this state
		s_send_start:
		begin
			if (~|tcounter) // if (tcounter == 0)
			begin
				tf_pop <= 1'b0; // stop pop data
				tcounter <= 5'b01111; // tcounter = 15
			end
			else
			if (tcounter == 5'b00001) // tcounter == 1
			begin
				tstate <= s_send_byte; // at 17T, to s_send_byte state
				tcounter <= 0;
			end
			else
			begin
				tcounter <= tcounter - 1'b1; // tcounter = tcounter - 1
			end
			stx_o_tmp <= 1'b0; // to low (start bit, will last 16T)
		end
		// at (T+18), enter this state
		// at (T+18+d), tcounter is 15,
		//              send first data bit(stx_o_tmp is bit_out, init in s_pop_byte state)
		// at (T+19+d), tcounter is 14
		// at (T+20+d), tcounter is 13
		// at (T+21+d), tcounter is 12
		// at (T+22+d), tcounter is 11
		// at (T+23+d), tcounter is 10
		// at (T+24+d), tcounter is 9
		// at (T+25+d), tcounter is 8
		// at (T+26+d), tcounter is 7
		// at (T+27+d), tcounter is 6
		// at (T+28+d), tcounter is 5
		// at (T+29+d), tcounter is 4
		// at (T+30+d), tcounter is 3
		// at (T+31+d), tcounter is 2
		// at (T+32+d), tcounter is 1
		// at (T+33),   tcounter is sampled as 1
		//              shift second data bit into bit_out
		// at (T+33+d), tcounter is 0
		// at (T+34),   enter this state
		// at (T+34+d), tcounter is 15,
		//              send second data bit
		// at (T+35+d), tcounter is 14
		// at (T+36+d), tcounter is 13
		// at (T+37+d), tcounter is 12
		// at (T+38+d), tcounter is 11
		// at (T+39+d), tcounter is 10
		// at (T+40+d), tcounter is 9
		// at (T+41+d), tcounter is 8
		// at (T+42+d), tcounter is 7
		// at (T+43+d), tcounter is 6
		// at (T+44+d), tcounter is 5
		// at (T+45+d), tcounter is 4
		// at (T+46+d), tcounter is 3
		// at (T+47+d), tcounter is 2
		// at (T+48+d), tcounter is 1
		// at (T+49),   tcounter is sampled as 1
		//              shift third data bit into bit_out
		// at (T+49+d), tcounter is 0
		// at (T+50),   enter this state
		// at (T+50+d), tcounter is 15
		//              send third data bit
		//
		// (T+18), (T+34), (T+50), (T+66), (T+82), (T+98), (T+114), (T+130), enter this state and send the data bit
		// (T+33), (T+49), (T+65), (T+81), (T+97), (T+113), (T+129), shift bit data into bit_out
		s_send_byte:
		begin // remains at this state until all the data bits are sent
			if (~|tcounter) // if (tcounter == 0)
				tcounter <= 5'b01111; // tcounter = 15
			else
			if (tcounter == 5'b00001) // tcounter == 1
			begin
				if (bit_counter > 3'b0) // bit_counter > 0
				begin
					bit_counter <= bit_counter - 1'b1;
					// right shift shift_out[]
					// the LSB is shifted to bit_out
					{shift_out[5:0], bit_out} <= {shift_out[6:1], shift_out[0]};
					tstate <= s_send_byte;
				end
				else // bit_counter == 0, end of byte
				begin
					if (~lcr[`UART_LC_PE]) // lcr[3] is 0, no parity
					begin
						tstate <= s_send_stop;
					end
					else // lcr[3] is 1, parity enable
					begin
						// even parity, stick parity
						case ({lcr[`UART_LC_EP],lcr[`UART_LC_SP]})
						// if parity_xor is 1 ==> odd number of 1 in data
						// if parity_xor is 0 ==> even number of 1 in data
						2'b00:	bit_out <= ~parity_xor; // odd parity combination
						2'b01:	bit_out <= 1'b1; // fixed parity number 1
						2'b10:	bit_out <= parity_xor; // even parity combination
						2'b11:	bit_out <= 1'b0; // fixed parity number 0
						endcase
						tstate <= s_send_parity;
					end
				end
				tcounter <= 0;
			end
			else
			begin
				tcounter <= tcounter - 1'b1;
			end
			stx_o_tmp <= bit_out; // send the data bit (last 16T)
		end
		// at (T+131),   enter this state
		// at (T+131+d), tcounter is 15
		//               send the parity bit
		// at (T+132+d), tcounter is 14
		// at (T+133+d), tcounter is 13
		// at (T+134+d), tcounter is 12
		// at (T+135+d), tcounter is 11
		// at (T+136+d), tcounter is 10
		// at (T+137+d), tcounter is 9
		// at (T+138+d), tcounter is 8
		// at (T+139+d), tcounter is 7
		// at (T+140+d), tcounter is 6
		// at (T+141+d), tcounter is 5
		// at (T+142+d), tcounter is 4
		// at (T+143+d), tcounter is 3
		// at (T+144+d), tcounter is 2
		// at (T+145+d), tcounter is 1
		// at (T+146),   tcounter is sampled as 1
		// total 16 periods in this state
		s_send_parity: begin
			if (~|tcounter) // tcounter == 0
				tcounter <= 5'b01111; // tcounter = 15
			else
			if (tcounter == 5'b00001)
			begin
				tstate <= s_send_stop;
				tcounter <= 0;
			end
			else
			begin
				tcounter <= tcounter - 1'b1;
			end
			stx_o_tmp <= bit_out; // send the parity bit (last 16T)
		end
		// if no parity
		// at (T+131),   enter this state
		// at (T+131+d), assign tcounter to 13 or 21 or 29
		//               send the stop bit
		//
		// if has parity
		// at (T+147),   enter this state
		// at (T+137+d), assign tcounter to 13 or 21 or 29
		//               send the stop bit
		s_send_stop: begin
			if (~|tcounter) // tcounter == 0
			begin
				casex ({lcr[`UART_LC_SB],lcr[`UART_LC_BITS]})
				3'b0xx:		tcounter <= 5'b01101; // 13, 1 stop bit
				3'b100:		tcounter <= 5'b10101; // 21, 1.5 stop bit
				default:	tcounter <= 5'b11101; // 29, 2 stop bits
				endcase
			end
			else
			if (tcounter == 5'b00001)
			begin
				tstate <= s_idle;
				tcounter <= 0;
			end
			else
			begin
				tcounter <= tcounter - 1'b1;
			end
			stx_o_tmp <= 1'b1; // to high (stop bit)
		end
		default: // should never get here
			tstate <= s_idle;
		endcase
	end // end if (baud_pulse)
	else // baud_pulse == 0
		tf_pop <= 1'b0;  // tf_pop is 1 clk pulse, asserted in s_pop_byte state
end // transmitter logic

// if lcr[6] == 1'b0
//    stx_pad_o = 1'b0
// else
//    stx_pad_o = stx_o_tmp
assign stx_pad_o = lcr[`UART_LC_BC] ? 1'b0 : stx_o_tmp; // Break condition

endmodule
