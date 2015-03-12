import math

def dB_conv(val):
    return math.ceil(10**(val/10))

ofile = open('P_to_dB_py.txt', 'w')

n = 99.5
ref = 82

while n > 0:
    #print(str(hex(dB_conv(n))[2:]) + '\t' + str(int(n-ref+0.5)) + '\t' + str(n))
    h = str(hex(dB_conv(n))[2:])
    d1 = str(int(n-ref+0.5))
    d2 = str(n)
    ofile.write('elsif P_tmp_c(46 downto 15) > x"' + h + '" then -- >' + d2 + 'dB\n\tP_dB_n <= to_signed(' + d1 + ', 8);\n')
    n -= 1

ofile.close()
