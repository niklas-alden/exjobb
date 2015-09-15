#
# file: agc.io
#
# This file introduces the corner- and power pads into the
# design. The rest of the pads should be defined in the ve-
# rilog file and are only refered to by name, and not type.
#

Version: 2

Orient: R180
Pad: Pcornerul NW PADSPACE_C_74x74u_CH
Orient: R90
Pad: Pcornerur NE PADSPACE_C_74x74u_CH
Orient: R270
Pad: Pcornerll SW PADSPACE_C_74x74u_CH
Orient: R0
Pad: Pcornerlr SE PADSPACE_C_74x74u_CH

# Bottom row, left to right
#Pad: PVDDi S CPAD_S_74x50u_VDD
Pad: clkpad S
Pad: PVDDc S PADVDD_74x50uNOTRIG
Pad: inpad_R_start S
#Pad: PVDDo S CPAD_S_74x50u_VDD

# Right row, upwards
#Pad: inpad_R_start E
Pad: inpad_R_sample E
Pad: outpad_R_done E
Pad: outpad_R_sample E

# Top row, left to right
#Pad: PGNDo N PADGND_74x50uNOTRIG
Pad: inpad_rstn N
Pad: PGNDc N PADGND_74x50uNOTRIG
Pad: inpad_L_start N
#Pad: PGNDi N PADGND_74x50uNOTRIG

# Left row, upwards
#Pad: inpad_L_start W
Pad: inpad_L_sample W
Pad: outpad_L_done W
Pad: outpad_L_sample W
