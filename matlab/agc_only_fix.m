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


LUT = int16(agc_lut_dB() .* 2^(bits-1));         % Lookup table with gain values
% P_prev = 0;

% Arrays for plotting
in_fix = zeros(size(in), 'int16');
P_in = zeros(size(in), 'int32');
P_dB = zeros(size(in), 'int16');
P_weighted = zeros(size(in), 'int32');
out_agc = zeros(size(in), 'int32');
gain_used = zeros(size(in), 'double');
% P_out = zeros(size(in), 'int32');
out = zeros(size(in));

% time constants
alpha = int32(0.02 .* 2^(16-1));    % attack time ~ 1ms
beta  = int32(0.001 .* 2^(16-1));   % release time ~ 300ms

P_x_fast = zeros(size(in));
% P_weighted = zeros(size(in));

for n = 1:length(in)
    in_fix(n) = int16( round(in(n) .* (2^(bits-1))) .* 2^(16-bits) ); % scale up to 2^bits-1 and round off to integer
    
    % ----- AGC -----
    P_in(n) = int32(abs(int32(in_fix(n))).^2);
    
    P_x_fast(n+1) = int32(((1*2^(16-1) - alpha).*(P_x_fast(n) / 2^(16-1))) + (int32(alpha.*P_in(n)) / 2^(16-1)));
%     P_x_fast(n+1) = (1-alpha)*P_x_fast(n) + alpha*(abs(in(n))^2);
    P_weighted(n+1) = max(P_x_fast(n+1), P_weighted(n));

    slope = P_x_fast(n+1) - P_x_fast(n);
% figure(2)
% plot(n,slope,'+');
% hold on;
    if(slope <= 0)
%         disp(n)
%         disp(['before  ', num2str(P_weighted(n+1))])
%         P_weighted(n+1)
%         (P_weighted(n+1) / 2^(16-1))
        P_weighted(n+1) = int32( int64(1*2^(16-1) - beta) .* int64(P_weighted(n+1)) / 2^(16-1));
        
%         disp(['after   ', num2str(P_weighted(n+1))])
%         int32((1*2^(16-1) - beta) .* ((P_weighted(n+1) / 2^(16-1))))
%         P_weighted(n+1)
%         disp('---------------------------------------------------------------')
%         P_weighted(n+1) = (1-beta)*P_weighted(n+1);
    end
    
   
    if P_weighted(n+1) ~= 0
        P_dB(n) = 10*log10(double(P_weighted(n+1))) - 82;
    else
        P_dB(n) = -82;
    end
    
    if round(P_dB(n)) > -82
        out_agc(n) = int16(int32(in_fix(n)) .* int32(LUT(round(P_dB(n)) + 82)) / 2^(16-1));
%         out_agc(n) = in(n) * LUT(round(P_dB(n)) + 82);
        gain_used(n) = double(LUT(round(P_dB(n)) + 82)) / 2^(16-1);
    else
        out_agc(n) = int16(in_fix(n));
        gain_used(n) = 1;
    end
    
%     P_prev = abs(out_agc(n)) ^ 2;
%     P_out(n) = 10*log10(P_prev);
    
    out(n) = double(out_agc(n)) ./ 2.^(16-1);    % scale down so -1 < output < 1
%     out(n) = out_agc(n);    
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