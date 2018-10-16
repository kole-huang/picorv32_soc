# "vivado -mode batch -source syn_proj.tcl" 
set proj_name "picorv32_soc"
set top_module_name "fpga_top"
set script_dir [file dirname [info script]]
set work_dir [file normalize $script_dir/syn]
set ip_module_dir [file normalize $script_dir/rtl/board/ip]
set fpga_part "xc7k325tffg900-2"

# Create project
file delete -force $work_dir
create_project $proj_name "$work_dir/"

# Set project properties
set obj [get_projects $proj_name]
set_property "default_lib" "xil_defaultlib" $obj
set_property "part" $fpga_part $obj
set_property "source_mgmt_mode" "DisplayOnly" $obj
set_property "target_language" "Verilog" $obj
set_property "simulator_language" "Mixed" $obj

# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets sources_1] ""]} {
  create_fileset -srcset sources_1
}

# Set 'sources_1' fileset properties
set obj [get_filesets sources_1]

# Set top module name
set_property "top" $top_module_name $obj
set_property verilog_define [list XILINX_FPGA FPGA_DEBUG=1] $obj

# Add files to 'sources_1' fileset
add_files -norecurse -fileset $obj [glob "$script_dir/rtl/top/*.v"]
add_files -norecurse -fileset $obj [glob "$script_dir/rtl/board/*.v"]
add_files -norecurse -fileset $obj [glob "$script_dir/../../rtl/picorv32/*.v"]
add_files -norecurse -fileset $obj [glob "$script_dir/../../rtl/wb_intercon/*.v"]
add_files -norecurse -fileset $obj [glob "$script_dir/../../rtl/wb_sram/*.v"]
add_files -norecurse -fileset $obj [glob "$script_dir/../../rtl/uart16550/*.v"]
add_files -norecurse -fileset $obj [glob "$script_dir/../../rtl/gpio/*.v"]

# add include path
# sram_boot.hex is in $script_dir,
# add $script_dir into include path for $readmemh in wb_sram_generic module
set_property include_dirs [list \
  [file normalize $script_dir/rtl/top] \
  [file normalize $script_dir/rtl/board] \
  [file normalize $script_dir/../../rtl/include] \
  [file normalize $script_dir/../../rtl/picorv32] \
  [file normalize $script_dir/../../rtl/wb_intercon] \
  [file normalize $script_dir/../../rtl/wb_sram] \
  [file normalize $script_dir/../../rtl/uart16550] \
  [file normalize $script_dir/../../rtl/gpio] \
  [file normalize $script_dir] \
] $obj

# add IPs
#add_files -norecurse -fileset $obj [file normalize "$ip_module_dir/sys_mmcm_clk/sys_mmcm_clk.xci"]
import_ip [file normalize "$ip_module_dir/sys_mmcm_clk/sys_mmcm_clk.xci"]
upgrade_ip [get_ips]
generate_target -force {instantiation_template synthesis} [get_ips sys_mmcm_clk]

# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

# Add files to 'constrs_1' fileset
set obj [get_filesets constrs_1]

add_files -fileset $obj -norecurse "[file normalize "$work_dir/../board.xdc"]"

# Create 'sim_1' fileset (if not found)
if {[string equal [get_filesets sim_1] ""]} {
  create_fileset -simset sim_1
}

# Add files to 'sim_1' fileset
set obj [get_filesets sim_1]

add_files -norecurse -fileset $obj [glob "$script_dir/sim/*.v"]

# add include path
set_property include_dirs [list \
	[file normalize $script_dir/sim] \
] $obj

# Set 'sim_1' fileset properties
set_property "runtime" "1000 ns" $obj
set_property "top" $top_module_name $obj
set_property "xelab.nosort" "1" $obj
set_property "xelab.unifast" "" $obj

add_files -norecurse [glob "$script_dir/sram_boot.hex"]

# Create 'synth_1' run (if not found)
if {[string equal [get_runs synth_1] ""]} {
  create_run -name synth_1 -part $fpga_part -flow {Vivado Synthesis 2017} -strategy "Vivado Synthesis Defaults" -constrset constrs_1
} else {
  set_property strategy "Vivado Synthesis Defaults" [get_runs synth_1]
  set_property flow "Vivado Synthesis 2017" [get_runs synth_1]
}
set obj [get_runs synth_1]
set_property "part" $fpga_part $obj

# Create 'impl_1' run (if not found)
if {[string equal [get_runs impl_1] ""]} {
  create_run -name impl_1 -part $fpga_part -flow {Vivado Implementation 2017} -strategy "Vivado Implementation Defaults" -constrset constrs_1 -parent_run synth_1
} else {
  set_property strategy "Vivado Implementation Defaults" [get_runs impl_1]
  set_property flow "Vivado Implementation 2017" [get_runs impl_1]
}
set obj [get_runs impl_1]
set_property "part" $fpga_part $obj
set_property STEPS.PHYS_OPT_DESIGN.IS_ENABLED true $obj
set_property STEPS.POST_ROUTE_PHYS_OPT_DESIGN.IS_ENABLED true $obj
set_property STEPS.WRITE_BITSTREAM.TCL.PRE "$work_dir/../showstopper.tcl" $obj

puts "INFO: Project created: $proj_name"

# Uncomment the two following lines for a full implementation
launch_runs -jobs 2 impl_1 -to_step write_bitstream
wait_on_run impl_1

