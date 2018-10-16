
SIM_TOP = top_tb
LIB_NAME = bench

LOG_FILE = compile.log
ARG_FILE = arg.lst
WAVE_FILE = ../vcs/waves.fsdb

PWD = $(shell pwd)
PROJECT_ROOT = $(PWD)/../../..
RTL_VERILOG_DIR = $(PROJECT_ROOT)/hw/rtl
RTL_VERILOG_MODULES = include mor1kx wb_intercon wb_sram uart16550 gpio
BENCH_VERILOG_DIR = $(PROJECT_ROOT)/hw/sim/bench
BENCH_VERILOG_MODULES = soc_top top_tb

DEPEND_DIR = depend

VERICOM_CMD = vericom
VERICOM_CMD_FLAGS = -lib $(LIB_NAME) -nlog $(LOG_FILE) -timescale=1ns/100ps
VERICOM_OPTS = +v2k -sverilog +define+DEBUG_MODULE

all: $(DEPEND_DIR)/.compile_done

$(ARG_FILE):
	@if [ ! -d $(DEPEND_DIR) ]; then \
		mkdir -p $(DEPEND_DIR); \
	fi; \
	if [ ! -e $(ARG_FILE) ]; then \
		echo "$(VERICOM_OPTS)" >> $(ARG_FILE); \
		for dir in $(BENCH_VERILOG_MODULES); do \
			echo "+incdir+$(BENCH_VERILOG_DIR)/$$dir" >> $(ARG_FILE); \
			vfiles=`ls $(BENCH_VERILOG_DIR)/$$dir/*.v`; \
			for f in $$vfiles; do \
				echo $$f >> $(ARG_FILE); \
			done; \
		done; \
		for dir in $(RTL_VERILOG_MODULES); do \
			echo "+incdir+$(RTL_VERILOG_DIR)/$$dir" >> $(ARG_FILE); \
			vfiles=`ls $(RTL_VERILOG_DIR)/$$dir/*.v`; \
			for f in $$vfiles; do \
				echo $$f >> $(ARG_FILE); \
			done; \
		done; \
	fi;

$(DEPEND_DIR)/.compile_done: $(ARG_FILE)
	@if [ ! -e $(ARG_FILE) ]; then \
		echo "No $(ARG_FILE) is found!!!"; \
		exit 0; \
	else \
		$(VERICOM_CMD) $(VERICOM_CMD_FLAGS) -file $(ARG_FILE); \
		grep -P "Total\t0 error" $(LOG_FILE); \
		ret=$$?; \
		if test $$ret -eq 0; then \
			touch $(DEPEND_DIR)/.compile_done; \
			echo "==== Compile done ===="; \
		else \
			echo "==== Compile failed ===="; \
		fi; \
	fi;

run_verdi: $(DEPEND_DIR)/.compile_done
	@if [ -e $(WAVE_FILE) ]; then \
		verdi -lib $(LIB_NAME) -top $(SIM_TOP) -ssf $(WAVE_FILE); \
	else \
		verdi -lib $(LIB_NAME) -top $(SIM_TOP); \
	fi;

clean:
	rm -f $(ARG_FILE)
	rm -fr $(DEPEND_DIR)
	rm -fr $(LIB_NAME).lib++
	rm -fr nWaveLog
	rm -fr verdiLog
	rm -fr vericomLog
	rm -f *.key
	rm -f *.log
	rm -f *.vcd *.fsdb
