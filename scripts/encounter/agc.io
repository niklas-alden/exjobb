#
# file: agc.io
#
# This file introduces the corner- and power pads into the
# design. The rest of the pads should be defined in the ve-
# rilog file and are only refered to by name, and not type.
#

Version: 2

Orient: R0
Pad: Pcornerul NW LTCORNERCELL_ST_SF_LIN
Orient: R0
Pad: Pcornerur NE RTCORNERCELL_ST_SF_LIN
Orient: R0
Pad: Pcornerll SW LBCORNERCELL_ST_SF_LIN
Orient: R0
Pad: Pcornerlr SE RBCORNERCELL_ST_SF_LIN

# Bottom row, left to right
Pad: PVCCi S VDDE_ST_SF_LIN
Pad: clkpad S
Pad: PVCCc S VDD_ST_SF_LIN
Pad: PVCCo S VDDE_ST_SF_LIN

# Right row, upwards
Pad: inpad_R_start E
Pad: inpad_R_sample E
Pad: outpad_R_done E
Pad: outpad_R_sample E

# Top row, left to right
Pad: PGNDo N GNDE_ST_SF_LIN
Pad: inpad_rstn N
Pad: PGNDc N GND_ST_SF_LIN
Pad: PGNDi N GNDE_ST_SF_LIN

# Left row, upwards
Pad: inpad_L_start W
Pad: inpad_L_sample W
Pad: outpad_L_done W
Pad: outpad_L_sample W
