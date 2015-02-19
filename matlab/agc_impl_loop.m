clear all; clf;

bits = 16;                      % resolution
% load handel; in = y.*1;%(1:2e4); % input signal
% in(17000:18000) = 0;
% in(18001:19000) = 1;
% in(19001:20000) = 0;
% in = audioread('test_mono_8000Hz_16bit_PCM.wav'); in = in(1:3e4);%.*1.2;
in = zeros(1,3e3); in(2e2:2e3) = 1;

in_hp = zeros(size(in));        % allocate high pass filtered input signal array
in_fix = zeros(size(in), 'int16');   % allocate fixed point input signal array
out_no_filter = zeros(size(in)); % allocate unfiltered output signal array
in_fix_filtered = zeros(size(in), 'int16'); % allocate fixed point filtered input signal array
in_fix_filtered_no_gain = zeros(size(in), 'int16'); 
out = zeros(size(in));          % allocate output signal array
P = zeros(size(in), 'int32');   % allocate power of fixed point input signal array
P_tmp = zeros(size(in), 'int32');   % allocate power of fixed point input signal array
[B_hp, A_hp] = high_pass_filter();  % get high pass filter coefficients
[B_eq, A_eq] = def_iir_filter();    % get eq. filter coefficients
alpha = 0.001;                   % attack time ~ < 5ms
beta  = 0.3;                    % release time ~ 30-40ms
P_prev = int32(1);              % Previous power value of input signal (memory)
LUT = agc_lut();                % Lookup table with gain values
gain_used = zeros(size(in));

for n = 1:length(in)
    % ----- HIGH PASS FILTER -----
    in_hp(n) = filter(B_hp, A_hp, in(n));
    
    % ----- FIXED POINT -----
    in_fix(n) = round(in_hp(n) .* 2.^(bits-1));   % scale up to 2^bits-1 and round off to integer
    out_no_filter(n) = double(in_fix(n)) ./ 2.^(bits-1);  % to compare outputs
    
    % ----- EQ. FILTER -----
    y_eq = filter(B_eq, A_eq, double(in_fix(n)));   % filtering with IIR filter
    in_fix_filtered(n) = y_eq ./ 128;               % scale down filter output
    in_fix_filtered_no_gain(n) = in_fix_filtered(n);

    % ----- AGC -----
    % P(n) = (1 - lambda)*P(n-1) + lambda*(x(n)^2), lambda = (alpha, beta)
    P_in = int32(in_fix_filtered(n)).^2;
    P_a = int32((1 - alpha).*P_prev + int32(alpha.*P_in)); 
    P_b = int32((1 - beta) .*P_prev + int32(beta.* P_in)); 
    if P_a > P_prev
        P_tmp(n) = P_a;
    else
        P_tmp(n) = P_b;
    end

% ***** TEMPORARY SOLUTION *****
%     P_tmp(n) = (1 - lambda).*P_prev + int32(lambda.*(int32(in_fix_filtered(n)).^2)); 
    P(n) = 10.*log10(double(P_tmp(n))); % convert to dB
    P_prev = P_tmp(n); % TEST, var P(n) tidigare
    
    if P(n) > 1
        out_agc = int16(in_fix_filtered(n) .* LUT(round(P(n))));
        gain_used(n) = LUT(round(P(n)));
    else
        out_agc = int16(in_fix_filtered(n));
        gain_used(n) = 1;
    end

%     TEST
%     P_tmp(n) = (1 - lambda).*real(P_prev) + int32(lambda.*(int32(in_fix_filtered(n)).^2)); 
%     P(n) = 10.*log10(double(P_tmp(n)));
%     P_prev = P(n);
%     SLUT TEST
    
%     out(n) = double(in_fix_filtered(n)) ./ 2.^(bits-1);    % scale down so -1 < output < 1
    out(n) = double(out_agc) ./ 2.^(bits-1);    % scale down so -1 < output < 1
end

figure(1)
subplot(311)
plot(1:length(in), in_fix_filtered_no_gain, 1:length(in), out.*2.^(bits-1), 'r--')
%plot(out)

subplot(312)
% plot(1:length(in), 10.*log10(double(in_fix_filtered_no_gain).^2), 'b',...
%      1:length(in), 10.*log10(double(in_fix_filtered).^2), 'r--')
plot(1:length(in), P, 1:length(in), 82, 'r')


 subplot(313)
 plot(1:length(in), gain_used)
% figure(2)
% plot(abs(in - out), 'r')        % plot error of filtered output
% hold on
% plot(abs(in - out_no_filter))   % plot error of unfiltered output
