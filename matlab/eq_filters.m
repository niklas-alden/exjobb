%% DEFAULT FILTER
clear all; close all;

load handel;  % input signal
in = y;

T = 1/40000;
R2 = 16.8e3;
C2 = 100e-9;
R4 = 2840e3;
C4 = 11.4e-12;

a_d = R2*C2*R4*C4;
b_d = R2*C2 + R4*C4 + R4*C2;
c_d = R2*C2 + R4*C4;

b_0 = (4*a_d + 2*T*b_d + T^2) / (4*a_d + 2*T*c_d + T^2);
b_1 = (2*(T^2) - 8*a_d) / (4*a_d + 2*T*c_d + T^2);
b_2 = (4*a_d - 2*T*b_d + T^2) / ((4*a_d + 2*T*c_d + T^2));
a_1 = (2*(T^2) - 8*a_d) / (4*a_d + 2*T*c_d + T^2);
a_2 = (4*a_d - 2*T*c_d + T^2) / ((4*a_d + 2*T*c_d + T^2));

B = [b_0, b_1, b_2];
A = [1, a_1, a_2];
H_dbi = (b_0 + b_1 + b_2) / (1 + a_1 + a_2);

zplane(B,A)
y = filter(B, A, in);       % filtering with IIR filter
% in_fix_filtered = y ./ (max(y) ./ max(in_fix));   % scale filter output
plot(1:length(in), y, 1:length(in), in, 'r')

%% OPTION 1 FILTER
clear all; close all;
T = 1/40000;
R6 = 30e3;
R8 = 15.5e3;
R10 = 32e5;
C6 = 100e-9;
C8 = 10e-12;
C10 = 10e-12;

a_o1 = R10*C10*R6*C6*R8*C8;
b_o1 = R8*C8*R6*C6 + (R8*C8 + R6*C6 + R8*C6)*R10*C10 + R10*R6*C6*C8;
c_o1 = R10*C10 + R8*C8 + R6*C6 + R8*C6 + R10*C6 + R10*C8;
d_o1 = R8*C8*R6*C6 + (R8*C8 + R6*C6 + R8*C6)*R10*C10;
e_o1 = R6*C6 + R8*C8 + R8*C6 + R10*C10;

a_0 = 8*a_o1 + 4*T*d_o1 + 2*(T^2)*e_o1 + T^3;
a_1 = (-24*a_o1 - 4*T*d_o1 + 2*(T^2)*e_o1 + 3*(T^3)) / a_0;
a_2 = (24*a_o1 - 4*T*d_o1 - 2*(T^2)*e_o1 + 3*(T^3)) / a_0;
a_3 = (-8*a_o1 + 4*T*d_o1 - 2*(T^2)*e_o1 + T^3) / a_0;
b_0 = (8*a_o1 + 4*T*b_o1 + 2*(T^2)*c_o1 + T^3) / a_0;
b_1 = (-24*a_o1 - 4*T*b_o1 + 2*(T^2)*c_o1 + 3*(T^3)) / a_0;
b_2 = (24*a_o1 - 4*T*b_o1 - 2*(T^2)*c_o1 + 3*(T^3)) / a_0;
b_3 = (-8*a_o1 + 4*T*b_o1 - 2*(T^2)*c_o1 + T^3) / a_0;

B = [b_0, b_1, b_2, b_3];
A = [1, a_1, a_2, a_3];

zplane(B,A)

%[H,w]=freqz(B,A, 2001);
%plot(w/pi, 20*log10(abs(H)));
