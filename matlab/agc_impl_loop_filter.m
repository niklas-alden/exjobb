clear all; clf;

bits = 16;              % resolution of data
filter_bits = 10;       % resolution of filter coefficients
% load handel; in = y(1:5000).*1; % input signal
% in = audioread('test_mono_8000Hz_16bit_PCM.wav'); in = in(1:3e4);%.*1.2;
in = audioread('Speech_all.wav'); in = in(1:5e4).*1;
% in = audioread('p50_male.wav'); in = in(62e3:64e3).*1;
% in = audioread('p50_female.wav'); in = in(1:5e4).*1;
% in = ones(1,1200).*1e-4; in(50:600) = 1;
% t = linspace(1,100,10000);
% f = @(t,G) G.*sin(2.*pi.*2e3.*t);
% in = [f(t(1:1000),0.01) f(t(1001:6000),1) f(t(6001:9000),0.01)];% f(t(5001:7000),0.6) f(t(7001:9000),1) f(t(9001:end),0.01)];
% in = zeros(1,10000);
% for i = 1e3:1e3:length(in)-1
%     in(i:i+500) = 1;
% end


LUT = int16(agc_lut() .* 2^(bits-1));       % Lookup table with gain values
P_prev = int32(0);                          % Previous power value of input signal (memory)

% Arrays used for plotting, replace with single registers in hardware design
in_fix = zeros(size(in), 'int16');          % fixed point input signal array
in_hp_fix = zeros(size(in), 'int32');
in_fix_filtered = zeros(size(in), 'int32'); % fixed point filtered input signal array
in_fix_filtered_no_gain = zeros(size(in), 'int32');
P = zeros(size(in), 'int32');               % power of fixed point input signal array
out_agc = zeros(size(in), 'int32');
gain_used = zeros(size(in));                % array to see what gain the agc used 
out = zeros(size(in));                      % output signal array

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
beta  = 0.05;                    % release time ~ 30-40ms

for n = 1:length(in)
    % ---------- FIXED POINT ----------
    in_fix(n) = int16(round(in(n) .* (2.^(9))) .* 2^6); % scale up to 2^bits-1 and round off to integer
    
    % ---------- HIGH PASS FILTER ----------
    in_hp = int32(int32(int32(-A_hp(2))* int32(y_hp_pre))...
                + int32(int32(B_hp(1)) * int32(in_fix(n)))...
                + int32(int32(B_hp(2)) * int32(x_hp_pre)));
    in_hp = in_hp ./ 2^(filter_bits-1);
    x_hp_pre = int32(in_fix(n));
    y_hp_pre = int32(in_hp);
    
    in_hp_fix(n) = int32(in_hp);
%     in_hp_fix(n) = int16(in_fix(n)); % bypass high pass filter
    
    % ---------- EQUALIZER FILTER ----------
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
    
    in_fix_filtered(n) = int32(y_eq ./ 128);    % scale down filter output
    
%     in_fix_filtered(n) = int32(in_hp_fix(n)); % bypass eq filter
    in_fix_filtered_no_gain(n) = in_fix_filtered(n);

    % ---------- AGC ----------
    P_in = int32(abs(in_fix_filtered(n)).^2);
    
    if P_in > P_prev
        P_tmp = int32((1 - alpha).*P_prev + int32(alpha.*P_in)); 
    else
        P_tmp = int32((1 - beta) .*P_prev + int32(beta .*P_in)); 
    end

    if P_tmp > 0 % avoid log10 of 0
        P(n) = 10.*log10(double(P_tmp)); % convert to dB
    else
        P(n) = 0;
    end
    
    if round(P(n)) > 0 % avoid index 0
        out_agc(n) = int32(in_fix_filtered(n) .* int32(LUT(round(P(n)))) / 2^(bits-1));
        gain_used(n) = double(LUT(round(P(n)))) / 2^(bits-1);
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
t = 1:length(in);

subplot(311)
plot(t, in, t, out, 'r--')
legend('in','out','Location','eastoutside')

subplot(312)
% plot(t, 10.*log10(double(in_fix_filtered_no_gain).^2), 'b',...
%      t, 10.*log10(double(in_fix_filtered).^2), 'r--')
plot(...t, P, 'b-', 
     t, real(20.*log10(double(in_fix_filtered_no_gain))), 'b',...
     t, real(20.*log10(double(out_agc))), 'r--', t, 82, 'm--')
legend('P_{in}', 'P_{out}', 'P_{max}', 'Location','eastoutside')
% plot(t, P, '', t, 82, 'r--')
% legend('P', 'P_{max}', 'Location','southeast')

subplot(313)
plot(t, gain_used)
% plot(t, in_fix_filtered - out_agc)
legend('gain','Location','eastoutside')