//////////////////////////////////////////////////////////////////////
////                                                              ////
////  uart_wb.v                                                   ////
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
////  UART core WISHBONE interface.                               ////
////                                                              ////
////  Known problems (limits):                                    ////
////  Inserts one wait state on all transfers.                    ////
////  Note affected signals and the way they are affected.        ////
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
// Revision 1.16  2002/07/29 21:16:18  gorban
// The uart_defines.v file is included again in sources.
//
// Revision 1.15  2002/07/22 23:02:23  gorban
// Bug Fixes:
//  * Possible loss of sync and bad reception of stop bit on slow baud rates fixed.
//  Problem reported by Kenny.Tung.
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
// Revision 1.12  2001/12/19 08:03:34  mohor
// Warnings cleared.
//
// Revision 1.11  2001/12/06 14:51:04  gorban
// Bug in LSR[0] is fixed.
// All WISHBONE signals are now sampled, so another wait-state is introduced on all transfers.
//
// Revision 1.10  2001/12/03 21:44:29  gorban
// Updated specification documentation.
// Added full 32-bit data bus interface, now as default.
// Address is 5-bit wide in 32-bit data bus mode.
// Added wb_sel_i input to the core. It's used in the 32-bit mode.
// Added debug interface with two 32-bit read-only registers in 32-bit mode.
// Bits 5 and 6 of LSR are now only cleared on TX FIFO write.
// My small test bench is modified to work with 32-bit mode.
//
// Revision 1.9  2001/10/20 09:58:40  gorban
// Small synopsis fixes
//
// Revision 1.8  2001/08/24 21:01:12  mohor
// Things connected to parity changed.
// Clock devider changed.
//
// Revision 1.7  2001/08/23 16:05:05  mohor
// Stop bit bug fixed.
// Parity bug fixed.
// WISHBONE read cycle bug fixed,
// OE indicator (Overrun Error) bug fixed.
// PE indicator (Parity Error) bug fixed.
// Register read bug fixed.
//
// Revision 1.4  2001/05/31 20:08:01  gorban
// FIFO changes and other corrections.
//
// Revision 1.3  2001/05/21 19:12:01  gorban
// Corrected some Linter messages.
//
// Revision 1.2  2001/05/17 18:34:18  gorban
// First 'stable' release. Should be sythesizable now. Also added new header.
//
// Revision 1.0  2001-05-17 21:27:13+02  jacob
// Initial revision
//
//

// UART core WISHBONE interface
//
// Author: Jacob Gorban (jacob.gorban@flextronicssemi.com)
// Company: Flextronics Semiconductor
//

`include "uart_defines.v"

module uart_wb(
	clk,
	rst,
	wb_we_i,
	wb_stb_i,
	wb_cyc_i,
	wb_ack_o,
	wb_adr_i,
	wb_dat_i,
	wb_dat_o,
	wb_sel_i,
	uart_adr_o,
	uart_dat8_i,
	uart_dat8_o,
	uart_we_o,
	uart_re_o // write and read enable output for the core
);

input		clk;
input		rst;

// WISHBONE interface
input		wb_we_i; // from master
input		wb_stb_i; // from master
input		wb_cyc_i; // from master
input	[3:0]	wb_sel_i; // from master
// UART_ADDR_WIDTH: 3 if DATA_BUS_WIDTH is 8
// UART_ADDR_WIDTH: 5 if DATA_BUS_WIDTH is 32
input	[`UART_ADDR_WIDTH-1:0]	wb_adr_i; // WISHBONE address line

`ifdef DATA_BUS_WIDTH_8
input	[7:0]	wb_dat_i; // from master
wire	[7:0]	wb_dat_i; // from master
reg	[7:0]	wb_dat_is; // sampled wb_dat_i
output	[7:0]	wb_dat_o; // to master
reg	[7:0]	wb_dat_o; // to master
`else // for 32 data bus mode
input	[31:0]	wb_dat_i; // from master
wire	[31:0]	wb_dat_i; // from master
reg	[31:0]	wb_dat_is; // sampled wb_dat_i
output	[31:0]	wb_dat_o; // to master
reg	[31:0]	wb_dat_o; // to master
`endif // !`ifdef DATA_BUS_WIDTH_8
wire	[3:0]	wb_sel_i; // from master

output	[`UART_ADDR_WIDTH-1:0]	uart_adr_o; // addr to uart_regs module
wire	[`UART_ADDR_WIDTH-1:0]	uart_adr_o; // to the wb_addr_i of uart_regs module
input	[7:0]	uart_dat8_i; // from uart_dat_o of uart_regs module, data from uart_regs
wire	[7:0]	uart_dat8_i; // this data will be sampled and put into wb_dat_o to master
output	[7:0]	uart_dat8_o; // sampled wb_dat_is
reg	[7:0]	uart_dat8_o; // to uart_dat_i of uart_regs module, data to uart_regs
output		wb_ack_o; // to master
reg		wb_ack_o;
output		uart_we_o; // to uart_regs module, write signal
wire		uart_we_o;
output		uart_re_o; // to uart_regs module, read signal
wire		uart_re_o;

reg	[`UART_ADDR_WIDTH-1:0]	wb_adr_is; // sampled wb_adr_i
reg				wb_we_is;  // sampled wb_we_i
reg				wb_cyc_is; // sampled wb_cyc_i
reg				wb_stb_is; // sampled wb_stb_i
reg	[3:0]			wb_sel_is; // sampled wb_sel_i

// wre: 0 ==> there is active read or write operation
// wre: 1 ==> can do read/write
reg				wre; // timing control signal for write or read enable

// wb_ack_o FSM
// all uart operations are doing register operations
// no wait, so ack can be issued quickly.
reg	[1:0]	wbstate;
always @(posedge clk or posedge rst)
begin
	if (rst)
	begin
		wre		<= 1;
		wbstate		<= 0;
		wb_ack_o	<= 0;
	end
	else
	begin
		// T-d:    wb_stb_i(1) && wb_cyc_i(1)
		// T+0:    assign wb_stb_is, wb_cyc_is
		// T+d:    wb_stb_is(1), wb_cyc_is(1)
		// T+1:    at wbstate 0, assign wre, wbstate, wb_ack_o
		// T+1+d:  wre(0), wbstate(1), wb_ack_o(1)
		// T+2:    at wbstate 1, assign wre, wbstate, wb_ack_o
		// T+2+d:  wre(0), wbstate(2), wb_ack_o(0)
		// T+3:    at wbstate 2, assign wre, wbstate, wb_ack_o
		// T+3+d:  wre(1), wbstate(0), wb_ack_o(0)
		// T+4:    at wbstate 0,
		//         check wb_stb_is && wb_cyc_is and
		//         assign wre, wbstate, wb_ack_o
		// T+4+d:  if (wb_stb_is(1) && wb_cyc_is(1)
		//             wre(0), wbstate(1), wb_ack_o(1)
		//         else
		//             wre(1), wbstate(0), wb_ack_o(0)
		// ==========
		// T-d:    master initiates a transfer
		// T+0:    this module receives the request
		// T+d:    all data && signals are forwarded to uart_regs module
		// T+1:    enter wbstate 0
		// T+1+d:  ack signal is up
		// T+2:    enter wbstate 1; the master will receive ack signal
		// T+2+d:  ack signal is down
		// T+3:    enter wbstate 2;
		// T+4:    enter wbstate 0
		case (wbstate)
			0: begin
				if (wb_stb_is & wb_cyc_is) begin
					wre		<= 0;
					wbstate		<= 1;
					wb_ack_o	<= 1;
				end else begin
					wre		<= 1;
					wbstate		<= 0;
					wb_ack_o	<= 0;
				end
			end
			1: begin
				wre		<= 0;
				wbstate		<= 2;
				wb_ack_o	<= 0;
			end
			2,3: begin
				wre		<= 1;
				wbstate		<= 0;
				wb_ack_o	<= 0;
			end
		endcase
	end
end

// wb_we_is is TRUE  ==> write cycle
// wb_we_is is FALSE ==> read cycle
// T-d: master initiates a transfer
// T+0: this module receives the request
// T+d: wb_we_is, wb_stb_is, wb_cyc_is, uart_we_o, uart_re_o are updated (all to high)
// T+1+d: uart_we_o, uart_re_o are updated (to low)
assign uart_we_o =  wb_we_is & wb_stb_is & wb_cyc_is & wre ; // WRITE for registers
assign uart_re_o = ~wb_we_is & wb_stb_is & wb_cyc_is & wre ; // READ for registers

// Sample input signals
always @(posedge clk or posedge rst)
begin
	if (rst)
	begin
		wb_adr_is <= 0;
		wb_we_is  <= 0;
		wb_cyc_is <= 0;
		wb_stb_is <= 0;
		wb_dat_is <= 0;
		wb_sel_is <= 0;
	end
	else
	begin
		// T-d: master initiates a transfer
		// T+0: do sample
		// T+d: variables are updated
		wb_adr_is <= wb_adr_i;
		wb_we_is  <= wb_we_i;
		wb_cyc_is <= wb_cyc_i;
		wb_stb_is <= wb_stb_i;
		wb_dat_is <= wb_dat_i;
		wb_sel_is <= wb_sel_i;
	end
end

`ifdef DATA_BUS_WIDTH_8 // 8-bit data bus
always @(posedge clk or posedge rst)
begin
	if (rst)
		wb_dat_o <= 0;
	else
		wb_dat_o <= uart_dat8_i;
end

always @(wb_dat_is)
	uart_dat8_o = wb_dat_is;

assign uart_adr_o = wb_adr_is;

`else // 32-bit bus
// put output to the correct byte in 32 bits using select line
always @(posedge clk or posedge rst)
begin
	if (rst)
		wb_dat_o <= 0;
	else if (uart_re_o)
	begin
		case (wb_sel_is)
			// T-d:   master initiates a transfer
			// T+0:   wb_sel_is is sampled
			// T+d:   wb_sel_is is updated
			// T+1:   enter here, do sample
			// T+1+d: wb_dat_o is updated
			4'b0001: wb_dat_o <= {24'b0, uart_dat8_i};
			4'b0010: wb_dat_o <= {16'b0, uart_dat8_i,  8'b0};
			4'b0100: wb_dat_o <= { 8'b0, uart_dat8_i, 16'b0};
			4'b1000: wb_dat_o <= {uart_dat8_i, 24'b0};
 			default: wb_dat_o <= 0;
		endcase // case(wb_sel_i)
	end
end

// in 32bit data bus with 8bit granularity
// only use the 32bit alignment part of wb_adr_i
// the offset within the 32bit alignment part is from wb_sel_i
// BIG endian: (the most significant data byte is stored at the lowest addr)
//   program wirte 0xff at 0x90000003
//   wb_adr_i: 0x90000003
//   wb_dat_i: 0x000000ff
//   wb_sel_i: 4b'0001
//     wb_dat_i[7:0]	the data for 0x90000003, wb_sel_i: 4b'0001
//     wb_dat_i[15:8]	the data for 0x90000002, wb_sel_i: 4b'0010
//     wb_dat_i[23:16]	the data for 0x90000001, wb_sel_i: 4b'0100
//     wb_dat_i[31:24]	the data for 0x90000000, wb_sel_i: 4b'1000
//
// LITTLE endian: (the most significant data byte is stored at the highest addr)
//   program wirte 0xff at 0x90000003
//   wb_adr_i: 0x90000003
//   wb_dat_i: 0xff000000
//   wb_sel_i: 4b'1000
//     wb_dat_i[7:0]	the data for 0x90000000, wb_sel_i: 4b'0001
//     wb_dat_i[15:8]	the data for 0x90000001, wb_sel_i: 4b'0010
//     wb_dat_i[23:16]	the data for 0x90000002, wb_sel_i: 4b'0100
//     wb_dat_i[31:24]	the data for 0x90000003, wb_sel_i: 4b'1000
//
reg [1:0] wb_adr_lsb;

always @(wb_sel_is or wb_dat_is)
begin
	case (wb_sel_is)
		// T-d:   master initiates a transfer
		// T+0:   wb_sel_is is sampled
		// T+d:   wb_sel_is is updated
		// T+d:   enter here, uart_dat8_o is updated according to wb_sel_is
		4'b0001 : uart_dat8_o = wb_dat_is[7:0];
		4'b0010 : uart_dat8_o = wb_dat_is[15:8];
		4'b0100 : uart_dat8_o = wb_dat_is[23:16];
		4'b1000 : uart_dat8_o = wb_dat_is[31:24];
		default : uart_dat8_o = wb_dat_is[7:0];
	endcase // case(wb_sel_i)
  `ifdef LITTLE_ENDIAN
	case (wb_sel_is)
		4'b0001 : wb_adr_lsb = 2'h0;
		4'b0010 : wb_adr_lsb = 2'h1;
		4'b0100 : wb_adr_lsb = 2'h2;
		4'b1000 : wb_adr_lsb = 2'h3;
		default : wb_adr_lsb = 2'h0;
	endcase // case(wb_sel_i)
  `else
	case (wb_sel_is)
		4'b0001 : wb_adr_lsb = 2'h3;
		4'b0010 : wb_adr_lsb = 2'h2;
		4'b0100 : wb_adr_lsb = 2'h1;
		4'b1000 : wb_adr_lsb = 2'h0;
		default : wb_adr_lsb = 2'h0;
	endcase // case(wb_sel_i)
  `endif
end

// {wb_adr_is[4:2], wb_adr_lsb}
assign uart_adr_o = {wb_adr_is[`UART_ADDR_WIDTH-1:2], wb_adr_lsb};

`endif // !`ifdef DATA_BUS_WIDTH_8

endmodule
