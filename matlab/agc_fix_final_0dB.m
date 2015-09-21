% clear all; 
% clf;
bits = 16;              % resolution of data
filter_bits = 10;       % resolution of filter coefficients
% load handel; in = y(1:end)./max(abs(in)); % input signal
% in = audioread('test_mono_8000Hz_16bit_PCM.wav'); in = in(1:6e4).*0.5;
% range = (1:end);
in = audioread('Speech_all.wav'); in = in./max(abs(in)).*1;
% in = audioread('p50_male.wav'); in = in(1:5e4).*1;
% in = audioread('p50_female.wav'); in = in(1:5e4).*1;
% in = [[0:0.1:1] [0.9:-0.1:0] 0 0 0 0 0 0 0];


LUT = int16(agc_lut_dB() .* 2^(bits-1));    % Lookup table with gain values

% high pass filter parameters
[B_1, A_1] = high_pass_filter();  % get high pass filter coefficients
B_hp = int32(B_1 .* 2^(filter_bits-1));
A_hp = int32(A_1 .* 2^(filter_bits-1));
y_hp_pre = int32(0);
x_hp_pre = int32(0);

% equalizer filter parameters
[B_2, A_2] = def_iir_filter();    % get eq. filter coefficients
B_eq = int32(B_2 .* 2^(filter_bits-1));
A_eq = int32(A_2 .* 2^(filter_bits-1));
y_eq_pre = int32(0);
y_eq_pre_pre = int32(0);
x_eq_pre = int32(0);
x_eq_pre_pre = int32(0);

% Arrays for plotting
in_fix = zeros(size(in), 'int16');
in_hp_fix = zeros(size(in), 'int16');       
in_fix_filtered = zeros(size(in), 'int16'); % fixed point filtered input signal array
P_in = zeros(size(in), 'int32');
P_dB = zeros(size(in), 'int16');
P_weighted = zeros(size(in), 'int32');
out_agc = zeros(size(in), 'int32');
gain_used = zeros(size(in), 'double');
out = zeros(size(in));

% time constants
alpha = int32(0.02 .* 2^(16-1));    % attack time ~ 1ms
beta  = int32(0.001 .* 2^(16-1));   % release time ~ 300ms

P_x_fast = zeros(size(in));
% P_weighted = zeros(size(in));

for n = 1:length(in)
    in_fix(n) = int16( round(in(n) .* (2^(bits-1))) .* 2^(16-bits) ); % scale up to 2^bits-1 and round off to integer
    
    % ----- HIGH PASS FILTER -----
    in_hp = int32(-A_hp(2) * y_hp_pre...
                       + B_hp(1) * int32(in_fix(n))...
                       + B_hp(2) * x_hp_pre);
    in_hp = int32(floor(double(in_hp) / 2^(filter_bits-1)));
    x_hp_pre = int32(in_fix(n));
    y_hp_pre = int32(in_hp);
    
    in_hp_fix(n) = int16(in_hp);
    
    % ----- EQUALIZER FILTER -----
    y_eq = int32(-A_eq(2) * y_eq_pre...
                - A_eq(3) * y_eq_pre_pre...
                + B_eq(1) * int32(in_hp_fix(n))...
                + B_eq(2) * x_eq_pre...
                + B_eq(3) * x_eq_pre_pre);
    y_eq = int32(floor(double(y_eq) / 2^(filter_bits-1)));
    x_eq_pre_pre = int32(x_eq_pre);
    x_eq_pre = int32(in_hp_fix(n));
    y_eq_pre_pre = int32(y_eq_pre);
    y_eq_pre = int32(y_eq);
    
    in_fix_filtered(n) = int16(int32(y_eq) ./ 2^7);               % scale down filter output
    
    % ----- AGC -----
    P_in(n) = int32(abs(int32(in_fix_filtered(n))).^2);
    
    P_x_fast(n+1) = int32(((1*2^(16-1) - alpha).*(P_x_fast(n) / 2^(16-1))) + (int32(alpha.*P_in(n)) / 2^(16-1)));
    P_weighted(n+1) = max(P_x_fast(n+1), P_weighted(n));

    slope = P_x_fast(n+1) - P_x_fast(n);

    if(slope <= 0)
        P_weighted(n+1) = int32( int64(1*2^(16-1) - beta) .* int64(P_weighted(n+1)) / 2^(16-1));
    end
    
   
    if P_weighted(n+1) ~= 0
        P_dB(n) = 10*log10(double(P_weighted(n+1))) - 82;
    else
        P_dB(n) = -82;
    end
    
    if round(P_dB(n)) > -82
        out_agc(n) = int16(int32(in_fix(n)) .* int32(LUT(round(P_dB(n)) + 82)) / 2^(16-1));
        gain_used(n) = double(LUT(round(P_dB(n)) + 82)) / 2^(16-1);
    else
        out_agc(n) = int16(in_fix(n));
        gain_used(n) = 1;
    end
    
    
    out(n) = double(out_agc(n)) ./ 2.^(16-1);    % scale down so -1 < output < 1
end

figure(1)
clf
t = 1:length(in);

subplot(311)
plot(t, in, t, out, 'r--')
legend('in','out','Location','Southeast')

subplot(312)
plot(t, P_dB, 'b')
legend('P_{dB}', 'Location','Southeast')

subplot(313)
plot(t, gain_used, 'b-')
legend('gain','Location','Southeast')