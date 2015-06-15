addRing -spacing_bottom 2 -width_left 3 -width_bottom 3 -width_top 3 -spacing_top 2 -layer_bottom M3 -stacked_via_top_layer AP -width_right 3 -around core -jog_distance 2.5 -offset_bottom 2.5 -layer_top M3 -threshold 2.5 -offset_left 2.5 -spacing_right 2 -spacing_left 2 -offset_right 2.5 -offset_top 2.5 -layer_right M4 -nets {GND VDD} -stacked_via_bottom_layer M1 -layer_left M4

addStripe -block_ring_top_layer_limit M4 -max_same_layer_jog_length 6 -padcore_ring_bottom_layer_limit M2 -set_to_set_distance 100 -stacked_via_top_layer AP -padcore_ring_top_layer_limit M4 -spacing 2 -merge_stripes_value 2.5 -direction horizontal -layer M3 -block_ring_bottom_layer_limit M2 -width 3 -nets {GND VDD} -stacked_via_bottom_layer M1

addStripe -block_ring_top_layer_limit M5 -max_same_layer_jog_length 6 -padcore_ring_bottom_layer_limit M3 -set_to_set_distance 100 -stacked_via_top_layer AP -padcore_ring_top_layer_limit M5 -spacing 2 -merge_stripes_value 2.5 -layer M4 -block_ring_bottom_layer_limit M3 -width 3 -nets {GND VDD} -stacked_via_bottom_layer M1

addWellTap -cell HS65_LH_FILLERCELL4 -cellInterval 25 -prefix WELLTAP
fit
