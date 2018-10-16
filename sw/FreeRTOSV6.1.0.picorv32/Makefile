#---------------------------------------------------------------------------
# Target definition (User)
#---------------------------------------------------------------------------
TARGET		= os

#---------------------------------------------------------------------------
# Define Toolchains
#---------------------------------------------------------------------------
CROSS_COMPILE=~/app/picorv32_toolchain/bin/riscv32-unknown-elf-
export CROSS_COMPILE

AS	= $(CROSS_COMPILE)as
LD	= $(CROSS_COMPILE)ld
CC	= $(CROSS_COMPILE)gcc
CPP	= $(CC) -E
AR	= $(CROSS_COMPILE)ar
NM	= $(CROSS_COMPILE)nm
LDR	= $(CROSS_COMPILE)ldr
STRIP	= $(CROSS_COMPILE)strip
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump
RANLIB	= $(CROSS_COMPILE)RANLIB

LDSCRIPT_SRC	= hal/boot.lds.S
LDSCRIPT	= hal/boot.lds

GCCINCDIR	= $(shell $(CC) -print-file-name=include)

ASFLAGS		=
CFLAGS		=

ASFLAGS		+= -I. -I./include -I./kernel/include -D__ASSEMBLY__
CFLAGS		+= -march=rv32i -mabi=ilp32
CFLAGS		+= -mcmodel=medany -mexplicit-relocs
CFLAGS		+= -static -std=gnu99
CFLAGS		+= -g
CFLAGS		+= -O2 -fno-inline
CFLAGS		+= -fno-common
CFLAGS		+= -ffunction-sections -fdata-sections
CFLAGS		+= -fno-builtin-putc -fno-builtin-puts -fno-builtin-snprintf -fno-builtin-printf
CFLAGS		+= -nostdinc \
		  -isystem $(GCCINCDIR) \
		  -I. -I./include -I./kernel/include -Wall -Wstrict-prototypes \
		  -fomit-frame-pointer -fno-strict-aliasing -fno-common \
		  -fno-builtin -ffreestanding
LDFLAGS		= --gc-sections -nostartfiles -T$(LDSCRIPT)
ARFLAGS		= rcv
LDSCRIPT_CPPFLAGS = -I./include

#---------------------------------------------------------------------------
# Source section (User)
#---------------------------------------------------------------------------
ASM_SRC		=
SYS_SRC		=
OS_SRC		=

ASM_SRC		+= hal/start.S

SYS_SRC		+= hal/hal.c hal/uart.c hal/irq.c
SYS_SRC		+= lib/division.c lib/string.c lib/console.c lib/printf_tiny.c lib/heap_mm.c
SYS_SRC		+= kernel/portable/port.c
SYS_SRC		+= kernel/portable/portISR.c
SYS_SRC		+= kernel/portable/heap.c
SYS_SRC		+= main.c

OS_SRC		+= kernel/tasks.c
OS_SRC		+= kernel/queue.c
OS_SRC		+= kernel/list.c

LIBS		+= $(shell echo `$(CC) $(CFLAGS) -print-file-name=libgcc.a`)
#LIBS		+= $(shell echo `$(CC) $(CFLAGS) -print-file-name=libc.a`)

#---------------------------------------------------------------------------
# Implicit rules
#---------------------------------------------------------------------------
ASM_OBJ		= $(ASM_SRC:%.S=%.o)
SYS_OBJ		= $(SYS_SRC:.c=.o)
OS_OBJ		= $(OS_SRC:.c=.o)

OBJ_FILES	= $(ASM_OBJ) $(SYS_OBJ) $(OS_OBJ)

all: $(TARGET)

$(TARGET): $(LDSCRIPT) $(TARGET).elf sram_boot.hex sram_boot.mif System.map

$(LDSCRIPT): $(LDSCRIPT_SRC) Makefile
	$(CC) $(LDSCRIPT_CPPFLAGS) -E -P -C -o $@ $<

$(TARGET).elf: $(OBJ_FILES) $(LDSCRIPT) Makefile FreeRTOSConfig.h
	$(LD) $(LDFLAGS) --start-group $(OBJ_FILES) --end-group $(LIBS) -Map $(TARGET).map -o $(TARGET).elf
	$(OBJCOPY) --output-target=binary -S -g -x -X -R .sbss -R .bss -R .reginfo $(TARGET).elf $(TARGET).bin
	$(OBJDUMP) -h -d -S $@ > $(TARGET).lst

System.map: $(TARGET).elf
	@$(NM) $< | \
	grep -v '\(compiled\)\|\(\.o$$\)\|\( [aUw] \)\|\(\.\.ng$$\)\|\(LASH[RL]DI\)' | \
	sort > System.map

sram_boot.hex: $(TARGET).bin
	../tools/bin2rtlhex -i $< -o $@ -s -b 32
	cp -f $@ ../../hw/sim/ncsim

sram_boot.mif: $(TARGET).bin
	../tools/bin2mif -i $< -o $@ -s -b 32

.S.o: Makefile FreeRTOSConfig.h
	$(CC) -c $(ASFLAGS) $< -o $@

$(ASM_OBJ) : %.o : %.S $(LDSCRIPT) Makefile
	$(CC) -c $(ASFLAGS) $< -o $@

$(SYS_OBJ) : %.o : %.c $(LDSCRIPT) Makefile FreeRTOSConfig.h
	$(CC) -c $(CFLAGS) $< -o $@

$(OS_OBJ) : %.o : %.c $(LDSCRIPT) Makefile FreeRTOSConfig.h
	$(CC) -c $(CFLAGS) $< -o $@

clean:
	rm -f $(OBJ_FILES:.o=.d) $(OBJ_FILES) $(TARGET).map System.map $(LDSCRIPT)
	rm -f $(TARGET).elf $(TARGET).lst $(TARGET).bin $(TARGET).nm *.bin *.hex *.mif

