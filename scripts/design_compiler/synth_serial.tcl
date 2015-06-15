set synt_scr_path "/home/piraten/ael10nal/Desktop/asic_final/script"
source $synt_scr_path/design_setup.tcl

analyze -library WORK -format vhdl {./vhdl/agc_optimized_serial.vhd ./vhdl/gain_lut_dual_input.vhd ./vhdl/top_agc_only_serial_EITpads.vhd}

elaborate top -library WORK -architecture Behavioral

# Make sure the compiler does not exchange pads.
set_dont_touch [ get_cells *pad*] true
#set_dont_touch clkpad true

source $synt_scr_path/create_clock.tcl

set_drive 0 {clk rstn}

set_dont_touch_network rstn
set_ideal_network rstn

set_max_leakage_power 0
set_max_area 0
compile -map_effort high -area_effort high 

remove_unconnected_ports -blast_buses [get_cells "*" -hier]
remove_unconnected_ports [get_cells "*" -hier]
change_names -rules verilog -hierarchy 
report_constraint -all_violators
#report_design
#report_area -hierarchy
#report_power
#report_timing –max_paths #number_of_paths

change_names -rules verilog -hierarchy 
#write -format ddc -hierarchy -output ./netlists/agc_synth.ddc
write -format verilog -hierarchy -output ./netlists/agc_synth.v
write_sdf ./netlists/agc_synth.sdf
write_sdc ./netlists/agc_synth.sdc
