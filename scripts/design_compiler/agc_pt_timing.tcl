
##################  remove any previous designs 
remove_design -all

set power_enable_analysis  true
set power_analysis_mode time_based

####################### set up libaries ############################
# step 1: link to your design libary 
# used libaries: 
#               fsc0l_d_generic_core_ff1p32vm40c.db/fsc0l_d_generic_core_ss1p08v125c.db/fsc0l_d_generic_core_tt1p2v25c.db
#               foc0l_a33_t33_generic_io_ff1p32vm40c.db/foc0l_a33_t33_generic_io_ss1p08v125c.db/foc0l_a33_t33_generic_io_tt1p2v25c.db
#               SHLD130_128X32X1BM1_TC.db/SPLD130_512X14BM1A_TC.db
 
#set dir_struc_path "/home/piraten/ael10nal/Desktop/asic_final"

set search_path "/net/cas-13/export/space/eit-oae/projects/tapeOutOct2012/digital/backend/lib \
				/usr/local-eit/cad2/cmpstm/stm065v536/CLOCK65LPHVT_3.1/libs \
		 		$env(STM065_DIR)/CORE65LPHVT_5.1/libs $search_path"

set link_library "* Pads_Oct2012.db \
				CLOCK65LPHVT_nom_1.20V_25C.db \
                CORE65LPHVT_nom_1.20V_25C.db" 
#\ standard.sldb dw_foundation.sldb"

set target_library "Pads_Oct2012.db \
					CLOCK65LPHVT_nom_1.20V_25C.db \
                    CORE65LPHVT_nom_1.20V_25C.db"

set symbol_library "CORE65LPHVT.sdb"

set synthetic_library "standard.sldb dw_foundation.sldb"

####################### design input    ############################
# step 2: read your design (netlist) & link design
# top deisgn name: top

read_verilog /home/piraten/ael10nal/Desktop/asic_final/soc/agc_june11.v
#read_verilog /media/GREEN/agc_may29/agc_may29.v
current_design top
link


####################### timing constraint ##########################
# step 3: setup timing constraint (or read sdc file)
# clock port: clk

read_sdc /home/piraten/ael10nal/Desktop/asic_final/netlists/agc_synth.sdc



####################### Back annotate     ##########################
# step 4: back annotate delay information (read sdf file)

read_parasitics /home/piraten/ael10nal/Desktop/asic_final/soc/agc_june11_ss.spef
read_sdf -type sdf_max /home/piraten/ael10nal/Desktop/asic_final/soc/agc_june11.sdf
#read_parasitics /media/GREEN/agc_may29/agc_may29_ff.spef
#read_sdf -typ sdf_max /media/GREEN/agc_may29/agc_may29.sdf

#read_vcd -strip_path tb_top_serial/uut /tmp/modelsim/agc_post_pnr/agc2.vcd
read_vcd -strip_path tb_top_serial/uut /tmp/modelsim/agc_june03/agc_june11.vcd

####################### timing analysis and report #################
# step 5: output timing report, including setup timing, hold timing, and clock skew

check_power
update_power
report_power -verbose > /home/piraten/ael10nal/Desktop/asic_final/report/power_agc.rpt

report_timing -delay_type min -max_paths 10 > /home/piraten/ael10nal/Desktop/asic_final/report/timing_hold_agc_pnr.rpt
report_timing -delay_type max -max_paths 10 > /home/piraten/ael10nal/Desktop/asic_final/report/timing_setup_agc_pnr.rpt
report_clock_timing -type skew -verbose > /home/piraten/ael10nal/Desktop/asic_final/report/timing_clk_agc_pnr.rpt

