% clear all; 
% clf;
% load handel; in = y(1:end).*1; % input signal
% in = audioread('test_mono_8000Hz_16bit_PCM.wav'); in = in(1:3e4);%.*1.2;
range = (6e3:7e3);
in = audioread('Speech_all.wav'); in = in(range)./max(abs(in(range)));
% in = audioread('p50_male.wav'); in = in(1:5e4).*1;
% in = audioread('p50_female.wav'); in = in(1:5e4).*1;
% in = [[0:0.05:1] [0.95:-0.05:0] [0.05:0.05:1] [0.95:-0.05:0]];


LUT = agc_lut_dB();
P_prev = 0;

% Arrays for plotting
P_in = zeros(size(in));
P_dB = zeros(size(in));
P_weighted = zeros(size(in));
out_agc = zeros(size(in));
gain_used = zeros(size(in));
P_out = zeros(size(in));
out = zeros(size(in));

% time constants
alpha = 0.9;
beta = 0.0001;

for n = 1:length(in)
    % ----- AGC -----
    P_in(n) = abs(in(n)) ^ 2;
    
    if P_in(n) > P_prev
        P_weighted(n) = (1 - alpha) * P_prev + alpha * P_in(n);
    else
        P_weighted(n) = (1 -  beta) * P_prev +  beta * P_in(n);
    end
    
    if P_weighted(n) ~= 0
        P_dB(n) = 10*log10(P_weighted(n));
    else
        P_dB(n) = 0;
    end
    
    if round(P_dB(n)) > -82
        out_agc(n) = in(n) * LUT(round(P_dB(n)) + 82);
        gain_used(n) = LUT(round(P_dB(n)) + 82);
    else
        out_agc(n) = in(n);
        gain_used(n) = 1;
    end
    
    P_prev = abs(out_agc(n)) ^ 2;
    P_out(n) = 10*log10(P_prev);
    
    out(n) = out_agc(n);
end

figure(1)
clf
t = 1:length(in);

subplot(221)
plot(t, in, t, out, 'r--')
legend('in','out','Location','Southeast')

subplot(223)
plot(t, P_dB, 'b', t, P_out, 'g--')
legend('P_{weighted}', 'P_{out}', 'Location','Southeast')

subplot(224)
plot(t(2:end), 10.*log10(P_in(2:end)), 'b', t(1:end-1), P_out(1:end-1), 'g--')
legend('P_{x[n]}', 'P_{y[n-1]}', 'Location','Southeast')

subplot(222)
plot(t, gain_used, 'b-')
legend('gain','Location','Southeast')