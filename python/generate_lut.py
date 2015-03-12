def tohex(val, nbits):
    return hex((val + (1 << nbits)) % (1 << nbits))

gain_file = open('matlab_gain_lut.txt', 'r')
g_lines = gain_file.readlines()
fix_file = open('gain_lut_template.vhd', 'r')
fix_lines = fix_file.readlines()
ofile = open('gain_lut_py.vhd', 'w')

for f_line in fix_lines:
    ofile.write(f_line)
    if 'case i_dB' in f_line:
        n = len(g_lines);
        for line in reversed(g_lines):
            g = int(float(line) * (2**15))
            dB = str(tohex(n-82,8))[2:]
            if len(dB) < 2:
                dB = '0' + dB
            gain = str(hex(g)[2:])
            if gain == '8000':
                gain = '7fff'
            ofile.write('            when x"' + dB + '" => o_gain <= x"' + gain + '"; -- ' + str(n) + 'dB' + '\n')
            n -= 1
    
gain_file.close()
fix_file.close()
ofile.close()

