//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Author(s):                                                  ////
////      - Julius Baxter    (julius@opencores.org)               ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 Authors                                   ////
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

module wb_sram #(
   parameter TECHNOLOGY = "GENERIC",
   parameter AW = 10,
   parameter DW = 32,
   parameter WB_B3 = 0,
   parameter INIT_MEM_FILE = "")
(
   input              wb_clk_i,
   input              wb_rst_i,

   input [AW-1:0]     wb_adr_i,
   input [DW-1:0]     wb_dat_i,
   input [(DW/8)-1:0] wb_sel_i,
   input              wb_we_i,
   input [1:0]        wb_bte_i,
   input [2:0]        wb_cti_i,
   input              wb_cyc_i,
   input              wb_stb_i,

   output [DW-1:0]    wb_dat_o,
   output             wb_ack_o,
   output             wb_rty_o,
   output             wb_err_o
);

generate
if (TECHNOLOGY == "GENERIC") begin : wb_sram_generic
wb_sram_generic #(
   .AW            (AW),
   .DW            (DW),
   .WB_B3         (WB_B3),
   .INIT_MEM_FILE (INIT_MEM_FILE)
) wb_sram_generic0 (
   .wb_clk_i (wb_clk_i),
   .wb_rst_i (wb_rst_i),

   .wb_adr_i (wb_adr_i),
   .wb_dat_i (wb_dat_i),
   .wb_sel_i (wb_sel_i),
   .wb_we_i  (wb_we_i),
   .wb_bte_i (wb_bte_i),
   .wb_cti_i (wb_cti_i),
   .wb_cyc_i (wb_cyc_i),
   .wb_stb_i (wb_stb_i),

   .wb_dat_o (wb_dat_o),
   .wb_ack_o (wb_ack_o),
   .wb_rty_o (wb_rty_o),
   .wb_err_o (wb_err_o)
);
end else if (TECHNOLOGY == "ALTERA") begin : wb_sram_altera
wb_sram_altera #(
   .AW            (AW),
   .DW            (DW),
   .WB_B3         (WB_B3),
   .INIT_MEM_FILE (INIT_MEM_FILE)
) wb_sram_altera0 (
   .wb_clk_i (wb_clk_i),
   .wb_rst_i (wb_rst_i),

   .wb_adr_i (wb_adr_i),
   .wb_dat_i (wb_dat_i),
   .wb_sel_i (wb_sel_i),
   .wb_we_i  (wb_we_i),
   .wb_bte_i (wb_bte_i),
   .wb_cti_i (wb_cti_i),
   .wb_cyc_i (wb_cyc_i),
   .wb_stb_i (wb_stb_i),

   .wb_dat_o (wb_dat_o),
   .wb_ack_o (wb_ack_o),
   .wb_rty_o (wb_rty_o),
   .wb_err_o (wb_err_o)
);
end
endgenerate

endmodule
