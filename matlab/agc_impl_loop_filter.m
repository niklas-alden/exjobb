clear all; clf;

bits = 16;                      % resolution
load handel; in = y(1:5000).*1; % input signal
% in = audioread('test_mono_8000Hz_16bit_PCM.wav'); in = in(1:3e4);%.*1.2;
% in = ones(1,1200).*1e-4; in(50:600) = 1;

in_hp = zeros(size(in));        % allocate high pass filtered input signal array
in_fix = zeros(size(in), 'int16');   % allocate fixed point input signal array
in_hp_fix = zeros(size(in), 'int16');
out_no_filter = zeros(size(in)); % allocate unfiltered output signal array
in_fix_filtered = zeros(size(in), 'int16'); % allocate fixed point filtered input signal array
in_fix_filtered_no_gain = zeros(size(in), 'int16');
out_agc = zeros(size(in), 'int16');
out = zeros(size(in));          % allocate output signal array
P = zeros(size(in), 'int32');   % allocate power of fixed point input signal array
P_tmp = zeros(size(in), 'int32');   % allocate power of fixed point input signal array
P_prev = int32(1);              % Previous power value of input signal (memory)
LUT = agc_lut();                % Lookup table with gain values
gain_used = zeros(size(in));

% high pass filter parameters
[B_hp, A_hp] = high_pass_filter();  % get high pass filter coefficients
y_hp_pre = int32(0);
x_hp_pre = int32(0);

% equalizer filter parameters
[B_eq, A_eq] = def_iir_filter();    % get eq. filter coefficients
y_eq_pre = int32(0);
y_eq_pre_pre = int32(0);
x_eq_pre = int32(0);
x_eq_pre_pre = int32(0);

% tune parameters
alpha = 0.005;                   % attack time ~ < 5ms
beta  = 0.05;                    % release time ~ 30-40ms

for n = 1:length(in)
    % ----- FIXED POINT -----
    in_fix(n) = round(in(n) .* 2.^(bits-1)); % scale up to 2^bits-1 and round off to integer
    
    % ----- HIGH PASS FILTER -----
%     in_hp(n) = filter(B_hp, A_hp, in(n));
    in_hp = int32(-A_hp(2)*int32(y_hp_pre) + B_hp(1)*int32(in_fix(n)) + B_hp(2)*int32(x_hp_pre));
    x_hp_pre = int32(in_fix(n));
    y_hp_pre = int32(in_hp);
    
    in_hp_fix(n) = int16(in_hp);
    
    % ----- EQ. FILTER -----
%     y_eq = filter(B_eq, A_eq, double(in_fix(n)));   % filtering with IIR filter
    y_eq = int32(-A_eq(2)*int32(y_eq_pre) - A_eq(3)*int32(y_eq_pre_pre) + B_eq(1)*int32(in_hp_fix(n)) + B_eq(2)*int32(x_eq_pre) + B_eq(3)*int32(x_eq_pre_pre));
    x_eq_pre_pre = int32(x_eq_pre);
    x_eq_pre = int32(in_hp_fix(n));
    y_eq_pre_pre = int32(y_eq_pre);
    y_eq_pre = int32(y_eq);
    
    
    in_fix_filtered(n) = int16(int32(y_eq));% ./ 128);               % scale down filter output
    in_fix_filtered_no_gain(n) = in_fix_filtered(n);

    % ----- AGC -----
    % P(n) = (1 - lambda)*P(n-1) + lambda*(x(n)^2), lambda = (alpha, beta)
    P_in = int32(abs(in_fix_filtered(n)).^2);
    
    if P_in > P_prev
        P_tmp(n) = int32((1 - alpha).*P_prev + int32(alpha.*P_in)); 
%         P_tmp(n) = P_a;
    else
        P_tmp(n) = int32((1 - beta) .*P_prev + int32(beta .*P_in)); 
%         P_tmp(n) = P_b;
    end

    P(n) = 10.*log10(double(P_tmp(n))); % convert to dB
    
    if round(P(n)) > 1 % avoid index 0
        out_agc(n) = int16(in_fix_filtered(n) .* LUT(round(P(n))));
        gain_used(n) = LUT(round(P(n)));
    else
        out_agc(n) = int16(in_fix_filtered(n));
        gain_used(n) = 1;
    end

    P_prev = int32(abs(int32(out_agc(n))).^2);

    out(n) = double(out_agc(n)) ./ 2.^(bits-1);    % scale down so -1 < output < 1
%     out(n) = double(in_fix_filtered(n)) ./ 2.^(bits-1);    % scale down so -1 < output < 1
%     out(n) = double(in_hp_fix(n)) ./ 2.^(bits-1);    % scale down so -1 < output < 1
end

figure(1)
subplot(311)
plot(1:length(in), in, 1:length(in), out, 'r--')
% plot(1:length(in), in_fix_filtered_no_gain, 1:length(in), out.*2.^(bits-1), 'r--')
legend('in','out','Location','southeast')

subplot(312)
% plot(1:length(in), 10.*log10(double(in_fix_filtered_no_gain).^2), 'b',...
%      1:length(in), 10.*log10(double(in_fix_filtered).^2), 'r--')
plot(1:length(in), real(20.*log10(double(in_fix_filtered_no_gain))), 'm',...
     1:length(in), real(20.*log10(double(out_agc))), 'g',...
     1:length(in), 82, 'r--', 1:length(in), P, 'b-')
legend('P_{in}', 'P_{out}', 'P_{max}', 'P', 'Location','southeast')

subplot(313)
plot(1:length(in), gain_used)
% plot(1:length(in), in_fix_filtered - out_agc)
legend('gain','Location','southeast')

% figure(2)
% plot(abs(in - out), 'r')        % plot error of filtered output
% hold on
% plot(abs(in - out_no_filter))   % plot error of unfiltered output
