setMultiCpuUsage -localCpu 2
setDesignMode -process 65
setDrawView place

clearGlobalNets
globalNetConnect VDD -type pgpin -pin VDDC -inst PVDD*
globalNetConnect VDD -type pgpin -pin vdd -inst *
globalNetConnect VDD -type tiehi -inst *
globalNetConnect GND -type pgpin -pin GNDC -inst PGND*
globalNetConnect GND -type pgpin -pin gnd -inst *
globalNetConnect GND -type tielo -inst *
getIoFlowFlag
setIoFlowFlag 0
#floorPlan -coreMarginsBy die -site CORE -s 300 220 95 95 95 95
floorPlan -coreMarginsBy die -site CORE -s 300 240 95 95 95 95
