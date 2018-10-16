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

`ifndef SOC_DEF
`define SOC_DEF

`define PICORV32_COMPRESS_ISA 0

//`define SOC_BUS_WB_B3

`define SRAM0_TECH_GENERIC
//`define SRAM0_TECH_ALTERA

`define SRAM1_TECH_GENERIC
//`define SRAM1_TECH_ALTERA

`define SRAM0_INIT_MEM_FILE_GENERIC "sram_boot.hex"
`define SRAM0_INIT_MEM_FILE_ALTERA  "sram_boot.mif"

`define SRAM1_INIT_MEM_FILE_GENERIC ""
`define SRAM1_INIT_MEM_FILE_ALTERA  ""

`define SRAM0_BASE 32'h00000000
`define SRAM0_SIZE 32'h00080000
`define SRAM0_MASK (~(`SRAM0_SIZE - 32'h00000001))

`define SRAM1_BASE (`SRAM0_BASE + `SRAM0_SIZE + 32'h00400000)
`define SRAM1_SIZE 32'h00040000
`define SRAM1_MASK (~(`SRAM1_SIZE - 32'h00000001))

`define UART0_BASE 32'h90000000
`define UART0_SIZE 32'h00000020
`define UART0_MASK (~(`UART0_SIZE - 32'h00000001))

`define BOOT_PC (`SRAM0_BASE)
`define IRQ_PC  (`BOOT_PC + 32'h00000010)
`ifdef SRAM0_TECH_GENERIC
`define SRAM0_INIT_MEM_FILE `SRAM0_INIT_MEM_FILE_GENERIC
`elsif SRAM0_TECH_ALTERA
`define SRAM0_INIT_MEM_FILE `SRAM0_INIT_MEM_FILE_ALTERA
`else
// synopsys translate_off
initial begin
   $display("%m : ERROR!!! SRAM0_INIT_MEM_FILE is not assigned!!!");
   $stop;
end
`endif

`ifdef SRAM1_TECH_GENERIC
`define SRAM1_INIT_MEM_FILE `SRAM1_INIT_MEM_FILE_GENERIC
`elsif SRAM1_TECH_ALTERA
`define SRAM1_INIT_MEM_FILE `SRAM1_INIT_MEM_FILE_ALTERA
`else
// synopsys translate_off
initial begin
   $display("%m : ERROR!!! SRAM1_INIT_MEM_FILE is not assigned!!!");
   $stop;
end
`endif

`endif // SOC_DEF

