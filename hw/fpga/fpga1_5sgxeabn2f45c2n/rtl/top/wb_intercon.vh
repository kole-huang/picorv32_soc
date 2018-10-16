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

wire [31:0] wb_m2s_picorv32_adr;
wire [31:0] wb_m2s_picorv32_dat;
wire  [3:0] wb_m2s_picorv32_sel;
wire        wb_m2s_picorv32_we ;
wire        wb_m2s_picorv32_cyc;
wire        wb_m2s_picorv32_stb;
wire  [2:0] wb_m2s_picorv32_cti;
wire  [1:0] wb_m2s_picorv32_bte;
wire [31:0] wb_s2m_picorv32_dat;
wire        wb_s2m_picorv32_ack;
wire        wb_s2m_picorv32_err;
wire        wb_s2m_picorv32_rty;

// to wb_sram.wb_*
wire [31:0] wb_m2s_sram0_adr;
wire [31:0] wb_m2s_sram0_dat;
wire  [3:0] wb_m2s_sram0_sel;
wire        wb_m2s_sram0_we ;
wire        wb_m2s_sram0_cyc;
wire        wb_m2s_sram0_stb;
wire  [2:0] wb_m2s_sram0_cti;
wire  [1:0] wb_m2s_sram0_bte;
wire [31:0] wb_s2m_sram0_dat;
wire        wb_s2m_sram0_ack;
wire        wb_s2m_sram0_err;
wire        wb_s2m_sram0_rty;

// to wb_sram.wb_*
wire [31:0] wb_m2s_sram1_adr;
wire [31:0] wb_m2s_sram1_dat;
wire  [3:0] wb_m2s_sram1_sel;
wire        wb_m2s_sram1_we ;
wire        wb_m2s_sram1_cyc;
wire        wb_m2s_sram1_stb;
wire  [2:0] wb_m2s_sram1_cti;
wire  [1:0] wb_m2s_sram1_bte;
wire [31:0] wb_s2m_sram1_dat;
wire        wb_s2m_sram1_ack;
wire        wb_s2m_sram1_err;
wire        wb_s2m_sram1_rty;

// to uart_top.wb_*
wire [31:0] wb_m2s_uart0_adr;
wire  [7:0] wb_m2s_uart0_dat;
wire  [3:0] wb_m2s_uart0_sel;
wire        wb_m2s_uart0_we ;
wire        wb_m2s_uart0_cyc;
wire        wb_m2s_uart0_stb;
wire  [2:0] wb_m2s_uart0_cti;
wire  [1:0] wb_m2s_uart0_bte;
wire  [7:0] wb_s2m_uart0_dat;
wire        wb_s2m_uart0_ack;
wire        wb_s2m_uart0_err;
wire        wb_s2m_uart0_rty;

wb_intercon wb_intercon0 (
    .wb_clk_i             (wb_clk),
    .wb_rst_i             (wb_rst),

    .wb_picorv32_adr_i    (wb_m2s_picorv32_adr),
    .wb_picorv32_dat_i    (wb_m2s_picorv32_dat),
    .wb_picorv32_sel_i    (wb_m2s_picorv32_sel),
    .wb_picorv32_we_i     (wb_m2s_picorv32_we ),
    .wb_picorv32_cyc_i    (wb_m2s_picorv32_cyc),
    .wb_picorv32_stb_i    (wb_m2s_picorv32_stb),
    .wb_picorv32_cti_i    (wb_m2s_picorv32_cti),
    .wb_picorv32_bte_i    (wb_m2s_picorv32_bte),
    .wb_picorv32_dat_o    (wb_s2m_picorv32_dat),
    .wb_picorv32_ack_o    (wb_s2m_picorv32_ack),
    .wb_picorv32_err_o    (wb_s2m_picorv32_err),
    .wb_picorv32_rty_o    (wb_s2m_picorv32_rty),

    .wb_sram0_adr_o       (wb_m2s_sram0_adr),
    .wb_sram0_dat_o       (wb_m2s_sram0_dat),
    .wb_sram0_sel_o       (wb_m2s_sram0_sel),
    .wb_sram0_we_o        (wb_m2s_sram0_we ),
    .wb_sram0_cyc_o       (wb_m2s_sram0_cyc),
    .wb_sram0_stb_o       (wb_m2s_sram0_stb),
    .wb_sram0_cti_o       (wb_m2s_sram0_cti),
    .wb_sram0_bte_o       (wb_m2s_sram0_bte),
    .wb_sram0_dat_i       (wb_s2m_sram0_dat),
    .wb_sram0_ack_i       (wb_s2m_sram0_ack),
    .wb_sram0_err_i       (wb_s2m_sram0_err),
    .wb_sram0_rty_i       (wb_s2m_sram0_rty),

    .wb_sram1_adr_o       (wb_m2s_sram1_adr),
    .wb_sram1_dat_o       (wb_m2s_sram1_dat),
    .wb_sram1_sel_o       (wb_m2s_sram1_sel),
    .wb_sram1_we_o        (wb_m2s_sram1_we ),
    .wb_sram1_cyc_o       (wb_m2s_sram1_cyc),
    .wb_sram1_stb_o       (wb_m2s_sram1_stb),
    .wb_sram1_cti_o       (wb_m2s_sram1_cti),
    .wb_sram1_bte_o       (wb_m2s_sram1_bte),
    .wb_sram1_dat_i       (wb_s2m_sram1_dat),
    .wb_sram1_ack_i       (wb_s2m_sram1_ack),
    .wb_sram1_err_i       (wb_s2m_sram1_err),
    .wb_sram1_rty_i       (wb_s2m_sram1_rty),

    .wb_uart0_adr_o       (wb_m2s_uart0_adr),
    .wb_uart0_dat_o       (wb_m2s_uart0_dat),
    .wb_uart0_sel_o       (wb_m2s_uart0_sel),
    .wb_uart0_we_o        (wb_m2s_uart0_we ),
    .wb_uart0_cyc_o       (wb_m2s_uart0_cyc),
    .wb_uart0_stb_o       (wb_m2s_uart0_stb),
    .wb_uart0_cti_o       (wb_m2s_uart0_cti),
    .wb_uart0_bte_o       (wb_m2s_uart0_bte),
    .wb_uart0_dat_i       (wb_s2m_uart0_dat),
    .wb_uart0_ack_i       (wb_s2m_uart0_ack),
    .wb_uart0_err_i       (wb_s2m_uart0_err),
    .wb_uart0_rty_i       (wb_s2m_uart0_rty)
);
