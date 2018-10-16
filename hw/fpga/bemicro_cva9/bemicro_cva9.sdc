#**************************************************************
# Create Clock
#**************************************************************
create_clock -name CLK_24M -period "24MHz" [get_ports {CLK_24M}]
create_clock -name DDR3_CLK_50M -period "50MHz" [get_ports {DDR3_CLK_50M}]

#constrain the TCK port
create_clock -name {altera_reserved_tck} -period "10MHz" {altera_reserved_tck}
#constrain the TDI port
set_input_delay -clock altera_reserved_tck -clock_fall 1 [get_ports altera_reserved_tdi]
#constrain the TMS port
set_input_delay -clock altera_reserved_tck -clock_fall 1 [get_ports altera_reserved_tms]
#constrain the TDO port
set_output_delay -clock altera_reserved_tck -clock_fall 1 [get_ports altera_reserved_tdo]

#**************************************************************
# Create Generated Clock
#**************************************************************

#**************************************************************
# Automatically constrain PLL and other generated clocks
#**************************************************************
derive_pll_clocks -create_base_clocks

#**************************************************************
# Automatically calculate clock uncertainty to jitter and other effects.
#**************************************************************
derive_clock_uncertainty

set_false_path -from [get_ports KEY[0]]

