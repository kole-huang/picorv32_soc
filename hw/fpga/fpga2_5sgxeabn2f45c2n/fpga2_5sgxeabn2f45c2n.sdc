#**************************************************************
# Time Information
#**************************************************************
set_time_format -unit ns -decimal_places 3

#**************************************************************
# Create Clock
#**************************************************************
create_clock -name {svb_clk_p} -period 10.000 -waveform { 0.000 5.000 } [get_ports { svb_clk_p }]
create_clock -name {svb_clk_125_p} -period 8.000 -waveform { 0.000 4.000 } [get_ports { svb_clk_125_p }]
create_clock -name {svb_clk_50} -period 20.000 -waveform { 0.000 10.000 } [get_ports { svb_clk_50 }]
create_clock -name {clkinbotb_ddr3_p} -period 10.000 -waveform { 0.000 5.000 } [get_ports { clkinbotb_ddr3_p }]
create_clock -name {clkintopb_ddr3_p} -period 10.000 -waveform { 0.000 5.000 } [get_ports { clkintopb_ddr3_p }]
create_clock -name {altera_reserved_tck} -period "40.000ns" {altera_reserved_tck}

#**************************************************************
# Create Generated Clock
#**************************************************************


#**************************************************************
# Set Clock Latency
#**************************************************************


#**************************************************************
# Set Clock Uncertainty
#**************************************************************
set_clock_uncertainty -rise_from [get_clocks {svb_clk_p}] -rise_to [get_clocks {svb_clk_p}] 0.020  
set_clock_uncertainty -rise_from [get_clocks {svb_clk_p}] -fall_to [get_clocks {svb_clk_p}] 0.020  
set_clock_uncertainty -fall_from [get_clocks {svb_clk_p}] -rise_to [get_clocks {svb_clk_p}] 0.020  
set_clock_uncertainty -fall_from [get_clocks {svb_clk_p}] -fall_to [get_clocks {svb_clk_p}] 0.020  
set_clock_uncertainty -rise_from [get_clocks {svb_clk_125_p}] -rise_to [get_clocks {svb_clk_125_p}] 0.020  
set_clock_uncertainty -rise_from [get_clocks {svb_clk_125_p}] -fall_to [get_clocks {svb_clk_125_p}] 0.020  
set_clock_uncertainty -fall_from [get_clocks {svb_clk_125_p}] -rise_to [get_clocks {svb_clk_125_p}] 0.020  
set_clock_uncertainty -fall_from [get_clocks {svb_clk_125_p}] -fall_to [get_clocks {svb_clk_125_p}] 0.020  
set_clock_uncertainty -rise_from [get_clocks {svb_clk_50}] -rise_to [get_clocks {svb_clk_50}] 0.020  
set_clock_uncertainty -rise_from [get_clocks {svb_clk_50}] -fall_to [get_clocks {svb_clk_50}] 0.020  
set_clock_uncertainty -fall_from [get_clocks {svb_clk_50}] -rise_to [get_clocks {svb_clk_50}] 0.020  
set_clock_uncertainty -fall_from [get_clocks {svb_clk_50}] -fall_to [get_clocks {svb_clk_50}] 0.020  
set_clock_uncertainty -rise_from [get_clocks {clkinbotb_ddr3_p}] -rise_to [get_clocks {clkinbotb_ddr3_p}] 0.020  
set_clock_uncertainty -rise_from [get_clocks {clkinbotb_ddr3_p}] -fall_to [get_clocks {clkinbotb_ddr3_p}] 0.020  
set_clock_uncertainty -fall_from [get_clocks {clkinbotb_ddr3_p}] -rise_to [get_clocks {clkinbotb_ddr3_p}] 0.020  
set_clock_uncertainty -fall_from [get_clocks {clkinbotb_ddr3_p}] -fall_to [get_clocks {clkinbotb_ddr3_p}] 0.020  
set_clock_uncertainty -rise_from [get_clocks {clkintopb_ddr3_p}] -rise_to [get_clocks {clkintopb_ddr3_p}] 0.020  
set_clock_uncertainty -rise_from [get_clocks {clkintopb_ddr3_p}] -fall_to [get_clocks {clkintopb_ddr3_p}] 0.020  
set_clock_uncertainty -fall_from [get_clocks {clkintopb_ddr3_p}] -rise_to [get_clocks {clkintopb_ddr3_p}] 0.020  
set_clock_uncertainty -fall_from [get_clocks {clkintopb_ddr3_p}] -fall_to [get_clocks {clkintopb_ddr3_p}] 0.020  

#**************************************************************
# Set Clock Groups
#**************************************************************


#**************************************************************
# Set Input Delay
#**************************************************************
set_input_delay -clock altera_reserved_tck 5 [get_ports altera_reserved_tdi]
set_input_delay -clock altera_reserved_tck 5 [get_ports altera_reserved_tms]


#**************************************************************
# Set Output Delay
#**************************************************************
set_output_delay -clock altera_reserved_tck -clock_fall -fall -max 5 [get_ports altera_reserved_tdo]


#**************************************************************
# Set Multicycle Path
#**************************************************************


#**************************************************************
# Set Maximum Delay
#**************************************************************


#**************************************************************
# Set Minimum Delay
#**************************************************************


#**************************************************************
# Set False Path
#**************************************************************
set_false_path -from eeprom* -to *
set_false_path -from * -to eeprom*

set_false_path -to [get_ports {fpga2_*}]
set_false_path -from [get_ports {fpga2_*}] 

