##############################################################################
##      _______      _______                                                ##
##     / ____\ \    / /_   _|                                               ##
##    | |  __ \ \  / /  | |                                                 ##
##    | | |_ | \ \/ /   | |                                                 ##
##    | |__| |  \  /   _| |_                                                ##
##     \_____|   \/   |_____|                                               ##
##                                                                          ##
## Copyright (c) 2012-2017 GVI.  All rights reserved.                       ##
##                                                                          ##
## THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY   ##
## KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE      ##
## IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A               ##
## PARTICULAR PURPOSE.                                                      ##
##                                                                          ##
## Website: http://www.gvi-tech.com/                                        ##
## Email: support@gvi-tech.com                                              ##
##                                                                          ##
##############################################################################

set_property BITSTREAM.CONFIG.BPI_SYNC_MODE Type2 [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN div-1 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property CONFIG_VOLTAGE 2.5 [current_design]
set_property CFGBVS VCCO [current_design]

set_property IOSTANDARD LVDS [get_ports SYS_CLK_P]
set_property IOSTANDARD LVDS [get_ports SYS_CLK_N]
set_property PACKAGE_PIN AD12 [get_ports SYS_CLK_P]
set_property PACKAGE_PIN AD11 [get_ports SYS_CLK_N]
create_clock -period 5.000 -name SYS_CLK_P [get_ports SYS_CLK_P]

set_property PACKAGE_PIN K13 [get_ports RST]
set_property PULLDOWN TRUE [get_ports RST]
set_property IOSTANDARD LVCMOS33 [get_ports RST]

set_property PACKAGE_PIN F16 [get_ports UART_RX]
set_property IOSTANDARD LVCMOS33 [get_ports UART_RX]
set_property PACKAGE_PIN E16 [get_ports UART_TX]
set_property IOSTANDARD LVCMOS33 [get_ports UART_TX]

set_property PACKAGE_PIN AB8 [get_ports {DIP_SWITCH[0]}]
set_property IOSTANDARD LVCMOS15 [get_ports {DIP_SWITCH[0]}]
set_property PACKAGE_PIN AA8 [get_ports {DIP_SWITCH[1]}]
set_property IOSTANDARD LVCMOS15 [get_ports {DIP_SWITCH[1]}]
set_property PACKAGE_PIN AB12 [get_ports {DIP_SWITCH[2]}]
set_property IOSTANDARD LVCMOS15 [get_ports {DIP_SWITCH[2]}]
set_property PACKAGE_PIN AA12 [get_ports {DIP_SWITCH[3]}]
set_property IOSTANDARD LVCMOS15 [get_ports {DIP_SWITCH[3]}]

set_property PACKAGE_PIN K15 [get_ports {PUSH_BUTTON[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {PUSH_BUTTON[0]}]
set_property PACKAGE_PIN L12 [get_ports {PUSH_BUTTON[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {PUSH_BUTTON[1]}]

set_property PACKAGE_PIN L20 [get_ports {LED[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {LED[0]}]
set_property PACKAGE_PIN M20 [get_ports {LED[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {LED[1]}]
set_property PACKAGE_PIN J22 [get_ports {LED[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {LED[2]}]
set_property PACKAGE_PIN J21 [get_ports {LED[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {LED[3]}]
set_property PACKAGE_PIN K21 [get_ports {LED[4]}]
set_property IOSTANDARD LVCMOS25 [get_ports {LED[4]}]
set_property PACKAGE_PIN L21 [get_ports {LED[5]}]
set_property IOSTANDARD LVCMOS25 [get_ports {LED[5]}]
set_property PACKAGE_PIN K24 [get_ports {LED[6]}]
set_property IOSTANDARD LVCMOS25 [get_ports {LED[6]}]
set_property PACKAGE_PIN K23 [get_ports {LED[7]}]
set_property IOSTANDARD LVCMOS25 [get_ports {LED[7]}]

