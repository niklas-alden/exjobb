clear all; clf;

bits = 16;              % resolution of data
filter_bits = 10;       % resolution of filter coefficients
% load handel; in = y(1:5000).*1; % input signal
% in = audioread('test_mono_8000Hz_16bit_PCM.wav'); in = in(1:3e4);%.*1.2;
in = audioread('Speech_all.wav'); in = in(1:5e4).*1;
% in = audioread('p50_male.wav'); in = in(1:5e4).*1;
% in = audioread('p50_female.wav'); in = in(1:5e4).*1;
% in = ones(1,1200).*1e-4; in(50:600) = 1;
% t = linspace(1,100,10000);
% f = @(t,G) G.*sin(2.*pi.*2e3.*t);
% in = [f(t(1:1000),0.01) f(t(1001:6000),1) f(t(6001:9000),0.01)];% f(t(5001:7000),0.6) f(t(7001:9000),1) f(t(9001:end),0.01)];

in_hp = zeros(size(in));        % allocate high pass filtered input signal array
in_fix = zeros(size(in), 'int16');   % allocate fixed point input signal array
in_hp_fix = zeros(size(in), 'int32');
% out_no_filter = zeros(size(in)); % allocate unfiltered output signal array
in_fix_filtered = zeros(size(in), 'int32'); % allocate fixed point filtered input signal array
in_fix_filtered_no_gain = zeros(size(in), 'int32');
out_agc = zeros(size(in), 'int32');
out = zeros(size(in));          % allocate output signal array
P = zeros(size(in), 'int32');   % allocate power of fixed point input signal array
P_tmp = zeros(size(in), 'int32');   % allocate power of fixed point input signal array
P_prev = int32(1);              % Previous power value of input signal (memory)
LUT = agc_lut();                % Lookup table with gain values
gain_used = zeros(size(in));

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

% tune parameters
alpha = 0.005;                   % attack time ~ < 5ms
beta  = 0.03;                    % release time ~ 30-40ms

for n = 1:length(in)
    % ----- FIXED POINT -----
    in_fix(n) = int16(round(in(n) .* (2.^(bits-1)))); % scale up to 2^bits-1 and round off to integer
    
    % ----- HIGH PASS FILTER -----
%---  in_hp(n) = filter(B_hp, A_hp, in(n));
    in_hp = int32(int32(int32(-A_hp(2))* int32(y_hp_pre))...
                + int32(int32(B_hp(1)) * int32(in_fix(n)))...
                + int32(int32(B_hp(2)) * int32(x_hp_pre)));
    in_hp = in_hp ./ 2^(filter_bits-1);
    x_hp_pre = int32(in_fix(n));
    y_hp_pre = int32(in_hp);
    
    in_hp_fix(n) = int32(in_hp);
%     in_hp_fix(n) = int16(in_fix(n)); % bypass high pass filter
    
    % ----- EQ. FILTER -----
% ---  y_eq = filter(B_eq, A_eq, double(in_fix(n)));   % filtering with IIR filter
    y_eq = int32(int32(int32(-A_eq(2))* int32(y_eq_pre))...
               - int32(int32(A_eq(3)) * int32(y_eq_pre_pre))...
               + int32(int32(B_eq(1)) * int32(in_hp_fix(n)))...
               + int32(int32(B_eq(2)) * int32(x_eq_pre))...
               + int32(int32(B_eq(3)) * int32(x_eq_pre_pre)));
    y_eq = y_eq ./ 2^(filter_bits-1);
    x_eq_pre_pre = int32(x_eq_pre);
    x_eq_pre = int32(in_hp_fix(n));
    y_eq_pre_pre = int32(y_eq_pre);
    y_eq_pre = int32(y_eq);
    
    in_fix_filtered(n) = int32(y_eq ./ 128);               % scale down filter output
    
%     in_fix_filtered(n) = int32(in_hp_fix(n)); % bypass eq filter
    in_fix_filtered_no_gain(n) = in_fix_filtered(n);

    % ----- AGC -----
    % P(n) = (1 - lambda)*P(n-1) + lambda*(x(n)^2), lambda = (alpha, beta)
    P_in = int32(abs(in_fix_filtered(n)).^2);
    
    if P_in > P_prev
        P_tmp(n) = int32((1 - alpha).*P_prev + int32(alpha.*P_in)); 
    else
        P_tmp(n) = int32((1 - beta) .*P_prev + int32(beta .*P_in)); 
    end

    if P_tmp(n) > 0 % avoid log10 of 0
        P(n) = 10.*log10(double(P_tmp(n))); % convert to dB
    else
        P(n) = 0;
    end
    
    if round(P(n)) > 1 % avoid index 0
        out_agc(n) = int32(in_fix_filtered(n) .* LUT(round(P(n))));
        gain_used(n) = LUT(round(P(n)));
    else
        out_agc(n) = int32(in_fix_filtered(n));
        gain_used(n) = 1;
    end

    P_prev = int32(abs(int32(out_agc(n))).^2);

    out(n) = double(out_agc(n)) ./ 2.^(bits-1);    % scale down so -1 < output < 1
%     out(n) = double(in_fix_filtered(n)) ./ (2.^(bits-1));    % BYPASS scale down so -1 < output < 1
%     out(n) = double(in_hp_fix(n)) ./ 2.^(bits-1);    % BYPASS scale down so -1 < output < 1
end

figure(1)
clf
subplot(311)
plot(1:length(in), in, 1:length(in), out, 'r--')
% plot(1:length(in), in_fix_filtered_no_gain, 1:length(in), out.*2.^(bits-1), 'r--')
% legend('in','out','Location','southeast')

subplot(312)
% plot(1:length(in), 10.*log10(double(in_fix_filtered_no_gain).^2), 'b',...
%      1:length(in), 10.*log10(double(in_fix_filtered).^2), 'r--')
plot(1:length(in), real(20.*log10(double(in_fix_filtered_no_gain))), 'm',...
     1:length(in), real(20.*log10(double(out_agc))), 'g--',...
     1:length(in), 82, 'r--', 1:length(in), P, 'b-')
legend('P_{in}', 'P_{out}', 'P_{max}', 'P', 'Location','southeast')
% plot(1:length(in), P, '', 1:length(in), 82, 'r--')
% legend('P', 'P_{max}', 'Location','southeast')

subplot(313)
plot(1:length(in), gain_used)
% plot(1:length(in), in_fix_filtered - out_agc)
legend('gain','Location','southeast')

% figure(2)
% plot(abs(in - out), 'r')        % plot error of filtered output
% hold on
% plot(abs(in - out_no_filter))   % plot error of unfiltered output
