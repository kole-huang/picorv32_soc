
# This is the testbench you want to simulate
SIM_TOP = top_tb

NCSIM_TCL_FILE = nc.tcl
NCSIM_CMD_FILE = nc.cmd

PWD = $(shell pwd)
PROJECT_ROOT = $(PWD)/../../..
RTL_VERILOG_DIR = $(PROJECT_ROOT)/hw/rtl
RTL_VERILOG_MODULES = include picorv32 wb_intercon wb_sram uart16550 gpio
BENCH_VERILOG_DIR = $(PROJECT_ROOT)/hw/sim/bench
BENCH_VERILOG_MODULES = soc_top top_tb

CDSLIB = cds.lib
WORK = work
WORK_TOP_DIR = sim
WORK_DIR = $(WORK_TOP_DIR)/$(WORK)
DEPEND_DIR = depend

NCVLOG_CMD = ncvlog
NCVLOG_OPTS = $(NCVLOG_INCLUDE_OPTS) -DEFINE SIM -VTIMESCALE 1ns/100ps -WORK $(WORK) -CDSLIB $(CDSLIB) -LOGFILE ncvlog.log -ERRORMAX 15 -UPDATE -LINEDEBUG -STATUS

NCELAB_CMD = ncelab
NCELAB_OPTS = -TIMESCALE 1ns/100ps -WORK $(WORK) -CDSLIB $(CDSLIB) -LOGFILE ncelab.log -ERRORMAX 15 -ACCESS +rwc -STATUS

NCSIM_CMD = ncsim
NCSIM_OPTS = -CDSLIB $(CDSLIB) -LOGFILE ncsim.log -ERRORMAX 15 -STATUS -SCSYNCEVERYDELTA off
NCSIM_OPTS+=$(shell if [ -e $(NCSIM_TCL_FILE) ]; then \
		echo -input $(NCSIM_TCL_FILE); fi;)
NCSIM_OPTS+=$(shell if [ -e $(NCSIM_CMD_FILE) ]; then \
		echo -file $(NCSIM_CMD_FILE); fi;)

ARG_FILE = arg.lst

all: $(DEPEND_DIR)/.update_done

$(ARG_FILE):
	@if [ ! -d $(DEPEND_DIR) ]; then \
		mkdir -p $(DEPEND_DIR); \
	fi; \
	if [ ! -d $(WORK_DIR) ]; then \
		mkdir -p $(WORK_DIR); \
	fi; \
	if [ ! -e cds.lib ]; then \
		echo "include \$$CDS_INST_DIR/tools/inca/files/cds.lib" >> cds.lib; \
		echo "define $(WORK) $(WORK_DIR)" > cds.lib; \
	fi; \
	if [ ! -e hdl.var ]; then \
		echo "include \$$CDS_INST_DIR/tools/inca/files/hdl.var" >> hdl.var; \
		echo "define $(WORK) $(WORK_DIR)" > hdl.var; \
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
		echo $(NCVLOG_OPTS) >> $(ARG_FILE); \
		for dir in $(BENCH_VERILOG_MODULES); do \
			if [ ! -d $(BENCH_VERILOG_DIR)/$$dir ]; then \
				echo "not exist $(BENCH_VERILOG_DIR)/$$dir"; \
			fi; \
			echo "-INCDIR $(BENCH_VERILOG_DIR)/$$dir" >> $(ARG_FILE); \
			vfiles=`ls $(BENCH_VERILOG_DIR)/$$dir/*.v`; \
			for f in $$vfiles; do \
				echo $$f >> $(ARG_FILE); \
			done; \
		done; \
		for dir in $(RTL_VERILOG_MODULES); do \
			if [ ! -d $(RTL_VERILOG_DIR)/$$dir ]; then \
				echo "not exist $(RTL_VERILOG_DIR)/$$dir"; \
			fi; \
			echo "-INCDIR $(RTL_VERILOG_DIR)/$$dir" >> $(ARG_FILE); \
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
		ncvlog -f $(ARG_FILE); \
		if [ $$? -ne 0 ]; then \
			echo "ncvlog failed"; \
			exit 0; \
		fi; \
		touch $(DEPEND_DIR)/.compile_done; \
		echo "==== Compile done ===="; \
	fi

$(DEPEND_DIR)/.elaborate_done: $(DEPEND_DIR)/.compile_done
	@if [ ! -e $(DEPEND_DIR)/.compile_done ]; then \
		exit 0; \
	else \
		$(NCELAB_CMD) $(NCELAB_OPTS) $(SIM_TOP); \
		if [ $$? -ne 0 ]; then \
			echo "ncelab failed"; \
			exit 0; \
		fi; \
		touch $(DEPEND_DIR)/.elaborate_done; \
		echo "==== Elaborate done ===="; \
	fi

$(DEPEND_DIR)/.update_done: $(DEPEND_DIR)/.elaborate_done
	@if [ ! -e $(DEPEND_DIR)/.elaborate_done ]; then \
		exit 0; \
	else \
		ncupdate $(SIM_TOP); \
		if [ $$? -ne 0 ]; then \
			echo "ncupdate failed"; \
			exit 0; \
		fi; \
		touch $(DEPEND_DIR)/.update_done; \
		echo "==== Update done ===="; \
	fi

run_ncsim: all
	@if [ ! -e $(DEPEND_DIR)/.elaborate_done ]; then \
		exit 0; \
	else \
		$(NCSIM_CMD) $(NCSIM_OPTS) $(SIM_TOP); \
	fi

run_ncsim_gui: all
	@if [ ! -e $(DEPEND_DIR)/.elaborate_done ]; then \
		exit 0; \
	else \
		$(NCSIM_CMD) $(NCSIM_OPTS) -gui $(SIM_TOP); \
	fi &

run_hal: all
	@if [ ! -e $(DEPEND_DIR)/.elaborate_done ]; then \
		exit 0; \
	else \
		hal $(SIM_TOP); \
	fi

run_hal_gui: hal
	@if [ ! -e $(DEPEND_DIR)/.elaborate_done ]; then \
		exit 0; \
	else \
		hal -gui $(SIM_TOP); \
	fi &

clean:
	rm -f $(ARG_FILE)
	rm -fr $(DEPEND_DIR)
	rm -fr $(WORK_TOP_DIR)
	rm -f hdl.var cds.lib
	rm -f *.key
	rm -f *.log
	rm -f *.vcd
	rm -fr waves.shm
	rm -fr .simvision
