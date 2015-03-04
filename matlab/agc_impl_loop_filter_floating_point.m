% clear all; 
clf;
% load handel; in = y(1:5000).*1; % input signal
% in = audioread('test_mono_8000Hz_16bit_PCM.wav'); in = in(1:3e4);%.*1.2;
in = audioread('Speech_all.wav'); in = in(1:end).*1;
% in = audioread('p50_male.wav'); in = in(1:5e4).*1;
% in = audioread('p50_female.wav'); in = in(1:5e4).*1;
% in = ones(1,1200).*1e-4; in(50:600) = 1;

LUT = agc_lut();
P_prev = 0;

% Arrays used for plotting, replace with single registers in hardware design
in_hp = zeros(size(in));
in_filtered = zeros(size(in));
P = zeros(size(in));
% P_tmp = zeros(size(in));
out_agc = zeros(size(in));
gain_used = zeros(size(in));
out = zeros(size(in));

% high pass filter parameters
[B_hp, A_hp] = high_pass_filter();
y_hp_pre = 0;
x_hp_pre = 0;

% equalizer filter parameters
[B_eq, A_eq] = def_iir_filter();
y_eq_pre = 0;
y_eq_pre_pre = 0;
x_eq_pre = 0;
x_eq_pre_pre = 0;

% tune parameters
alpha = 0.005;
beta = 0.03;

for n = 1:length(in)
    % ----- HIGH PASS FILTER -----
    in_hp(n) = -A_hp(2) * y_hp_pre...
              + B_hp(1) * in(n) * 2^15 ...
              + B_hp(2) * x_hp_pre;
    x_hp_pre = in(n) * 2^15;
    y_hp_pre = in_hp(n);
    
    % ----- EQUALIZER FILTER -----
    y_eq = - A_eq(2) * y_eq_pre...
           - A_eq(3) * y_eq_pre_pre...
           + B_eq(1) * in_hp(n)...
           + B_eq(2) * x_eq_pre...
           + B_eq(3) * x_eq_pre_pre;
    x_eq_pre_pre = x_eq_pre;
    x_eq_pre = in_hp(n);
    y_eq_pre_pre = y_eq_pre;
    y_eq_pre = y_eq;
    
    in_filtered(n) = y_eq / 2^7;
    
    % ----- AGC -----
    P_in = abs(in_filtered(n)) ^ 2;
    
    if P_in > P_prev
        P_tmp = (1 - alpha) * P_prev + alpha * P_in;
    else
        P_tmp = (1 - beta) * P_prev + beta * P_in;
    end
    
    if P_tmp > 1
        P(n) = 10*log10(P_tmp);% - 82;
    else
        P(n) = 0;%-82;
    end
    
    if round(P(n)) > 0
        out_agc(n) = in_filtered(n) * LUT(round(P(n)));% + 82);
        gain_used(n) = LUT(round(P(n)));% + 82);
    else
        out_agc(n) = in_filtered(n);
        gain_used(n) = 1;
    end
    
    P_prev = abs(out_agc(n)) ^ 2;
    
    out(n) = out_agc(n) / 2^15;
end

% figure(1)
% clf
% t = 1:length(in);
% 
% subplot(311)
% plot(t, in, t, out, 'r--')
% legend('in','out','Location','eastoutside')
% 
% subplot(312)
% % plot(t, 10.*log10(double(in_fix_filtered_no_gain).^2), 'b',...
% %      t, 10.*log10(double(in_fix_filtered).^2), 'r--')
% plot(t, P, 'b', t, 82, 'r--'...
%      ...,t, real(20.*log10(double(in_fix_filtered))) - 82, 'm',...
%      ...t, real(20.*log10(double(out_agc))) - 82, 'g--'...
%      )
% % legend('P_{max}', 'P', 'P_{in}', 'P_{out}', 'Location','eastoutside')
% legend('P', 'P_{max}', 'Location','eastoutside')
% 
% subplot(313)
% plot(t, gain_used, 'b-')
% legend('gain','Location','eastoutside')