//////////////////////////////////////////////////////////////////////
//
// Based on ORPSoC by
// Stefan Kristiansson <stefan.kristiansson@saunalahti.fi
//
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

module soc_top
(
	input		clk_i,
	input		rst_i,

	input		uart0_rx_i,
	output		uart0_tx_o
);

`include "verilog_utils.vh"
`include "soc.vh"

////////////////////////////////////////////////////////////////////////
//
// Clock and reset generation module
//
////////////////////////////////////////////////////////////////////////

assign wb_clk = clk_i;
assign wb_rst = rst_i;

////////////////////////////////////////////////////////////////////////
//
// Modules interconnections
//
////////////////////////////////////////////////////////////////////////
`include "wb_intercon.vh"

////////////////////////////////////////////////////////////////////////
//
// SRAM
//
////////////////////////////////////////////////////////////////////////
localparam SRAM0_AW = clog2(`SRAM0_SIZE/4);
wb_sram #(
`ifdef SRAM0_TECH_ALTERA
	.TECHNOLOGY("ALTERA"),
`else
	.TECHNOLOGY("GENERIC"),
`endif
	.AW(SRAM0_AW),
`ifdef SOC_BUS_WB_B3
	.WB_B3(1),
`else
	.WB_B3(0),
`endif
	.INIT_MEM_FILE(`SRAM0_INIT_MEM_FILE)
) sram0 (
	.wb_clk_i	(wb_clk),
	.wb_rst_i	(wb_rst),
	.wb_adr_i	(wb_m2s_sram0_adr[(SRAM0_AW+2)-1:2]),
	.wb_dat_i	(wb_m2s_sram0_dat),
	.wb_sel_i	(wb_m2s_sram0_sel),
	.wb_we_i	(wb_m2s_sram0_we ),
	.wb_cyc_i	(wb_m2s_sram0_cyc),
	.wb_stb_i	(wb_m2s_sram0_stb),
	.wb_cti_i	(wb_m2s_sram0_cti),
	.wb_bte_i	(wb_m2s_sram0_bte),
	.wb_dat_o	(wb_s2m_sram0_dat),
	.wb_ack_o	(wb_s2m_sram0_ack),
	.wb_rty_o	(wb_s2m_sram0_rty),
	.wb_err_o	(wb_s2m_sram0_err)
);

localparam SRAM1_AW = clog2(`SRAM1_SIZE/4);
wb_sram #(
`ifdef SRAM1_TECH_ALTERA
	.TECHNOLOGY("ALTERA"),
`else
	.TECHNOLOGY("GENERIC"),
`endif
	.AW(SRAM1_AW),
`ifdef SOC_BUS_WB_B3
	.WB_B3(1),
`else
	.WB_B3(0),
`endif
	.INIT_MEM_FILE(`SRAM1_INIT_MEM_FILE)
) sram1 (
	.wb_clk_i	(wb_clk),
	.wb_rst_i	(wb_rst),
	.wb_adr_i	(wb_m2s_sram1_adr[(SRAM1_AW+2)-1:2]),
	.wb_dat_i	(wb_m2s_sram1_dat),
	.wb_sel_i	(wb_m2s_sram1_sel),
	.wb_we_i	(wb_m2s_sram1_we ),
	.wb_cyc_i	(wb_m2s_sram1_cyc),
	.wb_stb_i	(wb_m2s_sram1_stb),
	.wb_cti_i	(wb_m2s_sram1_cti),
	.wb_bte_i	(wb_m2s_sram1_bte),
	.wb_dat_o	(wb_s2m_sram1_dat),
	.wb_ack_o	(wb_s2m_sram1_ack),
	.wb_rty_o	(wb_s2m_sram1_rty),
	.wb_err_o	(wb_s2m_sram1_err)
);

////////////////////////////////////////////////////////////////////////
//
// UART0
//
////////////////////////////////////////////////////////////////////////

wire	uart0_irq;

assign	wb_s2m_uart0_err = 0;
assign	wb_s2m_uart0_rty = 0;

uart_top uart0 (
	// Wishbone slave interface
	.wb_clk_i	(wb_clk),
	.wb_rst_i	(wb_rst),
	.wb_adr_i	(wb_m2s_uart0_adr[2:0]), // 8 register addressing (in byte)
	.wb_dat_i	(wb_m2s_uart0_dat),
	.wb_we_i	(wb_m2s_uart0_we),
	.wb_stb_i	(wb_m2s_uart0_stb),
	.wb_cyc_i	(wb_m2s_uart0_cyc),
	.wb_sel_i	(4'b0), // Not used in 8-bit mode
	.wb_dat_o	(wb_s2m_uart0_dat),
	.wb_ack_o	(wb_s2m_uart0_ack),

	// Outputs
	.int_o		(uart0_irq),
	.stx_pad_o	(uart0_tx_o),
	//.rts_pad_o	(),
	//.dtr_pad_o	(),

	// Inputs
	//.cts_pad_i	(1'b0),
	//.dsr_pad_i	(1'b0),
	//.ri_pad_i	(1'b0),
	//.dcd_pad_i	(1'b0),
	.srx_pad_i	(uart0_rx_i)
);

////////////////////////////////////////////////////////////////////////
//
// picorv32 CPU
//
////////////////////////////////////////////////////////////////////////

wire          picorv32_pcpi_valid;
wire   [31:0] picorv32_pcpi_insn;
wire   [31:0] picorv32_pcpi_rs1;
wire   [31:0] picorv32_pcpi_rs2;
wire          picorv32_pcpi_wr;
wire   [31:0] picorv32_pcpi_rd;
wire          picorv32_pcpi_wait;
wire          picorv32_pcpi_ready;

wire [31:0] picorv32_irq;
wire [31:0] picorv32_eoi;

wire        picorv32_trace_valid;
wire [35:0] picorv32_trace_data;

wire        picorv32_mem_instr;

picorv32_wb #(
	.PROGADDR_RESET (`BOOT_PC),
	.PROGADDR_IRQ   (`IRQ_PC),
	.COMPRESSED_ISA (`PICORV32_COMPRESS_ISA)
) picorv32_wb (
	.wb_clk_i(wb_clk),
	.wb_rst_i(wb_rst),

	.wbm_cyc_o(wb_m2s_picorv32_cyc),
	.wbm_stb_o(wb_m2s_picorv32_stb),
	.wbm_adr_o(wb_m2s_picorv32_adr),
	.wbm_dat_o(wb_m2s_picorv32_dat),
	.wbm_we_o (wb_m2s_picorv32_we ),
	.wbm_sel_o(wb_m2s_picorv32_sel),
	.wbm_ack_i(wb_s2m_picorv32_ack),
	.wbm_dat_i(wb_s2m_picorv32_dat),

	.irq(picorv32_irq),
	.eoi(picorv32_eoi),

	.trace_valid(picorv32_trace_valid),
	.trace_data(picorv32_trace_data),

	.mem_instr(picorv32_mem_instr)
);

localparam [2:0] BTE_LINEAR = 2'b00;
localparam [2:0] CTI_CLASSIC = 3'b000;
assign wb_m2s_picorv32_bte = BTE_LINEAR;
assign wb_m2s_picorv32_cti = CTI_CLASSIC;

assign picorv32_irq[0]  = 0; // picorv32 timer irq
assign picorv32_irq[1]  = 0; // ebreak/ecall/illegal insn
assign picorv32_irq[2]  = 0; // bus error
assign picorv32_irq[3]  = uart0_irq;
assign picorv32_irq[4]  = 0;
assign picorv32_irq[5]  = 0;
assign picorv32_irq[6]  = 0;
assign picorv32_irq[7]  = 0;
assign picorv32_irq[8]  = 0;
assign picorv32_irq[9]  = 0;
assign picorv32_irq[10] = 0;
assign picorv32_irq[11] = 0;
assign picorv32_irq[12] = 0;
assign picorv32_irq[13] = 0;
assign picorv32_irq[14] = 0;
assign picorv32_irq[15] = 0;
assign picorv32_irq[16] = 0;
assign picorv32_irq[17] = 0;
assign picorv32_irq[18] = 0;
assign picorv32_irq[19] = 0;
assign picorv32_irq[20] = 0;
assign picorv32_irq[21] = 0;
assign picorv32_irq[22] = 0;
assign picorv32_irq[23] = 0;
assign picorv32_irq[24] = 0;
assign picorv32_irq[25] = 0;
assign picorv32_irq[26] = 0;
assign picorv32_irq[27] = 0;
assign picorv32_irq[28] = 0;
assign picorv32_irq[29] = 0;
assign picorv32_irq[30] = 0;
assign picorv32_irq[31] = 0;

endmodule
