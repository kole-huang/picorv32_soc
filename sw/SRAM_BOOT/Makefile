
#########################################################################

OBJTREE		:= $(CURDIR)
SRCTREE		:= $(CURDIR)
TOPDIR		:= $(SRCTREE)
LNDIR		:= $(OBJTREE)
export TOPDIR SRCTREE OBJTREE

# Make sure CDPATH settings don't interfere
unexport CDPATH

#########################################################################

# load other configuration
include $(TOPDIR)/config.mk

#########################################################################
TARGET = sram_boot

SUBDIRS = hal lib main
OBJS += hal/start.o
LIBS += hal/lib.a
LIBS += lib/lib.a
LIBS += main/lib.a

.PHONY : $(OBJS) $(LIBS)

# Add GCC lib
PLATFORM_LIBS += -L $(shell dirname `$(CC) $(CFLAGS) -print-libgcc-file-name`) -lgcc

__OBJS := $(OBJS)
__LIBS := $(LIBS)

#########################################################################
#########################################################################

ALL += $(TARGET).dis System.map $(TARGET).bin $(TARGET).hex $(TARGET).mif

all:	$(ALL)

$(TARGET).elf: $(OBJS) $(LIBS) $(LDSCRIPT)
	cd $(LNDIR) && $(LD) $(LDFLAGS) \
	--start-group $(__OBJS) $(__LIBS) --end-group $(PLATFORM_LIBS) \
	-Map $(TARGET).map -o $@

$(TARGET).dis: $(TARGET).elf
	$(OBJDUMP) -S $< > $@

$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@

$(TARGET).hex: $(TARGET).bin
	../tools/bin2rtlhex -i $< -o $@ -s -b 32
	cp -f $@ ../../hw/sim/ncsim

$(TARGET).mif: $(TARGET).bin
	../tools/bin2mif -i $< -o $@ -s -b 32

$(OBJS):
	$(MAKE) -C $(dir $@) $(notdir $@)

$(LIBS):
	$(MAKE) -C $(dir $@)

System.map: $(TARGET).elf
	@$(NM) $< | \
	grep -v '\(compiled\)\|\(\.o$$\)\|\( [aUw] \)\|\(\.\.ng$$\)\|\(LASH[RL]DI\)' | \
	sort > $@

#########################################################################

depend:
	@for dir in $(SUBDIRS) ; do $(MAKE) -C $$dir depend ; done

clean:
	@rm -f $(LDSCRIPT) $(TARGET).elf $(TARGET).bin $(TARGET).dis $(TARGET).map System.map $(TARGET).hex $(TARGET).mif
	@find $(OBJTREE) -type f \
		\( -name 'core' -o -name '*.bak' -o -name '*~' \
		-o -name '*.o'	-o -name '*.a' \) -print \
		| xargs rm -f

#########################################################################
