//////////////////////////////////////////////////////////////////////
////                                                              ////
////  uart_tfifo.v                                                ////
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
////  UART core transmitter FIFO                                  ////
////                                                              ////
////  To Do:                                                      ////
////  Nothing.                                                    ////
////                                                              ////
////  Author(s):                                                  ////
////      - gorban@opencores.org                                  ////
////      - Jacob Gorban                                          ////
////      - Igor Mohor (igorm@opencores.org)                      ////
////                                                              ////
////  Created:        2001/05/12                                  ////
////  Last Updated:   2002/07/22                                  ////
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
// Revision 1.1  2002/07/22 23:02:23  gorban
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
// Revision 1.16  2001/12/20 13:25:46  mohor
// rx push changed to be only one cycle wide.
//
// Revision 1.15  2001/12/18 09:01:07  mohor
// Bug that was entered in the last update fixed (rx state machine).
//
// Revision 1.14  2001/12/17 14:46:48  mohor
// overrun signal was moved to separate block because many sequential lsr
// reads were preventing data from being written to rx fifo.
// underrun signal was not used and was removed from the project.
//
// Revision 1.13  2001/11/26 21:38:54  gorban
// Lots of fixes:
// Break condition wasn't handled correctly at all.
// LSR bits could lose their values.
// LSR value after reset was wrong.
// Timing of THRE interrupt signal corrected.
// LSR bit 0 timing corrected.
//
// Revision 1.12  2001/11/08 14:54:23  mohor
// Comments in Slovene language deleted, few small fixes for better work of
// old tools. IRQs need to be fix.
//
// Revision 1.11  2001/11/07 17:51:52  gorban
// Heavily rewritten interrupt and LSR subsystems.
// Many bugs hopefully squashed.
//
// Revision 1.10  2001/10/20 09:58:40  gorban
// Small synopsis fixes
//
// Revision 1.9  2001/08/24 21:01:12  mohor
// Things connected to parity changed.
// Clock devider changed.
//
// Revision 1.8  2001/08/24 08:48:10  mohor
// FIFO was not cleared after the data was read bug fixed.
//
// Revision 1.7  2001/08/23 16:05:05  mohor
// Stop bit bug fixed.
// Parity bug fixed.
// WISHBONE read cycle bug fixed,
// OE indicator (Overrun Error) bug fixed.
// PE indicator (Parity Error) bug fixed.
// Register read bug fixed.
//
// Revision 1.3  2001/05/31 20:08:01  gorban
// FIFO changes and other corrections.
//
// Revision 1.3  2001/05/27 17:37:48  gorban
// Fixed many bugs. Updated spec. Changed FIFO files structure. See CHANGES.txt file.
//
// Revision 1.2  2001/05/17 18:34:18  gorban
// First 'stable' release. Should be sythesizable now. Also added new header.
//
// Revision 1.0  2001-05-17 21:27:12+02  jacob
// Initial revision
//
//

`include "uart_defines.v"

module uart_tfifo(
	clk,
	rst,
	data_in,
	data_out,
	// Control signals
	push, // push strobe, active high, one clk pulse
	pop, // pop strobe, active high, one clk pulse
	// status signals
	overrun,
	count,
	fifo_reset,
	// lsr_mask from uart_regs.v
	reset_status
);

// FIFO parameters
parameter FIFO_WIDTH		= `UART_FIFO_WIDTH; // 8
parameter FIFO_DEPTH		= `UART_FIFO_DEPTH; // 16
parameter FIFO_POINTER_W	= `UART_FIFO_POINTER_W; // fifo pointer width, 4
parameter FIFO_COUNTER_W	= `UART_FIFO_COUNTER_W; // fifo couner width, 5

input				clk;
input				rst;
// push is high when UART_TX register is written
input				push;
// pop is high only when count > 0
input				pop;
input	[FIFO_WIDTH-1:0]	data_in; // data from CPU
input				fifo_reset; // wptr, rptr, count and overrun are all reset
input				reset_status; // only reset overrun

output	[FIFO_WIDTH-1:0]	data_out; // data from tx fifo sram, to uart_transmitter
output				overrun;
output	[FIFO_COUNTER_W-1:0]	count;

wire	[FIFO_WIDTH-1:0]	data_out;

// FIFO pointers
reg	[FIFO_POINTER_W-1:0]	wptr; // the position to write
reg	[FIFO_POINTER_W-1:0]	rptr; // the position to read

reg	[FIFO_COUNTER_W-1:0]	count;
reg				overrun;

wire				full;
wire				empty;

// top always points to an empty location for push new data
// bottom always points to an exist data
dpram #(FIFO_POINTER_W,FIFO_WIDTH,FIFO_DEPTH) tfifo
(
	.clk(clk),
	.wen(push),
	.waddr(wptr),
	.raddr(rptr),
	.data_in(data_in),
	.data_out(data_out)
);

always @(posedge clk or posedge rst) // synchronous FIFO
begin
	if (rst)
	begin
		wptr		<= 0;
		rptr		<= 0;
		count		<= 0;
	end
	else
	if (fifo_reset) begin
		wptr		<= 0;
		rptr		<= 0;
		count		<= 0;
	end
	else
	begin
		case ({push, pop})
		2'b10 :
		begin
			if (~full) // not full
			begin
				// advance write pointer for next write, be effective at next clk
				wptr	<= wptr + 1'b1;
				count	<= count + 1'b1;
			end
		end
		2'b01 :
		begin
			if (~empty) // not empty
			begin
				// advance read pointer for next read, be effective at next clk
				rptr	<= rptr + 1'b1;
				count	<= count - 1'b1;
			end
		end
		2'b11 :
		begin
			if (~full) // not full
			begin
				wptr <= wptr + 1'b1;
				if (empty) // if fifo is empty, only push can be done
					count <= count + 1'b1;
			end
			if (~empty) // not empty
			begin
				rptr <= rptr + 1'b1;
				if (full) // if fifo is full, only pop can be done
					count <= count - 1'b1;
			end
		end
		default: ; // do nothing when {2'b00}
		endcase
	end
end // always

always @(posedge clk or posedge rst) // synchronous FIFO
begin
	if (rst)
		overrun <= 1'b0;
	else
	if (fifo_reset | reset_status)
		overrun <= 1'b0;
	else
	// want to push and the fifo is full
	if (push & ~pop & full)
		overrun <= 1'b1;
end // always

assign full = (count == FIFO_DEPTH);
assign empty = (count == 0);

endmodule
