
CONFIG_FSDB := 0

SIM_PROG = simv

SIM_TOP = top_tb

PWD = $(shell pwd)
PROJECT_ROOT = $(PWD)/../../..
RTL_VERILOG_DIR = $(PROJECT_ROOT)/hw/rtl
RTL_VERILOG_MODULES = include picorv32 wb_intercon wb_sram uart16550 gpio
BENCH_VERILOG_DIR = $(PROJECT_ROOT)/hw/sim/bench
BENCH_VERILOG_MODULES = soc_top top_tb

ifeq ($(CONFIG_FSDB),1)
VERDI_PLI_VCS_DIR = /opt/Synopsys/verdi/J-2014.12-SP2/share/PLI/VCS/LINUX64
endif

DEPEND_DIR = depend

CC = gcc-4.8
CXX = g++-4.8
CFLAGS = -I${VCS_HOME}/include
CFLAGS += -std=c++11
LDFLAGS = -Wl,--no-as-needed

VCS_CMD = vcs
VCS_CMD_FLAGS = -full64 -l vcs.log -notice -line -debug_all -sverilog -timescale=1ns/100ps
VCS_OPTS += -cc $(CC) -cpp $(CXX) -ld $(CXX)
VCS_OPTS += +lint=all,noVCDE,noONGS,noUI
VCS_OPTS += +rad +v2k +vcs+lic+wait +vc+list
#VCS_OPTS += +vpi -CC \"-DVCS_VPI\"
VCS_OPTS += +define+DEBUG_MODULE
ifeq ($(CONFIG_FSDB),1)
VCS_OPTS += +define+DUMP_FSDB
VCS_OPTS += -P \"$(VERDI_PLI_VCS_DIR)/novas.tab\"
VCS_OPTS += -CC \"-Wl,-rpath,$(VERDI_PLI_VCS_DIR)\"
VCS_OPTS += $(VERDI_PLI_VCS_DIR)/pli.a
endif
VCS_OPTS += -error=noZONMCM
#VCS_OPTS += -quiet

ARG_FILE = arg.lst

all: $(DEPEND_DIR)/.compile_done

$(ARG_FILE):
	@if [ ! -d $(DEPEND_DIR) ]; then \
		mkdir -p $(DEPEND_DIR); \
	fi; \
	if [ ! -d $(BENCH_VERILOG_DIR) ]; then \
		echo "not exist $(BENCH_VERILOG_DIR)"; \
		exit 0; \
	fi; \
	if [ ! -d $(RTL_VERILOG_DIR) ]; then \
		echo "not exist $(RTL_VERILOG_DIR)"; \
		exit 0; \
	fi; \
	if [ ! -e $(ARG_FILE) ]; then \
		echo $(VCS_OPTS) >> $(ARG_FILE); \
		echo "-CFLAGS \"$(CFLAGS)\"" >> $(ARG_FILE); \
		echo "-LDFLAGS \"$(LDFLAGS)\"" >> $(ARG_FILE); \
		echo "-o $(SIM_PROG)" >> $(ARG_FILE); \
		for dir in $(BENCH_VERILOG_MODULES); do \
			if [ ! -d $(BENCH_VERILOG_DIR)/$$dir ]; then \
				echo "not exist $(BENCH_VERILOG_DIR)/$$dir"; \
			fi; \
			echo "+incdir+$(BENCH_VERILOG_DIR)/$$dir" >> $(ARG_FILE); \
			vfiles=`ls $(BENCH_VERILOG_DIR)/$$dir/*.v`; \
			for f in $$vfiles; do \
				echo $$f >> $(ARG_FILE); \
			done; \
		done; \
		for dir in $(RTL_VERILOG_MODULES); do \
			if [ ! -d $(RTL_VERILOG_DIR)/$$dir ]; then \
				echo "not exist $(RTL_VERILOG_DIR)/$$dir"; \
			fi; \
			echo "+incdir+$(RTL_VERILOG_DIR)/$$dir" >> $(ARG_FILE); \
			vfiles=`ls $(RTL_VERILOG_DIR)/$$dir/*.v`; \
			for f in $$vfiles; do \
				echo $$f >> $(ARG_FILE); \
			done; \
		done; \
	fi;

#
# $(SIM_PROG).daidir/libXmap.so should be re-generated
# because the default linking flags does not have "-Wl,--no-as-needed",
# this will make $(SIM_PROG) run abnormally
#
$(DEPEND_DIR)/.compile_done: $(ARG_FILE)
	@if [ ! -e $(ARG_FILE) ]; then \
		echo "No $(ARG_FILE) is found!!!"; \
		exit 0; \
	else \
		$(VCS_CMD) $(VCS_CMD_FLAGS) -file $(ARG_FILE); \
		if [ -e $(SIM_PROG) ]; then \
			if [ -e $(SIM_PROG).daidir/xmap0.so ]; then \
				cd $(SIM_PROG).daidir; \
				$(CXX) -shared $(LDFLAGS) -Wl,-rpath=. -o libXmap.so xmap0.so; \
				cd ..; \
			fi; \
			touch $(DEPEND_DIR)/.compile_done; \
			echo "==== Compile done ===="; \
		else \
			echo "==== Compile failed!! ===="; \
		fi; \
	fi;

ifeq ($(CONFIG_FSDB),1)
run_vcs: $(DEPEND_DIR)/.compile_done
	@echo "Run $(SIM_PROG)..."
	@export LD_LIBRARY_PATH=$(VERDI_PLI_VCS_DIR):$(LD_LIBRARY_PATH); \
	./$(SIM_PROG)
else
run_vcs: $(DEPEND_DIR)/.compile_done
	@echo "Run $(SIM_PROG)..."
	@./$(SIM_PROG)
endif

clean:
	rm -f $(ARG_FILE)
	rm -fr $(DEPEND_DIR)
	rm -f $(SIM_PROG)
	rm -fr csrc $(SIM_PROG).daidir
	rm -f *.key
	rm -f *.log
	rm -f *.vcd *.fsdb
