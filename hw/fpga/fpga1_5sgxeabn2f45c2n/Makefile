
SYN_TOP = fpga_top
BOARD = fpga1_5sgxeabn2f45c2n

BOARD_TEMPLATE_TCL_FILE = $(BOARD).tcl
BOARD_TEMPLATE_SDC_FILE = $(BOARD).sdc
TCL_FILE = $(SYN_TOP).tcl
SDC_FILE = $(SYN_TOP).sdc
PIN_ASSIGNMENT_FILE = $(SYN_TOP).pin

ifdef MINGW
PWD = $(shell (pwd -W))
else
PWD = $(shell pwd)
endif

SYN_ROOT_DIR = $(PWD)
SYN_RUN_DIR = $(PWD)/run

RTL_VERILOG_DIR = $(SYN_RUN_DIR)/../../../rtl
RTL_VERILOG_MODULES = include picorv32 wb_intercon wb_sram uart16550 gpio
BOARD_RTL_VERILOG_DIR = $(SYN_RUN_DIR)/../rtl
BOARD_RTL_VERILOG_MODULES = top board

all: depend sta

depend:
	@if [ ! -d $(SYN_RUN_DIR) ]; then \
		mkdir -p $(SYN_RUN_DIR); \
	fi;
	@echo "" > $(SYN_RUN_DIR)/timescale.v
	@if [ ! -f $(BOARD_TEMPLATE_TCL_FILE) ]; then \
		exit 1; \
	fi;

$(SYN_RUN_DIR)/$(TCL_FILE):
	@echo "#### Generating TCL file ####"
	@echo "project_new $(SYN_TOP) -overwrite" >> $@
	@cat $(BOARD_TEMPLATE_TCL_FILE) >> $@
	@echo "set_global_assignment -name TOP_LEVEL_ENTITY \"$(SYN_TOP)\"" >> $@
	@echo "set_global_assignment -name SDC_FILE $(SDC_FILE)" >> $@
	@if [ -f $(BOARD_TEMPLATE_SDC_FILE) ]; then \
		cp $(BOARD_TEMPLATE_SDC_FILE) $(SYN_RUN_DIR)/$(SDC_FILE); \
	fi;
	@echo "set_global_assignment -name SEARCH_PATH $(SYN_RUN_DIR)" >> $@
	@for dir in $(BOARD_RTL_VERILOG_MODULES); do \
		echo "set_global_assignment -name SEARCH_PATH $(BOARD_RTL_VERILOG_DIR)/$$dir" >> $@; \
	done;
	@for dir in $(RTL_VERILOG_MODULES); do \
		echo "set_global_assignment -name SEARCH_PATH $(RTL_VERILOG_DIR)/$$dir" >> $@; \
	done;
	@for dir in $(BOARD_RTL_VERILOG_MODULES); do \
		vfiles=`ls $(BOARD_RTL_VERILOG_DIR)/$$dir/*.v`; \
		for file in $$vfiles; do \
			 echo "set_global_assignment -name VERILOG_FILE $$file" >> $@; \
		done; \
	done;
	@for dir in $(RTL_VERILOG_MODULES); do \
		vfiles=`ls $(RTL_VERILOG_DIR)/$$dir/*.v`; \
		for file in $$vfiles; do \
			 echo "set_global_assignment -name VERILOG_FILE $$file" >> $@; \
		done; \
	done;
	@cp -f sram_boot.mif $(SYN_RUN_DIR)
	@echo "project_close" >> $@

project: $(SYN_RUN_DIR)/$(TCL_FILE)
	@echo "#### Generating project files ####"
	cd $(SYN_RUN_DIR) && quartus_sh -t $(TCL_FILE)

map: project
	@echo "#### Do map ####"
	cd $(SYN_RUN_DIR) && quartus_map $(SYN_TOP)

fit: map
	@echo "#### Do fit ####"
	cd $(SYN_RUN_DIR) && quartus_fit $(SYN_TOP)

asm: fit
	@echo "#### Do asm ####"
	cd $(SYN_RUN_DIR) && quartus_asm $(SYN_TOP)

sta: asm
	@echo "#### Do sta ####"
	cd $(SYN_RUN_DIR) && quartus_sta $(SYN_TOP)

pgm:
	@echo "#### Do pgm ####"
	cd $(SYN_RUN_DIR) && quartus_pgm --mode=jtag -o p\;$(SYN_TOP).sof

clean:
	@if [ -d $(SYN_RUN_DIR) ]; then \
		rm -fr $(SYN_RUN_DIR); \
	fi;

distclean: clean

