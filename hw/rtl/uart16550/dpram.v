//////////////////////////////////////////////////////////////////////
////                                                              ////
////  dpram.v                                                     ////
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
////  Inferrable Distributed RAM for FIFOs                        ////
////                                                              ////
////  Known problems (limits):                                    ////
////  None                .                                       ////
////                                                              ////
////  To Do:                                                      ////
////  Nothing so far.                                             ////
////                                                              ////
////  Author(s):                                                  ////
////      - gorban@opencores.org                                  ////
////      - Jacob Gorban                                          ////
////                                                              ////
////  Created:        2002/07/22                                  ////
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

`define DATA_FF_OUT

// Following is the Verilog code for a dual-port RAM with asynchronous read.
module dpram(
	clk,
	wen,
	waddr,
	raddr,
	data_in,
	data_out
);

parameter ADDR_WIDTH	= 4; // DEPTH = 2^ADDR_WIDTH
parameter DATA_WIDTH	= 8; // width of every ram element
parameter DEPTH		= 16; // numbers of ram element

input	clk;
input	wen; // write enable
input	[ADDR_WIDTH-1:0] waddr; // write addr
input	[ADDR_WIDTH-1:0] raddr; // read addr
input	[DATA_WIDTH-1:0] data_in; // data in
output	[DATA_WIDTH-1:0] data_out; // data out
reg	[DATA_WIDTH-1:0] ram [DEPTH-1:0]; // ram instance

`ifdef DATA_FF_OUT
reg	[DATA_WIDTH-1:0] data_out;
`else
wire	[DATA_WIDTH-1:0] data_out;
`endif
wire	[DATA_WIDTH-1:0] data_in;
wire	[ADDR_WIDTH-1:0] waddr;
wire	[ADDR_WIDTH-1:0] raddr;

always @(posedge clk)
	if (wen) ram[waddr] <= data_in; // write operation

`ifdef DATA_FF_OUT
always @(posedge clk)
	data_out <= ram[raddr];
`else
assign data_out = ram[raddr]; // read operation
`endif

endmodule
