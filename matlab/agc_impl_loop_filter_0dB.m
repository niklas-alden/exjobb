% clear all; 
% clf;
bits = 12;              % resolution of data
filter_bits = 10;       % resolution of filter coefficients
% load handel; in = y(1:5000).*1; % input signal
% in = audioread('test_mono_8000Hz_16bit_PCM.wav'); in = in(1:3e4);%.*1.2;
in = audioread('Speech_all.wav'); in = in(39280:39300).*1;
% in = audioread('p50_male.wav'); in = in(1:5e4).*1;
% in = audioread('p50_female.wav'); in = in(1:5e4).*1;
% in = ones(1,1200).*1e-4; in(50:600) = 1;
% t = linspace(1,100,10000);
% f = @(t,G) G.*sin(2.*pi.*2e3.*t);
% in = [f(t(1:1000),0.01) f(t(1001:6000),1) f(t(6001:9000),0.01)];% f(t(5001:7000),0.6) f(t(7001:9000),1) f(t(9001:end),0.01)];


LUT = int16(agc_lut() .* 2^(16-1));         % Lookup table with gain values
P_prev = int32(0);                          % Previous power value of input signal (memory)

% Arrays used for plotting, replace with single registers in hardware design
in_hp = zeros(size(in));                    
in_fix = zeros(size(in), 'int16');          % fixed point input signal array
in_hp_fix = zeros(size(in), 'int16');       
in_fix_filtered = zeros(size(in), 'int16'); % fixed point filtered input signal array
% in_fix_filtered_no_gain = zeros(size(in), 'int32');
P = zeros(size(in), 'int16');               % power of fixed point input signal array
P_tmp = zeros(size(in), 'int32');   % allocate power of fixed point input signal array
out_agc = zeros(size(in), 'int32');
gain_used = zeros(size(in), 'double');      % array to see what gain the agc used 
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
alpha = int32(0.005 .* 2^(16-1));    % attack time ~ < 5ms
beta  = int32(0.03 .* 2^(16-1));     % release time ~ 30-40ms

for n = 1:length(in)
    % ----- FIXED POINT -----
    in_fix(n) = int16( round(in(n) .* (2^(bits-1))) .* 2^(16-bits) ); % scale up to 2^bits-1 and round off to integer
    
    % ----- HIGH PASS FILTER -----
    in_hp = int32(-A_hp(2) * y_hp_pre...
                       + B_hp(1) * int32(in_fix(n))...
                       + B_hp(2) * x_hp_pre);
    in_hp = int32(floor(double(in_hp) / 2^(filter_bits-1)));
    x_hp_pre = int32(in_fix(n));
    y_hp_pre = int32(in_hp);
    
    in_hp_fix(n) = int16(in_hp);
%     in_hp_fix(n) = int16(in_fix(n)); % bypass high pass filter
    
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
    
%     in_fix_filtered(n) = int32(in_hp_fix(n)); % bypass eq filter
%     in_fix_filtered_no_gain(n) = in_fix_filtered(n);

    % ----- AGC -----
    P_in = int32(abs(int32(in_fix_filtered(n))).^2);
    
    if P_in > P_prev
        P_tmp(n) = int32(((1*2^(16-1) - alpha).*(P_prev / 2^(16-1))) + (int32(alpha.*P_in) / 2^(16-1)));
    else
        P_tmp(n) = int32(((1*2^(16-1) - beta) .*(P_prev / 2^(16-1))) + (int32(beta .*P_in) / 2^(16-1)));
    end

    if P_tmp(n) ~= 0 % avoid log10 of 0
        P(n) = 10.*log10(double(P_tmp(n))) - 82; % convert to dB, 82 dB as referense
    else
        P(n) = -82;
    end
    
    if round(P(n)) > -82 % avoid index 0
        out_agc(n) = int16(int32(in_fix_filtered(n)) .* int32(LUT(round(P(n)) + 82)) / 2^(16-1));
        gain_used(n) = double(LUT(round(P(n)) + 82)) / 2^(16-1);
    else
        out_agc(n) = int16(in_fix_filtered(n));
        gain_used(n) = 1;
    end

    P_prev = int32(abs(int32(out_agc(n))).^2);

    out(n) = double(out_agc(n)) ./ 2.^(16-1);    % scale down so -1 < output < 1
%     out(n) = double(in_fix_filtered(n)) ./ (2.^(bits-1));    % BYPASS scale down so -1 < output < 1
%     out(n) = double(in_hp_fix(n)) ./ 2.^(bits-1);    % BYPASS scale down so -1 < output < 1
end

% fileID = fopen('in_fixed.txt', 'w');
% fprintf(fileID, '%d\r\n', in_fix);
% fclose(fileID);
% 
% fileID = fopen('in_fix_filtered.txt', 'w');
% fprintf(fileID, '%d\r\n', in_fix_filtered);
% fclose(fileID);
% 
% fileID = fopen('out_fixed.txt', 'w');
% fprintf(fileID, '%d\r\n', out_agc);
% fclose(fileID);

figure(1)
clf
t = 1:length(in);

subplot(311)
plot(t, in, t, out, 'r--')
legend('in','out','Location','eastoutside')

subplot(312)
% plot(t, 10.*log10(double(in_fix_filtered_no_gain).^2), 'b',...
%      t, 10.*log10(double(in_fix_filtered).^2), 'r--')
plot(t, P, 'b', t, 0, 'r--'...
     ...,t, real(20.*log10(double(in_fix_filtered))) - 82, 'm',...
     ...t, real(20.*log10(double(out_agc))) - 82, 'g--'...
     )
% legend('P_{max}', 'P', 'P_{in}', 'P_{out}', 'Location','eastoutside')
legend('P', 'P_{max}', 'Location','eastoutside')

subplot(313)
plot(t, gain_used)
legend('gain','Location','eastoutside')