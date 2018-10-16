//////////////////////////////////////////////////////////////////////
////                                                              ////
////  uart_regs.v                                                 ////
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
////  Registers of the uart 16550 core                            ////
////                                                              ////
////  Known problems (limits):                                    ////
////  Inserts 1 wait state in all WISHBONE transfers              ////
////                                                              ////
////  To Do:                                                      ////
////  Nothing or verification.                                    ////
////                                                              ////
////  Author(s):                                                  ////
////      - gorban@opencores.org                                  ////
////      - Jacob Gorban                                          ////
////      - Igor Mohor (igorm@opencores.org)                      ////
////                                                              ////
////  Created:        2001/05/12                                  ////
////  Last Updated:   (See log for the revision history           ////
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
// Revision 1.41  2004/05/21 11:44:41  tadejm
// Added synchronizer flops for RX input.
//
// Revision 1.40  2003/06/11 16:37:47  gorban
// This fixes errors in some cases when data is being read and put to
// the FIFO at the same time. Patch is submitted by Scott Furman.
// Update is very recommended.
//
// Revision 1.39  2002/07/29 21:16:18  gorban
// The uart_defines.v file is included again in sources.
//
// Revision 1.38  2002/07/22 23:02:23  gorban
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
// Revision 1.37  2001/12/27 13:24:09  mohor
// lsr[7] was not showing overrun errors.
//
// Revision 1.36  2001/12/20 13:25:46  mohor
// rx push changed to be only one cycle wide.
//
// Revision 1.35  2001/12/19 08:03:34  mohor
// Warnings cleared.
//
// Revision 1.34  2001/12/19 07:33:54  mohor
// Synplicity was having troubles with the comment.
//
// Revision 1.33  2001/12/17 10:14:43  mohor
// Things related to msr register changed. After THRE IRQ occurs, and one
// character is written to the transmit fifo, the detection of the THRE bit in the
// LSR is delayed for one character time.
//
// Revision 1.32  2001/12/14 13:19:24  mohor
// MSR register fixed.
//
// Revision 1.31  2001/12/14 10:06:58  mohor
// After reset modem status register MSR should be reset.
//
// Revision 1.30  2001/12/13 10:09:13  mohor
// thre irq should be cleared only when being source of interrupt.
//
// Revision 1.29  2001/12/12 09:05:46  mohor
// LSR status bit 0 was not cleared correctly in case of reseting the FCR (rx fifo).
//
// Revision 1.28  2001/12/10 19:52:41  gorban
// Scratch register added
//
// Revision 1.27  2001/12/06 14:51:04  gorban
// Bug in LSR[0] is fixed.
// All WISHBONE signals are now sampled, so another wait-state is introduced on all transfers.
//
// Revision 1.26  2001/12/03 21:44:29  gorban
// Updated specification documentation.
// Added full 32-bit data bus interface, now as default.
// Address is 5-bit wide in 32-bit data bus mode.
// Added wb_sel_i input to the core. It's used in the 32-bit mode.
// Added debug interface with two 32-bit read-only registers in 32-bit mode.
// Bits 5 and 6 of LSR are now only cleared on TX FIFO write.
// My small test bench is modified to work with 32-bit mode.
//
// Revision 1.25  2001/11/28 19:36:39  gorban
// Fixed: timeout and break didn't pay attention to current data format when counting time
//
// Revision 1.24  2001/11/26 21:38:54  gorban
// Lots of fixes:
// Break condition wasn't handled correctly at all.
// LSR bits could lose their values.
// LSR value after reset was wrong.
// Timing of THRE interrupt signal corrected.
// LSR bit 0 timing corrected.
//
// Revision 1.23  2001/11/12 21:57:29  gorban
// fixed more typo bugs
//
// Revision 1.22  2001/11/12 15:02:28  mohor
// lsr1r error fixed.
//
// Revision 1.21  2001/11/12 14:57:27  mohor
// ti_int_pnd error fixed.
//
// Revision 1.20  2001/11/12 14:50:27  mohor
// ti_int_d error fixed.
//
// Revision 1.19  2001/11/10 12:43:21  gorban
// Logic Synthesis bugs fixed. Some other minor changes
//
// Revision 1.18  2001/11/08 14:54:23  mohor
// Comments in Slovene language deleted, few small fixes for better work of
// old tools. IRQs need to be fix.
//
// Revision 1.17  2001/11/07 17:51:52  gorban
// Heavily rewritten interrupt and LSR subsystems.
// Many bugs hopefully squashed.
//
// Revision 1.16  2001/11/02 09:55:16  mohor
// no message
//
// Revision 1.15  2001/10/31 15:19:22  gorban
// Fixes to break and timeout conditions
//
// Revision 1.14  2001/10/29 17:00:46  gorban
// fixed parity sending and tx_fifo resets over- and underrun
//
// Revision 1.13  2001/10/20 09:58:40  gorban
// Small synopsis fixes
//
// Revision 1.12  2001/10/19 16:21:40  gorban
// Changes data_out to be synchronous again as it should have been.
//
// Revision 1.11  2001/10/18 20:35:45  gorban
// small fix
//
// Revision 1.10  2001/08/24 21:01:12  mohor
// Things connected to parity changed.
// Clock devider changed.
//
// Revision 1.9  2001/08/23 16:05:05  mohor
// Stop bit bug fixed.
// Parity bug fixed.
// WISHBONE read cycle bug fixed,
// OE indicator (Overrun Error) bug fixed.
// PE indicator (Parity Error) bug fixed.
// Register read bug fixed.
//
// Revision 1.10  2001/06/23 11:21:48  gorban
// DL made 16-bit long. Fixed transmission/reception bugs.
//
// Revision 1.9  2001/05/31 20:08:01  gorban
// FIFO changes and other corrections.
//
// Revision 1.8  2001/05/29 20:05:04  gorban
// Fixed some bugs and synthesis problems.
//
// Revision 1.7  2001/05/27 17:37:49  gorban
// Fixed many bugs. Updated spec. Changed FIFO files structure. See CHANGES.txt file.
//
// Revision 1.6  2001/05/21 19:12:02  gorban
// Corrected some Linter messages.
//
// Revision 1.5  2001/05/17 18:34:18  gorban
// First 'stable' release. Should be sythesizable now. Also added new header.
//
// Revision 1.0  2001-05-17 21:27:11+02  jacob
// Initial revision
//
//

`include "uart_defines.v"

`define UART_DLL 7:0  // for dlv[7:0]
`define UART_DLM 15:8 // for dlv[15:8]

module uart_regs(
	clk,
	rst,
	uart_adr_i,
	uart_dat_i,
	uart_dat_o,
	uart_we_i,
	uart_re_i,
	// additional signals
	stx_pad_o,
	srx_pad_i,
	int_o
);

input					clk;
input					rst;
input	[`UART_ADDR_WIDTH-1:0]		uart_adr_i;
input	[7:0]				uart_dat_i;
output	[7:0]				uart_dat_o;
input					uart_we_i;
input					uart_re_i;

output					stx_pad_o;
input					srx_pad_i;

output					int_o;

reg					baud_pulse;

wire					stx_pad_o; // TX output pad
wire					srx_pad_i; // RX input pad
wire					serial_in; // sampled RX input
wire					serial_out; // TX output bit

reg	[7:0]				uart_dat_o;

wire	[`UART_ADDR_WIDTH-1:0]		uart_adr_i;
wire	[7:0]				uart_dat_i;

reg	[3:0]				ier;
reg	[3:0]				iir;
reg	[1:0]				fcr; // bits 7 and 6 of fcr. Other bits are ignored
reg	[7:0]				lcr;
reg	[15:0]				dlv; // divisor latch (clk/16*baud_rate)
reg	[7:0]				scratch; // UART scratch register
reg					start_dlc; // activate dlc on writing to UART_DLL
reg					lsr_mask_d; // delayed lsr_mask_condition
reg	[15:0]				dlc; // divisor latch counter
reg					int_o;

reg	[3:0]				trigger_level; // trigger level of the receiver FIFO
reg					rx_reset;
reg					tx_reset;

wire					dlab; // divisor latch access bit

// LSR bits wires and regs
wire	[7:0]				lsr;
wire					lsr0, lsr1, lsr2, lsr3, lsr4, lsr5, lsr6, lsr7;
reg					lsr0r, lsr1r, lsr2r, lsr3r, lsr4r, lsr5r, lsr6r, lsr7r;
wire					lsr_mask; // lsr_mask, the signal to clear error bit

// Interrupt signals
wire					rls_int;  // receiver line status interrupt
wire					rda_int;  // receiver data available interrupt
wire					ti_int;   // timeout indicator interrupt
wire					thre_int; // transmitter holding register empty interrupt

// FIFO signals
reg					tf_push;
reg					rf_pop;
wire	[`UART_FIFO_REC_WIDTH-1:0]	rf_data_out;
wire					rf_error_bit; // an error (parity or framing) is inside the fifo
wire					rf_overrun;
wire					rf_push_pulse;
wire	[`UART_FIFO_COUNTER_W-1:0]	rf_count;
wire	[`UART_FIFO_COUNTER_W-1:0]	tf_count;
wire	[2:0]				tstate; // the state of uart tx statemachine
wire	[3:0]				rstate; // the state of uart rx statemachine
wire	[9:0]				counter_t;

wire					thre_set_en; // THRE status is delayed one character time when a character is written to fifo.
reg	[7:0]				block_cnt;   // While counter counts, THRE status is blocked (delayed one character cycle)
reg	[7:0]				block_value; // One character tx time length (not including stop bit)

assign stx_pad_o = serial_out;

assign dlab = lcr[`UART_LC_DL]; // divisor latch access bit signal

uart_transmitter transmitter(
	.clk			(clk),
	.rst			(rst),
	.lcr			(lcr),
	.tf_push		(tf_push),
	.tf_push_data		(uart_dat_i),
	.baud_pulse		(baud_pulse),
	.stx_pad_o		(serial_out),
	.tstate			(tstate),
	.tf_count		(tf_count),
	.tx_reset		(tx_reset),
	.lsr_mask		(lsr_mask)
);

// Synchronizing and sampling serial RX input
uart_sync_flops i_uart_sync_flops(
	.clk_i			(clk),
	.rst_i			(rst),
	.stage1_rst_i		(1'b0),
	.stage1_clk_en_i	(1'b1),
	.async_dat_i		(srx_pad_i),
	.sync_dat_o		(serial_in)
);
defparam i_uart_sync_flops.width	= 1;
defparam i_uart_sync_flops.init_value	= 1'b1;

uart_receiver receiver(
	.clk			(clk),
	.rst			(rst),
	.lcr			(lcr),
	.rf_pop			(rf_pop),
	.srx_pad_i		(serial_in),
	.baud_pulse		(baud_pulse),
	.counter_t		(counter_t),
	.rf_count		(rf_count),
	.rf_data_out		(rf_data_out),
	.rf_error_bit		(rf_error_bit),
	.rf_overrun		(rf_overrun),
	.rx_reset		(rx_reset),
	.lsr_mask		(lsr_mask),
	.rstate			(rstate),
	.rf_push_pulse		(rf_push_pulse)
);

// Asynchronous reading here because the outputs are sampled in uart_wb.v file
always @(*)
begin
	case (uart_adr_i)
		`UART_REG_RB	: uart_dat_o = dlab ?
					dlv[`UART_DLL]
					:
					rf_data_out[10:3];
		`UART_REG_IE	: uart_dat_o = dlab ? dlv[`UART_DLM] : ier;
		`UART_REG_II	: uart_dat_o = {4'b1100,iir};
		`UART_REG_LC	: uart_dat_o = lcr;
		`UART_REG_LS	: uart_dat_o = lsr;
		`UART_REG_SR	: uart_dat_o = scratch;
		default		: uart_dat_o = 8'b0;
	endcase // case(uart_adr_i)
end // always @ (dlv or dlab or ier or iir or scratch...

// lsr_mask_condition: 1 when reading UART_LSR
wire	lsr_mask_condition;
// iir_read: 1 when reading UART_IIR
wire	iir_read;
// rfifo_read: 1 when reading UART_RX
wire	rfifo_read;
// tfifo_write: 1 when writing UART_TX
wire	tfifo_write;

// when do lsr read, lsr_mask_condition will be 1
assign lsr_mask_condition = (uart_re_i && uart_adr_i == `UART_REG_LS && !dlab);

// when do iir read, iir_read will be 1
assign iir_read = (uart_re_i && uart_adr_i == `UART_REG_II && !dlab);

// do UART RX
assign rfifo_read = (uart_re_i && uart_adr_i == `UART_REG_RB && !dlab);

// do UART TX
assign tfifo_write = (uart_we_i && uart_adr_i == `UART_REG_TR && !dlab);

// rf_pop signal handling
// one clock pulse
always @(posedge clk or posedge rst)
begin
	if (rst)
		rf_pop <= 0;
	else if (rf_pop) // set signal to 0 after one clock cycle
		rf_pop <= 0;
	else if (rfifo_read) // do RBR read
		rf_pop <= 1; // advance read pointer of uart_rfifio
end

// lsr_mask_d delayed signal handling
always @(posedge clk or posedge rst)
begin
	if (rst)
		lsr_mask_d <= 0;
	else // reset bits in the Line Status Register
		lsr_mask_d <= lsr_mask_condition;
end

// lsr_mask is rising edge detection of lsr_mask_condition
// which indicates that LSR is read
// it is the signal to clear error bits (also overrun in RX fifo)
assign lsr_mask = lsr_mask_condition && ~lsr_mask_d;

//
//   WRITES AND RESETS   //
//
// Line Control Register
always @(posedge clk or posedge rst)
begin
	if (rst)
		lcr <= 8'b00000011; // 8n1 setting
	else if (uart_we_i && uart_adr_i==`UART_REG_LC) // do lcr write
		lcr <= uart_dat_i; // update lcr
end

// Interrupt Enable Register or UART_DLM
always @(posedge clk or posedge rst)
begin
	if (rst)
	begin
		ier <= 4'b0000; // no interrupts after reset
		dlv[`UART_DLM] <= 8'b0;
	end
	else if (uart_we_i && uart_adr_i==`UART_REG_IE) // do ier write
	begin
		if (dlab) // do dlab MSB update
			dlv[`UART_DLM] <= uart_dat_i; // update dl MSB
		else // update ier
			ier <= uart_dat_i[3:0]; // ier uses only 4 bits lsb
	end
end

// FIFO Control Register and rx_reset, tx_reset signals
always @(posedge clk or posedge rst)
begin
	if (rst)
	begin
		fcr <= 2'b11; // fifo trigger level, default to 14
		rx_reset <= 0;
		tx_reset <= 0;
	end
	else if (uart_we_i && uart_adr_i==`UART_REG_FC) // do fcr write
	begin
		fcr <= uart_dat_i[7:6]; // update fcr fifo trigger level (FCR[7:6])
		rx_reset <= uart_dat_i[1]; // FCR[1] is RX FIFO CLR
		tx_reset <= uart_dat_i[2]; // FCR[2] is TX FIFO CLR
	end
	else
	begin
		rx_reset <= 0;
		tx_reset <= 0;
	end
end

// Scratch register
always @(posedge clk or posedge rst)
begin
	if (rst)
		scratch <= 0; // 8n1 setting
	else if (uart_we_i && uart_adr_i==`UART_REG_SR) // do sr write
		scratch <= uart_dat_i; // update sr
end

// TX_FIFO or UART_DLL
always @(posedge clk or posedge rst)
begin
	if (rst)
	begin
		dlv[`UART_DLL] <= 8'b0;
		tf_push <= 1'b0;
	end
	else if (uart_we_i && (uart_adr_i == `UART_REG_TR)) // tr write
	begin
		if (dlab) // do dlab LSB update
		begin
			dlv[`UART_DLL] <= uart_dat_i; // update dlab LSB
			tf_push <= 1'b0;
		end
		else // update tr
		begin
			tf_push <= 1'b1; // control signal to uart_transmitter
		end // else: !if (dlab)
	end
	else
	begin
		tf_push <= 1'b0;
	end // else: !if (dlab)
end

// Receiver FIFO trigger level selection logic (asynchronous mux)
always @(fcr)
begin
	case (fcr[`UART_FC_TL])
		2'b00 : trigger_level = 1;
		2'b01 : trigger_level = 4;
		2'b10 : trigger_level = 8;
		2'b11 : trigger_level = 14;
	endcase // case(fcr[`UART_FC_TL])
end

//
//  STATUS REGISTERS  //
//

reg dlab_cfg_done;
reg dlab_cfg_d;

always @(posedge clk or posedge rst)
begin
	if (rst)
		dlab_cfg_d <= 0;
	else
	begin
		dlab_cfg_d <= dlab;
	end
end

always @(posedge clk or posedge rst)
begin
	if (rst)
	begin
		dlab_cfg_done <= 0;
		start_dlc <= 0;
	end
	else
	begin
		start_dlc <= 0;
		if (dlab && ~dlab_cfg_d) // rising edge of dlab
			dlab_cfg_done <= 0;
		else if (~dlab && dlab_cfg_d && |dlv) // falling edge of dlab && (dlv > 0)
		begin
			dlab_cfg_done <= 1;
			start_dlc <= 1;
		end
	end
end

// Line Status Register
assign lsr[7:0] = {lsr7r, lsr6r, lsr5r, lsr4r, lsr3r, lsr2r, lsr1r, lsr0r};

// activation conditions

// data in receiver fifo available set condition
// when rx fifo is from empty to non-empty
assign lsr0 = (rf_count==0 && rf_push_pulse);

// Receiver overrun error
// when rx fifo is full
assign lsr1 = rf_overrun;

// parity error bit
assign lsr2 = rf_data_out[1];

// framing error bit
// when stop bit is not 1
assign lsr3 = rf_data_out[0];

// break error in the character
assign lsr4 = rf_data_out[2];

// tx fifo is empty and
// all data bits are sent out
assign lsr5 = (tf_count==5'b0 && thre_set_en);

// tx fifo is empty and
// all data bits are sent out and
// tx state machine is in IDLE state (this means that the stop bits are also sent out)
assign lsr6 = (tf_count==5'b0 && thre_set_en && (tstate == 0 /* `S_IDLE */));

assign lsr7 = rf_error_bit | rf_overrun;

// lsr bit0 (receiver data available)
reg lsr0_d;

// for rising edge detection of lsr0
// this is the pulse of rx fifo from empty to non-empty
always @(posedge clk or posedge rst)
begin
	if (rst)
		lsr0_d <= 0;
	else
		lsr0_d <= lsr0;
end

always @(posedge clk or posedge rst)
begin
	if (rst)
		lsr0r <= 0;
	else
	begin
		lsr0r <= ((rf_count==1 && rf_pop && !rf_push_pulse) ||
			  rx_reset) ?
			0 // deassert condition, fifo is going empty or reset
			:
			lsr0r || (lsr0 && ~lsr0_d); // set on rise of lsr0 and keep asserted
	end
end

// lsr bit 1 (receiver overrun)
reg lsr1_d;

// rising edge detection of lsr1
always @(posedge clk or posedge rst)
begin
	if (rst)
		lsr1_d <= 0;
	else
		lsr1_d <= lsr1;
end

always @(posedge clk or posedge rst)
begin
	if (rst)
		lsr1r <= 0;
	else
	begin
		lsr1r <= lsr_mask ?
			0 // LSR read to clear
			:
			lsr1r || (lsr1 && ~lsr1_d); // set on rise of lsr1 and keep asserted
	end
end

// lsr bit 2 (parity error)
reg lsr2_d;

// rising edge detection of lsr2
always @(posedge clk or posedge rst)
begin
	if (rst)
		lsr2_d <= 0;
	else
		lsr2_d <= lsr2;
end

always @(posedge clk or posedge rst)
begin
	if (rst)
		lsr2r <= 0;
	else
	begin
		lsr2r <= lsr_mask ?
			0 // LSR read to clear
			:
			lsr2r || (lsr2 && ~lsr2_d); // set on rise of lsr2 and keep asserted
	end
end

// lsr bit 3 (framing error)
reg lsr3_d;

// rising edge detection of lsr3
always @(posedge clk or posedge rst)
begin
	if (rst)
		lsr3_d <= 0;
	else
		lsr3_d <= lsr3;
end

always @(posedge clk or posedge rst)
begin
	if (rst)
		lsr3r <= 0;
	else
	begin
		lsr3r <= lsr_mask ?
			0 // LSR read to clear
			:
			lsr3r || (lsr3 && ~lsr3_d); // set on rise of lsr3 and keeep asserted
	end
end

// lsr bit 4 (break indicator)
reg lsr4_d;

// rising edge detection of lsr4
always @(posedge clk or posedge rst)
begin
	if (rst)
		lsr4_d <= 0;
	else
		lsr4_d <= lsr4;
end

always @(posedge clk or posedge rst)
begin
	if (rst)
		lsr4r <= 0;
	else
	begin
		lsr4r <= lsr_mask ?
			0 // LSR read to clear
			:
			lsr4r || (lsr4 && ~lsr4_d); // set on rise of lsr4 and keep asserted
	end
end

// lsr bit 5 (transmitter fifo is empty)
reg lsr5_d;

// rising edge detection of lsr5
always @(posedge clk or posedge rst)
begin
	if (rst)
		lsr5_d <= 1;
	else
		lsr5_d <= lsr5;
end

always @(posedge clk or posedge rst)
begin
	if (rst)
		lsr5r <= 1;
	else
	begin
		// lsr5r:0 when writing UART_TX
		lsr5r <= (tfifo_write) ?
			0 // writing UART_TX to clear
			:
			lsr5r || (lsr5 && ~lsr5_d); // set on rise of lsr5 and keep asserted
	end
end

// lsr bit 6 (transmitter empty indicator)
reg lsr6_d;

// rising edge detection of lsr6
always @(posedge clk or posedge rst)
begin
	if (rst)
		lsr6_d <= 1;
	else
		lsr6_d <= lsr6;
end

always @(posedge clk or posedge rst)
begin
	if (rst)
		lsr6r <= 1;
	else
	begin
		lsr6r <= (tfifo_write) ?
			0 // writing UART_TX to clear
			:
			lsr6r || (lsr6 && ~lsr6_d); // set on rise of lsr6 and keep asserted
	end
end

// lsr bit 7 (error in fifo)
reg lsr7_d;

// rising edge detection of lsr7
always @(posedge clk or posedge rst)
begin
	if (rst)
		lsr7_d <= 0;
	else
		lsr7_d <= lsr7;
end

always @(posedge clk or posedge rst)
begin
	if (rst)
		lsr7r <= 0;
	else
	begin
		lsr7r <= lsr_mask ?
			0 // LSR read to clear
			:
			lsr7r || (lsr7 && ~lsr7_d); // set on rise of lsr7 and keep asserted
	end
end

// Frequency divider
always @(posedge clk or posedge rst)
begin
	if (rst)
		dlc <= 0;
	else begin
		// start_dlc is one clk pulse
		// (start_dlc == 1 or dlc == 0)
		// (start_dlc == 1) ==> dlv is updated, dlc also needs to be updated
		// (dlc == 0) ==> needs to reload dlc from dlv
		if (start_dlc | ~(|dlc))
  			dlc <= dlv - 1; // preset counter reload
		else // start_dlc == 0 && dlc != 0
			dlc <= dlc - 1; // decrement counter
	end
end

// Enable signal generation logic
// dlv: clk/(16*baud_rate)
// dlc: clk/(16*baud_rate) at initial stage, decrease by 1 every clk
// baud_pulse frequency (baud_rate * 16)
always @(posedge clk or posedge rst)
begin
	if (rst)
		baud_pulse <= 1'b0;
	else begin
		if (|dlv & ~(|dlc)) // dlv>0 && dlc==0
			baud_pulse <= 1'b1;
		else
			baud_pulse <= 1'b0;
	end
end

// Delaying THRE status for one character cycle after a character is written to an empty fifo.
// block_value is in baud sample clock unit
// including stop bits
always @(lcr)
begin
	case (lcr[3:0])
		// 7   bits
		//   7*16-1
		//   (1 start bit + 5bits data + 1 stop bit)
		4'b0000					: block_value = 95;

		// 7.5 bits
		//   7.5*16-1
		//   (1 start bit + 5bits data + 1.5 stop bit)
		4'b0100					: block_value = 103;

		// 8   bits
		//   8*16-1
		//   (1 start bit + 5bits data + 1 parity bit + 1 stop bit)
		//   (1 start bit + 6bits data + 1 stop bit)
		4'b0001, 4'b1000			: block_value = 111;

		// 8.5 bits
		//   8.5*16-1
		//   (1 start bit + 5bits data + 1 parity bit + 1.5 stop bit)
		4'b1100					: block_value = 119;

		// 9   bits
		//   9*16-1
		//   (1 start bit + 6bits data + 1 parity bit + 1 stop bit)
		//   (1 start bit + 6bits data + 2 stop bit)
		//   (1 start bit + 7bits data + 1 stop bit)
		4'b0010, 4'b0101, 4'b1001		: block_value = 127;

		// 10  bits
		//   10*16-1
		//   (1 start bit + 6bits data + 1 parity bit + 2 stop bit)
		//   (1 start bit + 7bits data + 2 stop bit)
		//   (1 start bit + 7bits data + 1 parity bit + 1 stop bit)
		//   (1 start bit + 8bits data + 1 stop bit)
		4'b0011, 4'b0110, 4'b1010, 4'b1101	: block_value = 143;

		// 11  bits
		//   11*16-1
		//   (1 start bit + 7bits data + 1 parity bit + 2 stop bit)
		//   (1 start bit + 8bits data + 1 parity bit + 1 stop bit)
		//   (1 start bit + 8bits data + 2 stop bit)
		4'b0111, 4'b1011, 4'b1110		: block_value = 159;

		// 12  bits
		//   12*16-1
		//   (1 start bit + 8bits data + 1 parity bit + 2 stop bit)
		4'b1111					: block_value = 175;
	endcase // case(lcr[3:0])
end

// Counting time of transmitting one character (including start && stop bit)
// block_cnt == 0 ==> data is transmitted done
// block_cnt > 0  ==> data is transmitting
always @(posedge clk or posedge rst)
begin
	if (rst)
		block_cnt <= 8'd0;
	else
	begin
		if (lsr5r & tfifo_write) // THRE bit set & write to TX fifo occured
			block_cnt <= block_value;
		else if (baud_pulse & (|block_cnt)) // only work on baud_pulse times
			block_cnt <= block_cnt - 1; // decrement break counter
	end
end // always of break condition detection

// Generating THRE status baud_pulse signal
// thre_set_en: 1 when block_cnt == 0,
//              this imply that one tx byte is transmitted (not including stop bit)
// thre_set_en: 0 when block_cnt != 0
assign thre_set_en = ~(|block_cnt);

//
//	INTERRUPT LOGIC
//

// RLS interrupt is enabled && (overrun or parity error or frame error or break interrupt)
assign rls_int  = ier[`UART_IE_RLS] && (lsr[`UART_LS_OE] || lsr[`UART_LS_PE] || lsr[`UART_LS_FE] || lsr[`UART_LS_BI]);
assign rda_int  = ier[`UART_IE_RDA] && (rf_count >= {1'b0,trigger_level});
// THRE interrupt is enabled && TX FIFO is empty && last TX data byte is transmitted
assign thre_int = ier[`UART_IE_THRE] && lsr[`UART_LS_TFE];
// rf_count > 0 ==> there has at least one character in RX fifo
// counter_t == 0 ==> No remove or input actions on RX fifo during 4 char time
assign ti_int   = ier[`UART_IE_RDA] && (counter_t == 10'b0) && (|rf_count);

reg rls_int_d;  // delayed rls_int
reg thre_int_d; // delayed thre_int
reg ti_int_d;   // delayed ti_int
reg rda_int_d;  // delayed rda_int

// delay lines

// at every clock rising edge, sample rls_int
always  @(posedge clk or posedge rst)
	if (rst)
		rls_int_d <= 0;
	else
		rls_int_d <= rls_int;
// at every clock rising edge, sample rda_int
always  @(posedge clk or posedge rst)
	if (rst)
		rda_int_d <= 0;
	else
		rda_int_d <= rda_int;

// at every clock rising edge, sample thre_int
always  @(posedge clk or posedge rst)
	if (rst)
		thre_int_d <= 0;
	else
		thre_int_d <= thre_int;

// at every clock rising edge, sample ti_int
always  @(posedge clk or posedge rst)
	if (rst)
		ti_int_d <= 0;
	else
		ti_int_d <= ti_int;

// rise detection signals
wire rls_int_rise;
wire thre_int_rise;
wire ti_int_rise;
wire rda_int_rise;

// rda_int_rise is 1 when rda_int from 0 to 1
assign rda_int_rise = rda_int & ~rda_int_d;
// rls_int_rise is 1 when rls_int from 0 to 1
assign rls_int_rise = rls_int & ~rls_int_d;
// thre_int_rise is 1 when thre_int from 0 to 1
assign thre_int_rise = thre_int & ~thre_int_d;
// ti_int_rise is 1 when ti_int from 0 to 1
assign ti_int_rise = ti_int & ~ti_int_d;

// interrupt pending flags
reg rls_int_pnd;
reg rda_int_pnd;
reg thre_int_pnd;
reg ti_int_pnd;

// interrupt pending flags assignments
always  @(posedge clk or posedge rst)
begin
	if (rst) rls_int_pnd <= 0;
	else
	begin
		rls_int_pnd <= lsr_mask ?
			0 // reset condition
			:
			rls_int_rise ?
				1 // latch condition
				:
				rls_int_pnd && ier[`UART_IE_RLS]; // default operation: remove if masked
	end
end

always  @(posedge clk or posedge rst)
begin
	if (rst)
		rda_int_pnd <= 0;
	else
	begin
		rda_int_pnd <= ((rf_count == {1'b0,trigger_level}) && rfifo_read) ?
			0 // reset condition
			:
			rda_int_rise ?
				1 // latch condition
				:
				rda_int_pnd && ier[`UART_IE_RDA]; // default operation: remove if masked
	end
end

always  @(posedge clk or posedge rst)
begin
	if (rst)
		thre_int_pnd <= 0;
	else
	begin
		thre_int_pnd <= tfifo_write || (iir_read & ~iir[`UART_II_IP] & iir[`UART_II_II] == `UART_II_THRE) ?
			0
			:
			thre_int_rise ?
				1
				:
				thre_int_pnd && ier[`UART_IE_THRE];
	end
end

always  @(posedge clk or posedge rst)
begin
	if (rst)
		ti_int_pnd <= 0;
	else
	begin
		ti_int_pnd <= rfifo_read ?
			0
			:
			ti_int_rise ?
				1
				:
				ti_int_pnd && ier[`UART_IE_RDA];
	end
end
// end of pending flags

// int_o logic
always @(posedge clk or posedge rst)
begin
	if (rst)
		int_o <= 1'b0;
	else
	begin
		int_o <=
			// receiver line status interrupt
			// lsr_mask: 1 ==> reading LSR
			// lsr_mask: 0 ==> not reading LSR
			// if (rls_int_pnd && lsr_mask == 0) int_o <= 1
			// if (rls_int_pnd && lsr_mask != 0) int_o <= 0
			rls_int_pnd ?
				~lsr_mask
				:
			// receive data available interrupt
			// if (rda_int_pnd) int_o <= 1
				rda_int_pnd ?
					1
					:
			// timeout indication interrupt
			// rfifo_read: 1 ==> reading RBR
			// rfifo_read: 0 ==> not reading RBR
			// if (ti_int_pnd && !rfifo_read) int_o <= 1
			// if (ti_int_pnd &&  rfifo_read) int_o <= 0
					ti_int_pnd ?
						~rfifo_read
						:
			// transmitter holding register empty
			// tfifo_write: 1 ==> writing TR
			// tfifo_write: 0 ==> not writing TR
			// iir_read: 1 ==> reading IIR
			// iir_read: 0 ==> not reading IIR
						thre_int_pnd ?
							!(tfifo_write & iir_read)
							:
							0; // if no interrupt is pending
	end
end

// Interrupt Identification register
always @(posedge clk or posedge rst)
begin
	if (rst)
		iir <= 1;
	else
	if (rls_int_pnd) // interrupt is pending
	begin
		iir[`UART_II_II] <= `UART_II_RLS;	// set identification register to correct value
		iir[`UART_II_IP] <= 1'b0;		// and clear the IIR bit 0 (interrupt pending)
	end
	else // the sequence of conditions determines priority of interrupt identification
	if (rda_int)
	begin
		iir[`UART_II_II] <= `UART_II_RDA;
		iir[`UART_II_IP] <= 1'b0;
	end
	else
	if (ti_int_pnd)
	begin
		iir[`UART_II_II] <= `UART_II_TI;
		iir[`UART_II_IP] <= 1'b0;
	end
	else
	if (thre_int_pnd)
	begin
		iir[`UART_II_II] <= `UART_II_THRE;
		iir[`UART_II_IP] <= 1'b0;
	end
	else // no interrupt is pending
	begin
		iir[`UART_II_II] <= 0;
		iir[`UART_II_IP] <= 1'b1;
	end
end

endmodule
