% clear all; 
% clf;
% load handel; in = y(1:end)./max(abs(in)); % input signal
% in = audioread('test_mono_8000Hz_16bit_PCM.wav'); in = in(1:6e4).*0.5;
% range = (1:end);
in = audioread('Speech_all.wav'); in = in./max(abs(in));
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
alpha = 0.02;
beta = 0.001;

P_x_fast = zeros(size(in));
% P_weighted = zeros(size(in));

for n = 1:length(in)
    % ----- AGC -----
    P_x_fast(n+1) = (1-alpha)*P_x_fast(n) + alpha*(abs(in(n))^2);
    P_weighted(n+1)=max(P_x_fast(n+1),P_weighted(n));

    slope = P_x_fast(n+1) - P_x_fast(n);

    if(slope <= 0)
        P_weighted(n+1) = (1-beta)*P_weighted(n+1);
    end
    
   
    if P_weighted(n+1) ~= 0
        P_dB(n) = 10*log10(P_weighted(n+1));
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