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

// wb_adr_i is in wb data width (32bit) unit
module wb_sram_generic #(
   parameter AW = 10,
   parameter DW = 32,
   parameter WB_B3 = 0,
   parameter INIT_MEM_FILE = "")
(
   input               wb_clk_i,
   input               wb_rst_i,
   
   input [AW-1:0]      wb_adr_i,
   input [DW-1:0]      wb_dat_i,
   input [(DW/8)-1:0]  wb_sel_i,
   input               wb_we_i,
   input [1:0]         wb_bte_i,
   input [2:0]         wb_cti_i,
   input               wb_cyc_i,
   input               wb_stb_i,
   
   output reg [DW-1:0] wb_dat_o,
   output reg          wb_ack_o,
   output              wb_rty_o,
   output              wb_err_o
);

   localparam [2:0] CTI_CLASSIC      = 3'b000;
   localparam [2:0] CTI_END_OF_BURST = 3'b111;
   localparam [2:0] CTI_CONST_BURST  = 3'b001;
   localparam [2:0] CTI_INC_BURST    = 3'b010;
   localparam [1:0] BTE_LINEAR       = 2'b00;
   localparam [1:0] BTE_WRAP4        = 2'b01;
   localparam [1:0] BTE_WRAP8        = 2'b10;
   localparam [1:0] BTE_WRAP16       = 2'b11;
   localparam DEPTH = (1 << AW);

   reg [DW-1:0] mem[0:DEPTH-1]; 
   wire [AW-1:0] radr;
   wire [AW-1:0] wadr;
   wire sram_we;
   wire [(DW/8)-1:0] sram_we_sel;

   initial begin
      if (INIT_MEM_FILE != "") begin
         $display("Preloading SRAM data from %s", INIT_MEM_FILE);
         $readmemh(INIT_MEM_FILE, mem);
      end
   end

   assign wb_rty_o = 1'b0;
   assign wb_err_o = 1'b0;
   assign sram_we_sel = {(DW/8){sram_we}} & wb_sel_i;

   integer idx;
   always @(posedge wb_clk_i) begin
      wb_dat_o <= mem[radr];
      for (idx = 0; idx < (DW/8); idx = idx+1) begin
         if (sram_we_sel[idx]) mem[wadr][idx*8+:8] <= wb_dat_i[idx*8+:8];
      end
   end

generate
if (WB_B3) begin : gen_b3_burst

function wb_cti_err;
   input [2:0] cti;
   begin
      case (cti)
      CTI_CLASSIC      : wb_cti_err = 1'b0;
      CTI_CONST_BURST  : wb_cti_err = 1'b0;
      CTI_INC_BURST    : wb_cti_err = 1'b0;
      CTI_END_OF_BURST : wb_cti_err = 1'b0;
      default : begin
         wb_cti_err = 1'b1;
         // synopsys translate_off
         $display("%d : Illegal Wishbone B3 cycle type (%b)", $time, cti);
         // synopsys translate_on
      end
      endcase
   end
endfunction

function [AW-1:0] wb_next_burst_adr;
   input [AW-1:0] adr_i;
   input [2:0] 	cti_i;
   input [2:0] 	bte_i;
   reg [AW-1:0] adr;
   begin
      adr = adr_i;
      if (cti_i == CTI_INC_BURST) begin
         case (bte_i)
         BTE_LINEAR: adr = adr + 1;
         BTE_WRAP4 : adr[1:0] = adr[1:0] + 1;
         BTE_WRAP8 : adr[2:0] = adr[2:0] + 1;
         BTE_WRAP16: adr[3:0] = adr[3:0] + 1;
         endcase
      end
      wb_next_burst_adr = adr;
   end
endfunction

   wire classic;
   wire end_of_burst;
   wire burst;
   wire const_burst;
   wire inc_burst;
   wire support_burst;
   wire valid_phase;
   reg  valid_phase_r;
   wire [AW-1:0] adr;
   reg [AW-1:0] burst_adr_r;

   assign valid_phase = wb_cyc_i & wb_stb_i;
   always @(posedge wb_clk_i)
      valid_phase_r <= valid_phase;

   assign classic = (wb_cti_i == CTI_CLASSIC);
   // 1. burst -> end_of_burst
   // 2. master can use end_of_burst to do single xfer
   assign end_of_burst = (wb_cti_i == CTI_END_OF_BURST);
   // const addr during burst xfer
   assign const_burst = (wb_cti_i == CTI_CONST_BURST);
   // support BTE_LINEAR, BTE_WRAP4, BTE_WRAP8, BTE_WRAP16 addr increment
   assign inc_burst = (wb_cti_i == CTI_INC_BURST);
   // not classic cycle and not end of burst
   // => including supported or reserved burst
   assign burst = (~classic & ~end_of_burst);
   assign support_burst = ((wb_cti_i == CTI_CONST_BURST) | (wb_cti_i == CTI_INC_BURST));
   // 1. start of data phase
   // 2. start of classic cycle (where wb_ack_o is 0)
   // 3. start of end of burst (used for single xfer, where wb_ack_o is 0)
   assign new_phase = (valid_phase & !valid_phase_r) | (valid_phase & ((classic | end_of_burst) & ~wb_ack_o));
   assign next_burst_adr = wb_next_burst_adr(burst_adr_r, wb_cti_i, wb_bte_i);
   assign adr = (new_phase) ? wb_adr_i : ((burst) ? next_burst_adr : wb_adr_i);
   assign sram_we = wb_we_i & valid_phase & wb_ack_o;
   assign radr = adr;
   assign wadr = adr;

   always @(posedge wb_clk_i)
      if (wb_rst_i) begin
         burst_adr_r <= 0;
      end else begin
         if (new_phase)
            burst_adr_r <= wb_adr_i;
         else if (support_burst)
            burst_adr_r <= next_burst_adr;
         else
            burst_adr_r <= burst_adr_r;
      end

   always @(posedge wb_clk_i)
      if (wb_rst_i) begin
         wb_ack_o <= 0;
      end else if (wb_ack_o & (classic | end_of_burst)) begin
         // 1. the xfer of classic cycle has been acked
         // 2. see end of burst after burst xfer
         // 3. the xfer of single end of burst has been acked
         // need to deassert ack signal
         wb_ack_o <= 0;
      end else if (wb_ack_o & valid_phase & support_burst) begin
         // burst xfer is in progress
         // continue to assert ack signal
         wb_ack_o <= 1;
      end else if (new_phase) begin
         // 1. start of data phase
         // 2. start of classic cycle (where wb_ack_o is 0)
         // 3. start of end of burst (used for single xfer, where wb_ack_o is 0)
         // this means new data phase will be started,
         // also new addr will be used.
         // T: new xfer is detected
         // T+d: new addr is ready
         // T+1: new rom data is ready
         // so ack signal should be assert at T+1
         wb_ack_o <= 1;
      end else begin
         wb_ack_o <= 0;
      end

end else begin // if (!WB_B3)

   assign radr = wb_adr_i;
   assign wadr = wb_adr_i;
   assign sram_we = wb_we_i & wb_ack_o;

   always @(posedge wb_clk_i or posedge wb_rst_i)
      if (wb_rst_i)
         wb_ack_o <= 1'b0;
      else
         wb_ack_o <= wb_stb_i & wb_cyc_i & !wb_ack_o;

end // if (WB_B3)
endgenerate

endmodule 
