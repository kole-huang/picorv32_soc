//////////////////////////////////////////////////////////////////////
///                                                               //// 
/// Wishbone multiplexer, burst-compatible                        ////
///                                                               ////
/// Simple mux with an arbitrary number of slaves.                ////
///                                                               ////
/// The parameters MATCH_ADDR and MATCH_MASK are flattened arrays ////
/// AW*NUM_SLAVES sized arrays that are used to calculate the     ////
/// active slave. slave i is selected when                        ////
/// (wb_adr_i & MATCH_MASK[(i+1)*AW-1:i*AW] is equal to           ////
/// MATCH_ADDR[(i+1)*AW-1:i*AW]                                   ////
/// If several regions are overlapping, the slave with the lowest ////
/// index is selected. This can be used to have fallback          ////
/// functionality in the last slave, in case no other slave was   ////
/// selected.                                                     ////
///                                                               ////
/// If no match is found, the wishbone transaction will stall and ////
/// an external watchdog is required to abort the transaction     ////
///                                                               ////
/// Olof Kindgren, olof@opencores.org                             ////
///                                                               ////
/// Todo:                                                         ////
/// Registered master/slave connections                           ////
/// Rewrite with System Verilog 2D arrays when tools support them ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2013 Authors and OPENCORES.ORG                 ////
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

module wb_mux #(
   parameter AW = 32,        // Address width
   parameter DW = 32,        // Data width
   parameter SELW = (DW/8),  // Byte Sel width
   parameter NUM_SLAVES = 2, // Number of slaves
   parameter [NUM_SLAVES*AW-1:0] MATCH_ADDR = 0,
   parameter [NUM_SLAVES*AW-1:0] MATCH_MASK = 0)
(
   input			wb_clk_i,
   input			wb_rst_i,

   // Master Interface
   input  [AW-1:0]		wbm_adr_i,
   input  [DW-1:0]		wbm_dat_i,
   input  [SELW-1:0]		wbm_sel_i,
   input			wbm_we_i,
   input			wbm_cyc_i,
   input			wbm_stb_i,
   input  [2:0]			wbm_cti_i,
   input  [1:0]			wbm_bte_i,
   output [DW-1:0]		wbm_dat_o,
   output			wbm_ack_o,
   output			wbm_err_o,
   output			wbm_rty_o,

   // Wishbone Slave interface
   output [NUM_SLAVES*AW-1:0]	wbs_adr_o,
   output [NUM_SLAVES*DW-1:0]	wbs_dat_o,
   output [NUM_SLAVES*SELW-1:0]	wbs_sel_o, 
   output [NUM_SLAVES-1:0]	wbs_we_o,
   output [NUM_SLAVES-1:0]	wbs_cyc_o,
   output [NUM_SLAVES-1:0]	wbs_stb_o,
   output [NUM_SLAVES*3-1:0]	wbs_cti_o,
   output [NUM_SLAVES*2-1:0]	wbs_bte_o,
   input  [NUM_SLAVES*DW-1:0]	wbs_dat_i,
   input  [NUM_SLAVES-1:0]	wbs_ack_i,
   input  [NUM_SLAVES-1:0]	wbs_err_i,
   input  [NUM_SLAVES-1:0]	wbs_rty_i
);

   `include "verilog_utils.vh"

///////////////////////////////////////////////////////////////////////////////
// Master/slave connection
///////////////////////////////////////////////////////////////////////////////
   // Use parameter instead of localparam to work around a bug in Xilinx ISE
   parameter slave_sel_bits = NUM_SLAVES > 1 ? clog2(NUM_SLAVES) : 1;

   wire [slave_sel_bits-1:0] 	 slave_sel;
   wire [NUM_SLAVES-1:0] 	 match;
   wire                          slave_match;
   wire                          valid_bus_phase;

   // match[0]: 1 ==> request is for slave idx 0 (wbm_adr_i is within the slave0's address space)
   // match[1]: 1 ==> request is for slave idx 1 (wbm_adr_i is within the slave1's address space)
   // ...
   genvar 			 idx;
   generate
      for(idx=0; idx<NUM_SLAVES ; idx=idx+1) begin : addr_match
         assign match[idx] = (wbm_adr_i & MATCH_MASK[idx*AW+:AW]) == MATCH_ADDR[idx*AW+:AW];
      end
   endgenerate

   // Find First 1 - Start from MSB and count downwards, returns 0 when no bit set
   function [slave_sel_bits-1:0] ff1;
      input [NUM_SLAVES-1:0] in;
      integer 		     i;
      begin
         ff1 = 0;
         for (i = NUM_SLAVES-1; i >= 0; i = i-1) begin
            if (in[i]) ff1 = i;
         end
      end
   endfunction

   assign slave_match = |match;
   assign valid_bus_phase = wbm_cyc_i & slave_match;
   // wbm_adr_i does not match any slave's address space
   assign err_bus_phase = wbm_cyc_i & ~slave_match;

   // match[0]: 1 ==> slave_sel is 0
   // match[1]: 1 ==> slave_sel is 1
   // match[2]: 1 ==> slave_sel is 2
   // ...
   // if (match == 0) ==> slave_sel is 0, this means that wbm_adr_i does not match any slave
   assign slave_sel = ff1(match);

   // forward wbm_adr_i to the selected slave
   assign wbs_adr_o = valid_bus_phase ? {{(NUM_SLAVES*AW){1'b0}} | (wbm_adr_i << (slave_sel*AW))} : 0;
   assign wbs_dat_o = (valid_bus_phase & wbm_we_i) ? {{(NUM_SLAVES*DW){1'b0}} | (wbm_dat_i << (slave_sel*DW))} : 0;
   assign wbs_sel_o = valid_bus_phase ? {{(NUM_SLAVES*SELW){1'b0}} | (wbm_sel_i << (slave_sel*SELW))} : 0;
   assign wbs_we_o  = valid_bus_phase ? {{(NUM_SLAVES*1){1'b0}} | (wbm_we_i << (slave_sel*1))} : 0;

   // forward wbm_cyc_i to the selected slave
   assign wbs_cyc_o = valid_bus_phase ? {{(NUM_SLAVES*1){1'b0}} | (wbm_cyc_i << (slave_sel*1))} : 0;
   assign wbs_stb_o = valid_bus_phase ? {{(NUM_SLAVES*1){1'b0}} | (wbm_stb_i << (slave_sel*1))} : 0;

   assign wbs_cti_o = valid_bus_phase ? {{(NUM_SLAVES*3){1'b0}} | (wbm_cti_i << (slave_sel*3))} : 0;
   assign wbs_bte_o = valid_bus_phase ? {{(NUM_SLAVES*2){1'b0}} | (wbm_bte_i << (slave_sel*2))} : 0;

   // forward the selected slave reponse signals to master
   assign wbm_dat_o = (valid_bus_phase & ~wbm_we_i & wbm_ack_o) ? wbs_dat_i[slave_sel*DW+:DW] : {(DW-1){1'b0}};
   assign wbm_ack_o = (valid_bus_phase) ? wbs_ack_i[slave_sel] : 0;
   assign wbm_err_o = err_bus_phase | ((valid_bus_phase) ? wbs_err_i[slave_sel] : 0);
   assign wbm_rty_o = (valid_bus_phase) ? wbs_rty_i[slave_sel] : 0;

endmodule
