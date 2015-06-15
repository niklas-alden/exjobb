source scripts/floorplan.tcl
source scripts/add_io_filler.tcl
source scripts/power_planning.tcl
source scripts/std_route.tcl

setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -preCTS
optDesign -preCTS

source scripts/clock_tree.tcl

optDesign -postCTS -hold
optDesign -postCTS
optDesign -postCTS -hold
optDesign -postCTS

source scripts/nano_route.tcl

optDesign -postRoute
optDesign -postRoute -hold
optDesign -postRoute
optDesign -postRoute -hold

#source scripts/add_filler.tcl
