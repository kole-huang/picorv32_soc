//////////////////////////////////////////////////////////////////////
////                                                              ////
////  uart_receiver.v                                             ////
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
////  UART core receiver logic                                    ////
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
// Revision 1.29  2002/07/29 21:16:18  gorban
// The uart_defines.v file is included again in sources.
//
// Revision 1.28  2002/07/22 23:02:23  gorban
// Bug Fixes:
//  * Possible loss of sync and bad reception of stop bit on slow baud rates fixed.
//   Problem reported by Kenny.Tung.
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
// Revision 1.27  2001/12/30 20:39:13  mohor
// More than one character was stored in case of break. End of the break
// was not detected correctly.
//
// Revision 1.26  2001/12/20 13:28:27  mohor
// Missing declaration of rf_push_q fixed.
//
// Revision 1.25  2001/12/20 13:25:46  mohor
// rx push changed to be only one cycle wide.
//
// Revision 1.24  2001/12/19 08:03:34  mohor
// Warnings cleared.
//
// Revision 1.23  2001/12/19 07:33:54  mohor
// Synplicity was having troubles with the comment.
//
// Revision 1.22  2001/12/17 14:46:48  mohor
// overrun signal was moved to separate block because many sequential lsr
// reads were preventing data from being written to rx fifo.
// underrun signal was not used and was removed from the project.
//
// Revision 1.21  2001/12/13 10:31:16  mohor
// timeout irq must be set regardless of the rda irq (rda irq does not reset the
// timeout counter).
//
// Revision 1.20  2001/12/10 19:52:05  gorban
// Igor fixed break condition bugs
//
// Revision 1.19  2001/12/06 14:51:04  gorban
// Bug in LSR[0] is fixed.
// All WISHBONE signals are now sampled, so another wait-state is introduced on all transfers.
//
// Revision 1.18  2001/12/03 21:44:29  gorban
// Updated specification documentation.
// Added full 32-bit data bus interface, now as default.
// Address is 5-bit wide in 32-bit data bus mode.
// Added wb_sel_i input to the core. It's used in the 32-bit mode.
// Added debug interface with two 32-bit read-only registers in 32-bit mode.
// Bits 5 and 6 of LSR are now only cleared on TX FIFO write.
// My small test bench is modified to work with 32-bit mode.
//
// Revision 1.17  2001/11/28 19:36:39  gorban
// Fixed: timeout and break didn't pay attention to current data format when counting time
//
// Revision 1.16  2001/11/27 22:17:09  gorban
// Fixed bug that prevented synthesis in uart_receiver.v
//
// Revision 1.15  2001/11/26 21:38:54  gorban
// Lots of fixes:
// Break condition wasn't handled correctly at all.
// LSR bits could lose their values.
// LSR value after reset was wrong.
// Timing of THRE interrupt signal corrected.
// LSR bit 0 timing corrected.
//
// Revision 1.14  2001/11/10 12:43:21  gorban
// Logic Synthesis bugs fixed. Some other minor changes
//
// Revision 1.13  2001/11/08 14:54:23  mohor
// Comments in Slovene language deleted, few small fixes for better work of
// old tools. IRQs need to be fix.
//
// Revision 1.12  2001/11/07 17:51:52  gorban
// Heavily rewritten interrupt and LSR subsystems.
// Many bugs hopefully squashed.
//
// Revision 1.11  2001/10/31 15:19:22  gorban
// Fixes to break and timeout conditions
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
// Revision 1.0  2001-05-17 21:27:11+02  jacob
// Initial revision
//
//

`include "uart_defines.v"

module uart_receiver(
	clk,
	rst,
	lcr,
	rf_pop,
	srx_pad_i,
	baud_pulse,
	counter_t,
	rf_count,
	rf_data_out,
	rf_error_bit,
	rf_overrun,
	rx_reset,
	lsr_mask,
	rstate,
	rf_push_pulse
);

input					clk;
input					rst;
input	[7:0]				lcr;
input					rf_pop;
input					srx_pad_i;
input					baud_pulse; // at baud sample stage, baud_pulse is 1
input					rx_reset;
input					lsr_mask;

output	[9:0]				counter_t; // timeout counter
output	[`UART_FIFO_COUNTER_W-1:0]	rf_count; // fifo element count
// UART_FIFO_REC_WIDTH: 11
output	[`UART_FIFO_REC_WIDTH-1:0]	rf_data_out;
output					rf_overrun;
output					rf_error_bit;
output	[3:0]				rstate;
output					rf_push_pulse;

reg	[3:0]	rstate;			// uart rx state
reg	[3:0]	rcounter16;		// decreament 4 bit counter
reg	[2:0]	rbit_counter;		// receive bit counter
reg	[7:0]	rshift;			// receiver shift register
reg		rparity;		// received parity bit
reg		rparity_error;		// parity error signal
reg		rframing_error;		// framing error flag
reg		rparity_xor;		// calculated parity
reg	[7:0]	counter_b;		// counts the 0 (low) signals
reg		rf_push_q;		// sampled rf_push last clk

// RX FIFO signals
// rx data (8bits data and 3bits frame info) from rx pad
reg	[`UART_FIFO_REC_WIDTH-1:0]	rf_data_in;
// rx data (8bits data and 3bits frame info) to uart_regs
wire	[`UART_FIFO_REC_WIDTH-1:0]	rf_data_out;
wire					rf_push_pulse; // rising edge detection of rf_push, one clk pulse
reg					rf_push;
wire					rf_pop; // one clk pulse
wire					rf_overrun; // rx fifo full indication
wire	[`UART_FIFO_COUNTER_W-1:0]	rf_count; // fifo element count
wire					rf_error_bit; // an error (parity or framing) is inside the fifo
// counter_b is 0 indicates that no rising pulse during
// a data frame transfer.
// this detect break control behaviour (lcr[6] is set)
wire					break_error = (counter_b == 0);

// RX FIFO instance
uart_rfifo #(`UART_FIFO_REC_WIDTH) fifo_rx(
	.clk		(	clk		),
	.rst		(	rst		),
	.data_in	(	rf_data_in	),
	.data_out	(	rf_data_out	),
	.push		(	rf_push_pulse	),
	.pop		(	rf_pop		),
	.overrun	(	rf_overrun	),
	.count		(	rf_count	),
	.error_bit	(	rf_error_bit	),
	.fifo_reset	(	rx_reset	),
	.reset_status	(	lsr_mask	)
);

parameter  sr_idle		= 4'd0;
parameter  sr_rec_start		= 4'd1;
parameter  sr_rec_bit		= 4'd2;
parameter  sr_rec_parity	= 4'd3;
parameter  sr_rec_stop		= 4'd4;
parameter  sr_check_parity	= 4'd5;
parameter  sr_rec_prepare	= 4'd6;
parameter  sr_end_bit		= 4'd7;
parameter  sr_calc_parity	= 4'd8;
parameter  sr_wait1		= 4'd9;
parameter  sr_push		= 4'd10;

always @(posedge clk or posedge rst)
begin
	if (rst)
	begin
		rstate		<= sr_idle;
		rcounter16	<= 0;
		rbit_counter	<= 0;
		rparity_xor	<= 1'b0;
		rframing_error	<= 1'b0;
		rparity_error	<= 1'b0;
		rparity		<= 1'b0;
		rshift		<= 0;
		rf_push		<= 1'b0;
		rf_data_in	<= 0;
	end
	else
	if (baud_pulse) // at baud sample stage, baud_pulse is 1
	begin
		case (rstate)
		// detects start bit
		sr_idle: begin
			rf_push		<= 1'b0;
			rf_data_in	<= 0;
			rcounter16	<= 0;
			// detects start bit
			if (srx_pad_i == 1'b0 & ~break_error) // detected a pulse (start bit?)
			begin
				// at (T+0), start bit is detected
				// at (T+d). rstate is sr_rec_start
				rstate	<= sr_rec_start;
			end
		end
		// at (T+0),   start bit is detcted
		// at (T+1),   enter this state
		// at (T+1+d), rcounter16 is 0xF
		// at (T+2+d), rcounter16 is 0xE
		// at (T+3+d), rcounter16 is 0xD
		// at (T+4+d), rcounter16 is 0xC
		// at (T+5+d), rcounter16 is 0xB
		// at (T+6+d), rcounter16 is 0xA
		// at (T+7+d), rcounter16 is 0x9
		// at (T+8),   rcounter16 is sampled as 0x9
		// at (T+8),   sample srx_pad_i again
		// if (srx_pad_i) is still zero at detection, ==> go to sr_rec_prepare state
		// else goto sr_idle
		sr_rec_start: begin
			if (~|rcounter16) // rcounter16 == 0
			begin
				rf_push <= 1'b0;
				rcounter16 <= 4'b1111;
			end
			else
			if (rcounter16 == 4'b1001) // at (T+8), enter this condition, check the pulse
			begin
				if (srx_pad_i == 1'b1) // no start bit
					rstate <= sr_idle;
				else // start bit is still held zero
				begin
					// jump to sr_rec_prepare state
					// at (T+8+d), rstate is sr_rec_prepare
					rstate <= sr_rec_prepare;
					rcounter16 <= 0;
				end
			end
			else
			begin
				rcounter16 <= rcounter16 - 1'b1;
			end
		end
		// at (T+9),    enter this state
		// at (T+9+d),  rcounter16 is 0xF
		// at (T+10+d), rcounter16 is 0xE
		// at (T+11+d), rcounter16 is 0xD
		// at (T+12+d), rcounter16 is 0xC
		// at (T+13+d), rcounter16 is 0xB
		// at (T+14+d), rcounter16 is 0xA
		// at (T+15+d), rcounter16 is 0x9
		// at (T+16),   rcounter16 is sampled as 0x9
		//
		// wait 8 clk and enter sr_rec_bit state
		sr_rec_prepare: begin
			if (~|rcounter16) // rcounter16 == 0
			begin
				case (lcr[/*`UART_LC_BITS*/1:0])  // number of bits in a word
				// for 8bits mode
				// sample rx data bit at rbit_counter (7, 6, 5, 4, 3, 2, 1, 0)
				2'b00 : rbit_counter <= 3'b100; // 4
				2'b01 : rbit_counter <= 3'b101; // 5
				2'b10 : rbit_counter <= 3'b110; // 6
				2'b11 : rbit_counter <= 3'b111; // 7
				endcase
				rcounter16 <= 4'b1111;
			end
			else
			if (rcounter16 == 4'b1001) // at T+16, enter this condition
			begin
				rshift		<= 0;
				rstate		<= sr_rec_bit;
				rcounter16	<= 0;
			end
			else
			begin
				rcounter16	<= rcounter16 - 1'b1;
			end
		end
		// at (T+17),   enter this state
		// at (T+17+d), rcounter16 is 0xF
		// at (T+18+d), rcounter16 is 0xE
		// at (T+19+d), rcounter16 is 0xD
		// at (T+20+d), rcounter16 is 0xC
		// at (T+21+d), rcounter16 is 0xB
		// at (T+22+d), rcounter16 is 0xA
		// at (T+23+d), rcounter16 is 0x9
		// at (T+24),   rcounter16 is sampled as 0x9
		//		sample RX data bit
		// at (T+24+d), rcounter16 is 0x8
		// at (T+25+d), rcounter16 is 0x7
		// at (T+26+d), rcounter16 is 0x6
		// at (T+27+d), rcounter16 is 0x5
		// at (T+28+d), rcounter16 is 0x4
		// at (T+29+d), rcounter16 is 0x3
		// at (T+30+d), rcounter16 is 0x2
		// at (T+31),	rcounter16 is sampled as 0x2
		// at (T+32),   enter sr_end_bit state
		// at (T+33),   enter here from sr_end_bit state
		// at (T+33+d), rcounter16 is 0xF
		// at (T+34+d), rcounter16 is 0xE
		// at (T+35+d), rcounter16 is 0xD
		// at (T+36+d), rcounter16 is 0xC
		// at (T+37+d), rcounter16 is 0xB
		// at (T+38+d), rcounter16 is 0xA
		// at (T+39+d), rcounter16 is 0x9
		// at (T+40),	rcounter16 is sampled as 0x9
		//		sample RX data bit
		// at (T+40+d), rcounter16 is 0x8
		// at (T+41+d), rcounter16 is 0x7
		// at (T+42+d), rcounter16 is 0x6
		// at (T+43+d), rcounter16 is 0x5
		// at (T+44+d), rcounter16 is 0x4
		// at (T+45+d). rcounter16 is 0x3
		// at (T+46+d), rcounter16 is 0x2
		// at (T+47),	rcounter16 is sampled as 0x2
		// at (T+48),   enter sr_end_bit state
		// at (T+49),   enter here from sr_end_bit state
		// at (T+49+d), rcounter16 is 0xF
		// at (T+50+d), rcounter16 is 0xE
		// at (T+51+d), rcounter16 is 0xD
		// at (T+52+d), rcounter16 is 0xC
		// at (T+53+d), rcounter16 is 0xB
		// at (T+54+d), rcounter16 is 0xA
		// at (T+55+d), rcounter16 is 0x9
		// at (T+56),   rcounter16 is sampled as 0x9
		//		sample RX data bit
		// at (T+56+d), rcounter16 is 0x8
		// at (T+57+d), rcounter16 is 0x7
		// at (T+58+d), rcounter16 is 0x6
		// at (T+59+d), rcounter16 is 0x5
		// at (T+60+d), rcounter16 is 0x4
		// at (T+61+d), rcounter16 is 0x3
		// at (T+62+d), rcounter16 is 0x2
		// at (T+63),   rcounter16 is sampled as 0x2
		// at (T+64),   enter sr_end_bit state
		// at (T+65),   enter here from sr_end_bit state
		//
		//
		// (T+17), (T+33), (T+49), (T+65), (T+81), (T+97), (T+113), (T+129), enter this state
		// (T+24), (T+40), (T+56), (T+72), (T+88), (T+104), (T+120), (T+136), sample the data bit
		sr_rec_bit: begin
			if (~|rcounter16) // rcounter16 == 0
			begin
				rcounter16 <= 4'b1111;
			end
			else
			// at (T+31), (T+47), (T+63), (T+79), (T+95), (T+111), (T+127), (T+143) enter this condition
			if (rcounter16 == 4'b0010)
			begin
				rstate <= sr_end_bit;
			end
			// at (T+24), (T+40), (T+56), (T+72), (T+88), (T+104), (T+120), (T+136), read the data bit
			else
			if (rcounter16 == 4'b1001)
			begin
				case (lcr[/*`UART_LC_BITS*/1:0]) // number of bits in a word
				// do right shift
				2'b00 : rshift[4:0]  <= {srx_pad_i, rshift[4:1]};
				2'b01 : rshift[5:0]  <= {srx_pad_i, rshift[5:1]};
				2'b10 : rshift[6:0]  <= {srx_pad_i, rshift[6:1]};
				2'b11 : rshift[7:0]  <= {srx_pad_i, rshift[7:1]};
				endcase
			end
			rcounter16 <= rcounter16 - 1'b1;
		end
		// (T+32), (T+48), (T+64), (T+80), (T+96), (T+112), (T+128), (T+144) enter this state
		// if all the data bits are received, jump to src_rec_stop or src_rec_parity
		// else go back to sr_rec_bit
		sr_end_bit: begin
			if (rbit_counter == 3'b0) // no more data bits
			begin
				if (lcr[`UART_LC_PE]) // has parity
				begin
					rstate <= sr_rec_parity;
				end
				else // no parity
				begin
					rparity_error <= 1'b0;  // no parity - no error :)
					rstate <= sr_rec_stop;
				end
			end
			else // else we have more bits to read
			begin
				rbit_counter <= rbit_counter - 1'b1;
				rstate <= sr_rec_bit;
			end
			rcounter16 <= 0;
		end
		// for 8bits mode
		// at (T+145),   enter this state
		// at (T+145+d), rcounter16 is 0xF
		// at (T+146+d), rcounter16 is 0xE
		// at (T+147+d), rcounter16 is 0xD
		// at (T+148+d), rcounter16 is 0xC
		// at (T+149+d), rcounter16 is 0xB
		// at (T+150+d), rcounter16 is 0xA
		// at (T+151+d), rcounter16 is 0x9
		// at (T+152),   rcounter16 is sampled as 0x9
		//		 sample the parity bit
		// at (T+152+d), rcounter16 is 0x8
		sr_rec_parity: begin
			if (~|rcounter16)
			begin
				rcounter16 <= 4'b1111;
			end
			else
			if (rcounter16 == 4'b1001)
			begin
				rparity <= srx_pad_i; // read the parity bit
				rstate <= sr_calc_parity;
			end
			rcounter16 <= rcounter16 - 1'b1;
		end
		// at (T+153),   enter this state
		// at (T+153+d), rcounter16 is 0x7
		sr_calc_parity : begin
			// rshift[0]^rshift[1]^rshift[2]...^rshift[7]^rparity
			rparity_xor	<= ^{rshift,rparity}; // calculate parity on all incoming data
			rstate		<= sr_check_parity;
			rcounter16	<= rcounter16 - 1'b1;
		end
		// at (T+154),   enter this state
		// at (T+154+d), rcounter16 is 0x6
		sr_check_parity: begin
			case ({lcr[`UART_LC_EP],lcr[`UART_LC_SP]})
				// odd parity, the calculated parity value should be 1
				2'b00: rparity_error <=  rparity_xor == 0;	// no error if parity 1
				// stick parity high at 1
				2'b01: rparity_error <= ~rparity;		// parity should sticked to 1
				// even parity, the calculated parity value should be 0
				2'b10: rparity_error <=  rparity_xor == 1;	// error if parity is odd
				// stick parity low at 0
				2'b11: rparity_error <=  rparity;		// parity should be sticked to 0
			endcase
			rstate <= sr_wait1;
			rcounter16 <= rcounter16 - 1'b1;
		end
		// at (T+155),   enter this state
		// at (T+155+d), rcounter16 is 0x5
		// at (T+156+d), rcounter16 is 0x4
		// at (T+157+d), rcounter16 is 0x3
		// at (T+158+d), rcounter16 is 0x2
		// at (T+159+d), rcounter16 is 0x1
		// at (T+160+d), rcounter16 is 0x0
		sr_wait1: begin
			if (rcounter16 == 4'b0000)
			begin
				rstate <= sr_rec_stop;
				rcounter16 <= 4'b0000;
			end
			else
			begin
				rcounter16 <= rcounter16 - 1'b1;
			end
		end
		// if no parity
		// at (T+145),   enter this state
		// at (T+145+d), rcounter16 is 0xF
		// at (T+146+d), rcounter16 is 0xE
		// at (T+147+d), rcounter16 is 0xD
		// at (T+148+d), rcounter16 is 0xC
		// at (T+149+d), rcounter16 is 0xB
		// at (T+150+d), rcounter16 is 0xA
		// at (T+151+d), rcounter16 is 0x9
		// at (T+152),   rcounter16 is sampled as 0x9
		//
		// if has parity
		// at (T+161),   enter this state
		// at (T+161+d), rcounter16 is 0xF
		// at (T+162+d), rcounter16 is 0xE
		// at (T+163+d), rcounter16 is 0xD
		// at (T+164+d), rcounter16 is 0xC
		// at (T+165+d), rcounter16 is 0xB
		// at (T+166+d), rcounter16 is 0xA
		// at (T+167+d), rcounter16 is 0x9
		// at (T+168),   rcounter16 is sampled as 0x9
		sr_rec_stop: begin
			if (~|rcounter16) // rcounter16 == 0
			begin
				rcounter16 <= 4'b1111;
			end
			else
			if (rcounter16 == 4'b1001) // read the stop bit
			begin
				// check frame error here
				// framing error if the stop bit is 0
				// if srx_pad_i is 0 ==> error
				// if srx_pad_i is 1 ==> ok
				rframing_error <= !srx_pad_i;
				rstate <= sr_push;
			end
			else
			begin
				rcounter16 <= rcounter16 - 1'b1;
			end
		end
		// if no parity
		// at (T+153), enter this state
		// push data into fifo
		// at (T+154), go to sr_idle state
		//
		// if has parity
		// at (T+167), enter this state
		// at (T+168), go to sr_idle state
		sr_push: begin
			// srx_pad_i == 1, break_error == 0 or break_error == 1
			// srx_pad_i == 0, break_error == 1
			if (srx_pad_i | break_error)
			begin
				if (break_error)
					rf_data_in <= {8'b0, 3'b100}; // break input (empty character) to receiver FIFO
				else
					rf_data_in <= {rshift, 1'b0, rparity_error, rframing_error};
				rf_push <= 1'b1;
				rstate <= sr_idle;
			end
			// srx_pad_i == 0, break_error == 0, rframing_error == 0
			else if (~rframing_error)
			begin
				rf_data_in <= {rshift, 1'b0, rparity_error, rframing_error};
				rf_push <= 1'b1;
				rstate <= sr_rec_start;
				rcounter16 <= 0;
			end
			// srx_pad_i == 0, break_error == 0, rframing_error == 1
			// wait for (break_error == 1) or (srx_pad_i == 1)
		end
		default: rstate <= sr_idle;
		endcase
	end  // if (baud_pulse)
end // always of receiver

always @(posedge clk or posedge rst)
begin
	if (rst)
		rf_push_q <= 0;
	else
		rf_push_q <= rf_push; // sample push signal
end

// rising edge detection of rf_push
assign rf_push_pulse = rf_push & ~rf_push_q;

// break condition detection.
// works in conjuction with the receiver state machine
// value to be set to timeout counter
// one data bit costs 16 baud pulse
// in 4X RX transcation period(in baud pulse unit)
reg	[9:0]	toc_value;

always @(lcr)
begin
	case (lcr[3:0])
		// 7 bits	(7*16*4-1)
		// start bit, 5 data bits, 1 stop bit
		4'b0000					: toc_value = 447;
		// 7.5 bits	(7.5*16*4-1)
		// start bit, 5 data bits, 1.5 stop bit
		4'b0100					: toc_value = 479;
		// 8 bits	(8*16*4-1)
		// start bit, 6 data bits, 2 stop bits
		// start bit, 5 data bits, parity bit, 1 stop bit
		4'b0001, 4'b1000			: toc_value = 511;
		// 8.5 bits	(8.5*16*4-1)
		// start bit, 5 data bits, parity bit, 1.5 stop bit
		4'b1100					: toc_value = 543;
		// 9 bits	(9*16*4-1)
		// start bit, 7 data bits, 1 stop bit
		// start bit, 6 data bits, 2 stop bits
		// start bit, 6 data bits, parity bit, parity bit, stop bit
		4'b0010, 4'b0101, 4'b1001		: toc_value = 575;
		// 10 bits	(10*16*4-1)
		// start bit, 8 data bits, 1 stop bit
		// start bit, 7 data bits, 2 stop bits
		// start bit, 7 data bits, parity bit, 1 stop bit
		// start bit, 6 data bits, parity bit, 2 stop bits
		4'b0011, 4'b0110, 4'b1010, 4'b1101	: toc_value = 639;
		// 11 bits	(11*16*4-1)
		// start bit, 8 data bits, 2 stop bits, 1 stop bit
		// start bit, 8 data bits, parity bit, 1 stop bit
		// start bit, 7 data bits, parity bit, 2 stop bit
		4'b0111, 4'b1011, 4'b1110		: toc_value = 703;
		// 12 bits	(12*16*4-1)
		// start bit, 8 data bits, parity bit, 2 stop bit
		4'b1111					: toc_value = 767;
	endcase // case(lcr[3:0])
end

wire	[7:0]	brc_value; // value to be set to break counter
// brc_value = (toc_value >> 2)
// for lcr[3:0] is 0x0000
// the total transaction cost is 7*16 baud pulse, which is toc_value[9:2]
assign brc_value = toc_value[9:2]; // the same as timeout but is 1 insead of 4 character times

// during the RX transaction,
// if srx_pad_i is always 0
// the counter_b will be decreased to 0,
// this will trigger break_error signal
always @(posedge clk or posedge rst)
begin
	if (rst)
		counter_b <= 8'd159; // 10 bits RX transaction period
	else
	begin
		if (srx_pad_i) // if srx_pad_i is 1
			counter_b <= brc_value;
		else // srx_pad_i is 0
		begin
			// at baud pulse stage
			if (baud_pulse & counter_b != 8'b0) // only work on baud_pulse times break not reached.
				counter_b <= counter_b - 1; // decrease break counter
		end
	end
end // always of break condition detection

// Timeout condition detection
// in 4X RX transcation period(in baud pulse unit), if fifo has no activity,
// counter_t will be decreased to zero
reg	[9:0]	counter_t; // counts the timeout condition clocks

always @(posedge clk or posedge rst)
begin
	if (rst)
		counter_t <= 10'd639; // 10 bits RX transaction period * 4
	else
	begin
		// counter is reset when RX FIFO is empty,
		// accessed or above trigger level
		if (rf_push_pulse || rf_pop || rf_count == 0)
			counter_t <= toc_value;
		else
		begin
			if (baud_pulse && counter_t != 10'b0) // we don't want to underflow
				counter_t <= counter_t - 1;
		end
	end
end

endmodule
