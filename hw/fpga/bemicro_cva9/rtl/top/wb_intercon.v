//////////////////////////////////////////////////////////////////////
//
// This source file may be used and distributed without
// restriction provided that this copyright statement is not
// removed from the file and that any derivative work contains
// the original copyright notice and the associated disclaimer.
//
// This source file is free software; you can redistribute it
// and/or modify it under the terms of the GNU Lesser General
// Public License as published by the Free Software Foundation;
// either version 2.1 of the License, or (at your option) any
// later version.
//
// This source is distributed in the hope that it will be
// useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
// PURPOSE.  See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General
// Public License along with this source; if not, download it
// from http://www.opencores.org/lgpl.shtml
//
//////////////////////////////////////////////////////////////////////

`include "soc.vh"

module wb_intercon (
    input         wb_clk_i,
    input         wb_rst_i,
    // wb master signals from picorv32
    input  [31:0] wb_picorv32_adr_i,
    input  [31:0] wb_picorv32_dat_i,
    input   [3:0] wb_picorv32_sel_i,
    input         wb_picorv32_we_i,
    input         wb_picorv32_cyc_i,
    input         wb_picorv32_stb_i,
    input   [2:0] wb_picorv32_cti_i,
    input   [1:0] wb_picorv32_bte_i,
    output [31:0] wb_picorv32_dat_o,
    output        wb_picorv32_ack_o,
    output        wb_picorv32_err_o,
    output        wb_picorv32_rty_o,
    // to sram0 wb signals
    output [31:0] wb_sram0_adr_o,
    output [31:0] wb_sram0_dat_o,
    output  [3:0] wb_sram0_sel_o,
    output        wb_sram0_we_o ,
    output        wb_sram0_cyc_o,
    output        wb_sram0_stb_o,
    output  [2:0] wb_sram0_cti_o,
    output  [1:0] wb_sram0_bte_o,
    input  [31:0] wb_sram0_dat_i,
    input         wb_sram0_ack_i,
    input         wb_sram0_err_i,
    input         wb_sram0_rty_i,
    // to sram1 wb signals
    output [31:0] wb_sram1_adr_o,
    output [31:0] wb_sram1_dat_o,
    output  [3:0] wb_sram1_sel_o,
    output        wb_sram1_we_o ,
    output        wb_sram1_cyc_o,
    output        wb_sram1_stb_o,
    output  [2:0] wb_sram1_cti_o,
    output  [1:0] wb_sram1_bte_o,
    input  [31:0] wb_sram1_dat_i,
    input         wb_sram1_ack_i,
    input         wb_sram1_err_i,
    input         wb_sram1_rty_i,
    // to uart0 wb signals
    output [31:0] wb_uart0_adr_o,
    output  [7:0] wb_uart0_dat_o,
    output  [3:0] wb_uart0_sel_o,
    output        wb_uart0_we_o ,
    output        wb_uart0_cyc_o,
    output        wb_uart0_stb_o,
    output  [2:0] wb_uart0_cti_o,
    output  [1:0] wb_uart0_bte_o,
    input   [7:0] wb_uart0_dat_i,
    input         wb_uart0_ack_i,
    input         wb_uart0_err_i,
    input         wb_uart0_rty_i
);

// internal wb resize signals for uart0
wire [31:0] wb_m2s_resize_uart0_adr;
wire [31:0] wb_m2s_resize_uart0_dat;
wire  [3:0] wb_m2s_resize_uart0_sel;
wire        wb_m2s_resize_uart0_we ;
wire        wb_m2s_resize_uart0_cyc;
wire        wb_m2s_resize_uart0_stb;
wire  [2:0] wb_m2s_resize_uart0_cti;
wire  [1:0] wb_m2s_resize_uart0_bte;
wire [31:0] wb_s2m_resize_uart0_dat;
wire        wb_s2m_resize_uart0_ack;
wire        wb_s2m_resize_uart0_err;
wire        wb_s2m_resize_uart0_rty;

wb_mux #(
    .NUM_SLAVES (3),
    .MATCH_ADDR ({`SRAM0_BASE, `SRAM1_BASE, `UART0_BASE}),
    .MATCH_MASK ({`SRAM0_MASK, `SRAM1_MASK, `UART0_MASK})
) wb_mux_picorv32_wb (
    .wb_clk_i  (wb_clk_i),
    .wb_rst_i  (wb_rst_i),
    .wbm_adr_i (wb_picorv32_adr_i),
    .wbm_dat_i (wb_picorv32_dat_i),
    .wbm_sel_i (wb_picorv32_sel_i),
    .wbm_we_i  (wb_picorv32_we_i ),
    .wbm_cyc_i (wb_picorv32_cyc_i),
    .wbm_stb_i (wb_picorv32_stb_i),
    .wbm_cti_i (wb_picorv32_cti_i),
    .wbm_bte_i (wb_picorv32_bte_i),
    .wbm_dat_o (wb_picorv32_dat_o),
    .wbm_ack_o (wb_picorv32_ack_o),
    .wbm_err_o (wb_picorv32_err_o),
    .wbm_rty_o (wb_picorv32_rty_o),
    .wbs_adr_o ({wb_sram0_adr_o, wb_sram1_adr_o, wb_m2s_resize_uart0_adr}),
    .wbs_dat_o ({wb_sram0_dat_o, wb_sram1_dat_o, wb_m2s_resize_uart0_dat}),
    .wbs_sel_o ({wb_sram0_sel_o, wb_sram1_sel_o, wb_m2s_resize_uart0_sel}),
    .wbs_we_o  ({wb_sram0_we_o , wb_sram1_we_o , wb_m2s_resize_uart0_we }),
    .wbs_cyc_o ({wb_sram0_cyc_o, wb_sram1_cyc_o, wb_m2s_resize_uart0_cyc}),
    .wbs_stb_o ({wb_sram0_stb_o, wb_sram1_stb_o, wb_m2s_resize_uart0_stb}),
    .wbs_cti_o ({wb_sram0_cti_o, wb_sram1_cti_o, wb_m2s_resize_uart0_cti}),
    .wbs_bte_o ({wb_sram0_bte_o, wb_sram1_bte_o, wb_m2s_resize_uart0_bte}),
    .wbs_dat_i ({wb_sram0_dat_i, wb_sram1_dat_i, wb_s2m_resize_uart0_dat}),
    .wbs_ack_i ({wb_sram0_ack_i, wb_sram1_ack_i, wb_s2m_resize_uart0_ack}),
    .wbs_err_i ({wb_sram0_err_i, wb_sram1_err_i, wb_s2m_resize_uart0_err}),
    .wbs_rty_i ({wb_sram0_rty_i, wb_sram1_rty_i, wb_s2m_resize_uart0_rty})
);

wb_data_resize_32to8 wb_data_resize_uart0 (
    .wbm_adr_i (wb_m2s_resize_uart0_adr),
    .wbm_dat_i (wb_m2s_resize_uart0_dat),
    .wbm_sel_i (wb_m2s_resize_uart0_sel),
    .wbm_we_i  (wb_m2s_resize_uart0_we ),
    .wbm_cyc_i (wb_m2s_resize_uart0_cyc),
    .wbm_stb_i (wb_m2s_resize_uart0_stb),
    .wbm_cti_i (wb_m2s_resize_uart0_cti),
    .wbm_bte_i (wb_m2s_resize_uart0_bte),
    .wbm_dat_o (wb_s2m_resize_uart0_dat),
    .wbm_ack_o (wb_s2m_resize_uart0_ack),
    .wbm_err_o (wb_s2m_resize_uart0_err),
    .wbm_rty_o (wb_s2m_resize_uart0_rty),
    .wbs_adr_o (wb_uart0_adr_o),
    .wbs_dat_o (wb_uart0_dat_o),
    .wbs_we_o  (wb_uart0_we_o ),
    .wbs_cyc_o (wb_uart0_cyc_o),
    .wbs_stb_o (wb_uart0_stb_o),
    .wbs_cti_o (wb_uart0_cti_o),
    .wbs_bte_o (wb_uart0_bte_o),
    .wbs_dat_i (wb_uart0_dat_i),
    .wbs_ack_i (wb_uart0_ack_i),
    .wbs_err_i (wb_uart0_err_i),
    .wbs_rty_i (wb_uart0_rty_i)
);

endmodule
