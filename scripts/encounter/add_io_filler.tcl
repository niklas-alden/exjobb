deselectAll
selectInst Pcornerul
#selectInst PGNDo
selectInst inpad_rstn
selectInst PGNDc
selectInst inpad_L_start
#selectInst PGNDi
spaceObject -fixSide left -space 46

deselectAll
selectInst Pcornerll
#selectInst PVDDi
selectInst clkpad
selectInst PVDDc
selectInst inpad_R_start
#selectInst PVDDo
spaceObject -fixSide left -space 46

deselectAll
selectInst Pcornerul
selectInst outpad_L_sample
selectInst outpad_L_done
selectInst inpad_L_sample
#selectInst inpad_L_start
spaceObject -fixSide top -space 31

deselectAll
selectInst Pcornerur
selectInst outpad_R_sample
selectInst outpad_R_done
selectInst inpad_R_sample
#selectInst inpad_R_start
spaceObject -fixSide top -space 31
deselectAll

deselectAll
fit

addIoFiller -cell PADSPACE_74x16u PADSPACE_74x8u PADSPACE_74x4u PADSPACE_74x2u PADSPACE_74x1u -prefix IOFILLER -side n
addIoFiller -cell PADSPACE_74x16u PADSPACE_74x8u PADSPACE_74x4u PADSPACE_74x2u PADSPACE_74x1u -prefix IOFILLER -side s
addIoFiller -cell PADSPACE_74x16u PADSPACE_74x8u PADSPACE_74x4u PADSPACE_74x2u PADSPACE_74x1u -prefix IOFILLER -side w
addIoFiller -cell PADSPACE_74x16u PADSPACE_74x8u PADSPACE_74x4u PADSPACE_74x2u PADSPACE_74x1u -prefix IOFILLER -side e

fit
