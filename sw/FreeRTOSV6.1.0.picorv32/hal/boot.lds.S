#include <board.h>

OUTPUT_ARCH("riscv")
OUTPUT_FORMAT("elf32-littleriscv", "elf32-littleriscv", "elf32-littleriscv")
ENTRY(reset_vec)

SECTIONS
{
	. = BOOT_SRAM_PHYS_ADDR;

	.text : { KEEP(*(.vectors*)) *(.text*) }

	.rodata : {
		*(.rodata*)
	}

	.data : {
		*(.data*)
	}

	.sdata : {
		__gp = . + 0x800;
		*(.srodata.cst16*)
		*(.srodata.cst8*)
		*(.srodata.cst4*)
		*(.srodata.cst2*)
		*(.srodata*)
		*(.sdata*)
	}

	. = ALIGN(8);
	__bss_start = .;
	.sbss : {
		*(.sbss*)
		*(.scommon*)
	}

	.bss : { *(.bss*) }

	. = ALIGN(8);
	__bss_end = .;

	/* End of uninitalized data segement */
	__end = .;

	. = ALIGN(0x10);
	__malloc_start = .;
	__malloc_end = __malloc_start + MALLOC_SIZE;

	__stack_top = . + STACK_SIZE;
}

