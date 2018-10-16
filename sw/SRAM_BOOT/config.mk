#########################################################################

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

LDSCRIPT_SRC := $(TOPDIR)/hal/boot.lds.S
LDSCRIPT := $(TOPDIR)/hal/boot.lds

GCC_INC_DIR := $(shell $(CC) -print-file-name=include)

# clean the slate ...
AFLAGS =
CFLAGS =
CPPFLAGS =
LDFLAGS  =
LDSCRIPT_CPPFLAGS =
ARFLAGS =

CFLAGS += -march=rv32i -mabi=ilp32
#CFLAGS += -march=rv32ic -mabi=ilp32
CFLAGS += -mcmodel=medany -mexplicit-relocs
CFLAGS += -static -std=gnu99
CFLAGS += -g
CFLAGS += -O2 -fno-inline
CFLAGS += -fno-common
CFLAGS += -ffunction-sections -fdata-sections
CFLAGS += -fno-builtin-putc -fno-builtin-puts -fno-builtin-snprintf -fno-builtin-printf
CFLAGS += -fno-builtin -ffreestanding -nostdinc \
	  -isystem $(TOPDIR)/include -isystem $(GCC_INC_DIR)
CFLAGS += -Wall -Wstrict-prototypes
LDFLAGS += -static -strip-debug -nostdlib -nostartfiles
LDFLAGS += -gc-sections
LDFLAGS += -Bstatic -T $(LDSCRIPT)
CPPFLAGS = -isystem $(TOPDIR)/include -isystem $(GCC_INC_DIR)
LDSCRIPT_CPPFLAGS = -I . -I $(TOPDIR)/include
AFLAGS += -D__ASSEMBLY__ $(CFLAGS)
ifneq (,$(findstring s,$(MAKEFLAGS)))
ARFLAGS += cr
else
ARFLAGS += crv
endif

#########################################################################

CONFIG_SHELL	:= $(shell if [ -x "$$BASH" ]; then echo $$BASH; \
		    else if [ -x /bin/bash ]; then echo /bin/bash; \
		    else echo sh; fi ; fi)

HOSTCC		= gcc
HOSTCFLAGS	= -Wall -Wstrict-prototypes -pipe
HOSTSTRIP	= strip

#########################################################################
#
# Option checker (courtesy linux kernel) to ensure
# only supported compiler options are used
#
cc-option = $(shell if $(CC) $(CFLAGS) $(1) -S -o /dev/null -xc /dev/null \
		> /dev/null 2>&1; then echo "$(1)"; else echo "$(2)"; fi ;)

#########################################################################

export CONFIG_SHELL HOSTCC HOSTCFLAGS CROSS_COMPILE \
	AS LD CC CPP AR NM STRIP OBJCOPY OBJDUMP \
	MAKE
export CPPFLAGS AFLAGS CFLAGS ARFLAGS LDSCRIPT LDSCRIPT_SRC LDSCRIPT_CPPFLAGS

#########################################################################

%.s:	%.S
	$(CPP) $(AFLAGS) -o $@ $<
%.o:	%.S
	$(CC) $(AFLAGS) -c -o $@ $<
%.o:	%.c
	$(CC) $(CFLAGS) -c -o $@ $<

#########################################################################
