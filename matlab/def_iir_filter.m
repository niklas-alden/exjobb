function [ B,A ] = def_iir_filter( ~ )
%DEF_IIR_FILTER Return polynomial coefficients for the default IIR filter
%   Detailed explanation goes here

    downscale = 128;
    
    T = 1/8000;
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

    B = [b_0, b_1, b_2]./downscale;
    A = [1, a_1, a_2]./downscale;
    
end

