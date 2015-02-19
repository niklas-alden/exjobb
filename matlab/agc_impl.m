clear all; close all;

bits = 16;                      % resolution
load handel;                    % input signal
in = y;

% ----- HIGH PASS FILTER -----
[B, A] = high_pass_filter();
in_hp = filter(B, A, in);

% ----- FIXED POINT -----
in_fix = in_hp .* 2.^(bits-1);     % scale up to 2^bits-1
in_fix = round(in_fix);         % round off to integer
out_no_filter = in_fix ./ 2.^(bits-1);  % to compare outputs

% ----- EQ. FILTER -----
[B, A] = def_iir_filter();      % get filter coefficients
y = filter(B, A, in_fix);       % filtering with IIR filter
in_fix_filtered = y ./ (max(y) ./ max(in_fix));   % scale filter output
% figure(1)
% plot(1:length(in_fix), y, 1:length(in_fix), in_fix, 'r')

% ----- AGC -----
% P(n) = (1 - lambda)*P(n-1) + lambda*(x(n)^2), lambda = 0.05 (alpha, beta)
% if (P(n) < linear_limit) gain = 1 else 0 < gain < 1 (look-up table)
% out_agc = in_fix_filtered * gain


out = in_fix_filtered ./ 2.^(bits-1);    % scale down so -1 < output < 1

% figure(2)
plot(abs(in - out), 'r')        % plot error of filtered output
hold on
plot(abs(in - out_no_filter))   % plot error of unfiltered output
