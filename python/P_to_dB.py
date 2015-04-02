import math

def dB_conv(val):
    return math.ceil(10**(val/10))

ofile = open('P_to_dB_py.txt', 'w')

n = 95.5
ref = 82
first = 1

while n > 0:
    h = str(hex(dB_conv(n))[2:])
    max_bit = str(len(h)*4-1)
    d1 = str(int(n-ref+0.5))
    d2 = str(n)
    if first:
        ofile.write('if P_tmp_c(' + max_bit + ' downto 0) > x"' + h + '" then -- >' + d2 + 'dB\n\tP_dB_n <= to_signed(' + d1 + ', 8);\n')
        first = 0
    else:
        ofile.write('elsif P_tmp_c(' + max_bit + ' downto 0) > x"' + h + '" then -- >' + d2 + 'dB\n\tP_dB_n <= to_signed(' + d1 + ', 8);\n')
    n -= 1

ofile.close()
