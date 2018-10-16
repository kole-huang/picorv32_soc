module wb_data_resize_32to8
(
   // Wishbone Master interface
   input  [31:0] wbm_adr_i,
   input  [31:0] wbm_dat_i,
   input  [3:0]  wbm_sel_i,
   input         wbm_we_i,
   input         wbm_cyc_i,
   input         wbm_stb_i,
   input  [2:0]  wbm_cti_i,
   input  [1:0]  wbm_bte_i,
   output [31:0] wbm_dat_o,
   output        wbm_ack_o,
   output        wbm_err_o,
   output        wbm_rty_o, 
   // Wishbone Slave interface
   output [31:0] wbs_adr_o,
   output [7:0]  wbs_dat_o,
   output        wbs_we_o,
   output        wbs_cyc_o,
   output        wbs_stb_o,
   output [2:0]  wbs_cti_o,
   output [1:0]  wbs_bte_o,
   input  [7:0]  wbs_dat_i,
   input         wbs_ack_i,
   input         wbs_err_i,
   input         wbs_rty_i
);

   // for value 0x12345678 in picorv32 (little endian)
   // mem_byte[0] = 0x78
   // mem_byte[1] = 0x56
   // mem_byte[2] = 0x34
   // mem_byte[3] = 0x12
   // wbm_dat_i[7:0]   = 0x78 => mem_byte[0]
   // wbm_dat_i[15:8]  = 0x56 => mem_byte[1]
   // wbm_dat_i[23:16] = 0x34 => mem_byte[2]
   // wbm_dat_i[31:24] = 0x12 => mem_byte[3]
   // wb_sel_i[0] is for wbm_dat_i[7:0]   => mem_byte[0]
   // wb_sel_i[1] is for wbm_dat_i[15:8]  => mem_byte[1]
   // wb_sel_i[2] is for wbm_dat_i[23:16] => mem_byte[2]
   // wb_sel_i[3] is for wbm_dat_i[31:24] => mem_byte[3]
   assign wbs_adr_o[31:2] = wbm_adr_i[31:2]; // 32-bit aligned address
   assign wbs_adr_o[1:0] = wbm_sel_i[3] ? 2'd3 :
                           wbm_sel_i[2] ? 2'd2 :
                           wbm_sel_i[1] ? 2'd1 :
                                          2'd0;
   // according to wbm_sel_i, construct wbs_dat_o (8-bit data)
   assign wbs_dat_o = ~wbm_we_i ? {8'b0} : (
                         wbm_sel_i[3] ? wbm_dat_i[31:24] :
                         wbm_sel_i[2] ? wbm_dat_i[23:16] :
                         wbm_sel_i[1] ? wbm_dat_i[15:8]  :
                         wbm_sel_i[0] ? wbm_dat_i[7:0]   :
                                        {8'b0});
   assign wbs_cyc_o = wbm_cyc_i;
   assign wbs_stb_o = wbm_stb_i;
   assign wbs_we_o  = wbm_we_i;
   assign wbs_cti_o = wbm_cti_i;
   assign wbs_bte_o = wbm_bte_i;
   // compose 32-bit data from 8-bit data
   assign wbm_dat_o = (wbm_we_i | ~wbs_ack_i) ? {32'b0} : (
                         wbm_sel_i[3] ? {wbs_dat_i, 24'b0       } :
                         wbm_sel_i[2] ? {8'b0 , wbs_dat_i, 16'b0} :
                         wbm_sel_i[1] ? {16'b0, wbs_dat_i, 8'b0 } :
                         wbm_sel_i[0] ? {24'b0, wbs_dat_i       } :
                                        {32'b0});
   assign wbm_ack_o = wbs_ack_i;
   assign wbm_err_o = wbs_err_i;
   assign wbm_rty_o = wbs_rty_i;

endmodule
