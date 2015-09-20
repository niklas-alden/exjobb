% clear all; 
% clf;
% load handel; in = y(1:end).*1; % input signal
% in = audioread('test_mono_8000Hz_16bit_PCM.wav'); in = in(1:3e4);%.*1.2;
range = (6e3:7e3);
in = audioread('Speech_all.wav'); in = in(range)./max(abs(in(range)));
% in = audioread('p50_male.wav'); in = in(1:5e4).*1;
% in = audioread('p50_female.wav'); in = in(1:5e4).*1;
% in = ones(1,1200).*1e-4; in(50:600) = 1;

LUT = agc_lut_dB();
P_prev = 0;

% Arrays for plotting
P = zeros(size(in));
P_weighted = zeros(size(in));
out_agc = zeros(size(in));
gain_used = zeros(size(in));
out = zeros(size(in));

% time constants
alpha = 0.9;
beta = 0.01;

for n = 1:length(in)
    % ----- AGC -----
    P_in = abs(in(n)) ^ 2;
    
    if P_in > P_prev
        P_weighted(n) = (1 - alpha) * P_prev + alpha * P_in;
    else
        P_weighted(n) = (1 -  beta) * P_prev +  beta * P_in;
    end
    
    if P_weighted(n) ~= 0
        P(n) = 10*log10(P_weighted(n));
    else
        P(n) = 0;
    end
    
    if round(P(n)) > -82
        out_agc(n) = in(n) * LUT(round(P(n)) + 82);
        gain_used(n) = LUT(round(P(n)) + 82);
    else
        out_agc(n) = in(n);
        gain_used(n) = 1;
    end
    
    P_prev = abs(out_agc(n)) ^ 2;
    
    out(n) = out_agc(n);
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
plot(t, P, 'b'..., t, -10, 'r--'...
     ...,t, real(20.*log10(double(in_fix_filtered))) - 82, 'm',...
     ,t, real(20.*log10(out_agc)), 'g--'...
     )
% legend('P_{max}', 'P', 'P_{in}', 'P_{out}', 'Location','eastoutside')
legend('P', 'P_{out}', 'Location','eastoutside')

subplot(313)
plot(t, gain_used, 'b-')
legend('gain','Location','eastoutside')