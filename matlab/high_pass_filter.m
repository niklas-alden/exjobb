function [ B,A ] = high_pass_filter( ~ )
%HIGH_PASS_FILTER Return polynomial coefficients for the input high pass filter
%   Detailed explanation goes here
T = 1/8000;
R = 39e3;
C = 100e-9;

b_0 = 2*R*C / (2*R*C+T);
b_1 = -2*R*C / (2*R*C+T);
a_1 = (-2*R*C+T) / (2*R*C+T);

B = [b_0, b_1];
A = [1, a_1];
end

