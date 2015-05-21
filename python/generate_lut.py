def tohex(val, nbits):
    return hex((val + (1 << nbits)) % (1 << nbits))

def to_bin(val, nbit):
    leading_zeros = '{0:0' + str(nbit) + 'b}'
    return leading_zeros.format(val)

gain_file = open('matlab_gain_lut_poly3_50dB.txt', 'r')
g_lines = gain_file.readlines()
ofile = open('gain_lut_py_poly3_50dB_bin.vhd', 'w')

limit = 82
n = len(g_lines) - (82 - limit)
for line in reversed(g_lines):
    g = int(float(line) * (2**15))
    dB = str(tohex(n-82,8))[2:]
    if len(dB) < 2:
        dB = '0' + dB
    gain = to_bin(g, 15)
    if gain == '1' + '0'*15:
        gain = '1'*15
    ofile.write('\t\twhen x"' + dB + '" => gain_n <= "' + gain + '"; -- ' + str(n) + 'dB' + '\n')
    n -= 1
    if n < 0:
        break
    
gain_file.close()

ofile.close()

