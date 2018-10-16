//////////////////////////////////////////////////////////////////////
///                                                               //// 
/// Wishbone arbiter, burst-compatible                            ////
///                                                               ////
/// Simple round-robin arbiter for multiple Wishbone masters      ////
///                                                               ////
/// Olof Kindgren, olof@opencores.org                             ////
///                                                               ////
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

module wb_arbiter #(
   parameter AW = 32,
   parameter DW = 32,
   parameter SELW = (DW/8),
   parameter NUM_MASTERS = 0)
  (
   input wb_clk_i,
   input wb_rst_i,

   // Wishbone Master Interface
   input  [NUM_MASTERS*AW-1:0]   wbm_adr_i,
   input  [NUM_MASTERS*DW-1:0]   wbm_dat_i,
   input  [NUM_MASTERS*SELW-1:0] wbm_sel_i,
   input  [NUM_MASTERS-1:0]      wbm_we_i,
   input  [NUM_MASTERS-1:0]      wbm_cyc_i,
   input  [NUM_MASTERS-1:0]      wbm_stb_i,
   input  [NUM_MASTERS*3-1:0]    wbm_cti_i,
   input  [NUM_MASTERS*2-1:0]    wbm_bte_i,
   output [NUM_MASTERS*DW-1:0]   wbm_dat_o,
   output [NUM_MASTERS-1:0]      wbm_ack_o,
   output [NUM_MASTERS-1:0]      wbm_err_o,
   output [NUM_MASTERS-1:0]      wbm_rty_o, 

   // Wishbone Slave interface
   output [AW-1:0] 	         wbs_adr_o,
   output [DW-1:0] 	         wbs_dat_o,
   output [SELW-1:0] 	         wbs_sel_o, 
   output 		         wbs_we_o,
   output 		         wbs_cyc_o,
   output 		         wbs_stb_o,
   output [2:0] 	         wbs_cti_o,
   output [1:0] 	         wbs_bte_o,
   input [DW-1:0] 	         wbs_dat_i,
   input 		         wbs_ack_i,
   input 		         wbs_err_i,
   input 		         wbs_rty_i
);

   `include "verilog_utils.vh"

   // Use parameter instead of localparam to work around a bug in Xilinx ISE
   parameter MASTER_SEL_BITS = NUM_MASTERS > 1 ? clog2(NUM_MASTERS) : 1;

   wire [NUM_MASTERS-1:0]     grant;
   wire [MASTER_SEL_BITS-1:0] master_sel;
   wire 		      active;

   arbiter #(
      .NUM_PORTS (NUM_MASTERS)
   ) arbiter0 (
      .clk     (wb_clk_i),
      .rst     (wb_rst_i),
      .request (wbm_cyc_i),
      .grant   (grant),
      .select  (master_sel),
      .active  (active)
   );

   // forward the selected master's request signals to slave
   assign wbs_adr_o = active ? wbm_adr_i[master_sel*AW+:AW] : 0;
   assign wbs_dat_o = active ? wbm_dat_i[master_sel*DW+:DW] : 0;
   assign wbs_sel_o = active ? wbm_sel_i[master_sel*SELW+:SELW] : 0;
   assign wbs_we_o  = active ? wbm_we_i [master_sel] : 0;
   assign wbs_cyc_o = active ? wbm_cyc_i[master_sel] : 0;
   assign wbs_stb_o = active ? wbm_stb_i[master_sel] : 0;
   assign wbs_cti_o = active ? wbm_cti_i[master_sel*3+:3] : 0;
   assign wbs_bte_o = active ? wbm_bte_i[master_sel*2+:2] : 0;

   // forward the slave's response signal to master
   assign wbm_dat_o = active ? {{(NUM_MASTERS*DW){1'b0}} | (wbs_dat_i << (master_sel*DW))} : 0;
   assign wbm_ack_o = active ? (wbs_ack_i << master_sel) : 0;
   assign wbm_err_o = active ? (wbs_err_i << master_sel) : 0;
   assign wbm_rty_o = active ? (wbs_rty_i << master_sel) : 0;
 
endmodule // wb_arbiter
