create_clock clk -period 10 -name clk

set_clock_uncertainty 0.1 clk
set_fix_hold clk

set_input_delay 0.75 -clock clk [remove_from_collection [all_inputs] {clk}]
set_output_delay 0.25 -clock clk [all_outputs]

set_clock_transition 0.1 -rise [all_clocks]
set_clock_transition 0.1 -fall [all_clocks]
set_dont_touch_network [all_clocks]

set_propagated_clock clk
