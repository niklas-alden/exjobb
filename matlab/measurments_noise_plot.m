clear all;
clf;

P_ref =     [60.2 66.3 70.5 75.2 80.0 85.5 91.0 95.0 98.0 103];
P_no_hp =   [60.3 65.7 70.3 74.8 79.6 82.1 83.7 84.5 85.1 85.2];
P_agc_off = [65.2 69.7 74.5 79.4 82.3 83.9 84.7 85.0 85.3 84.3];
P_agc_on =  [66.5 71.0 75.8 79.9 82.0 82.8 81.8 79.2 75.8 74.3];

P_ref2 =    [60.5 66.5 71.2 77.2 81.0 85.0 89.5 94.0 99.5];
P_no_hp2 =  [60.6 65.4 70.5 75.4 79.1 81.2 82.4 82.9 83.2];
P_peltor =  [68.6 72.4 77.0 77.5 76.3 76.7 79.0 78.4 79.2];
% P_out = zeros(size(P_in));
% 
% for i = 1:length(P_in)
%     P_out(i) = mean(abs(audioread(['recording' num2str(i) '.wav']) .* 2^15));
% end
% 
% P_out_dB = 10 * log10(P_out .^ 2);
% 
% P_out_ref = ones(1,100).*82;
% P_out_ref(1:81) = 1:81;
% plot(1:100, P_out_ref)
% hold on;
% grid on;
% plot(P_in, P_out_dB, 'ro')
subplot(121)
plot(60:105, [60:82 ones(1,23).*82], 'black--')
hold on;
plot(P_ref, P_no_hp, 'r-')
plot(P_ref, P_agc_off, 'b-')
plot(P_ref, P_agc_on, 'g-')
grid on
xlabel('P_{reference} / dB')
ylabel('P_{measured} / dB')
legend('Ideal', 'No hearing protectors', 'AGC off', 'AGC on', 'Location', 'southeast')

subplot(122)
plot(60:90, [60:82 ones(1,8).*82], 'black--')
hold on;
plot(P_no_hp, P_agc_off, 'b-')
plot(P_no_hp, P_agc_on, 'g-')
grid on
xlabel('P_{without hearing protectors} / dB')
ylabel('P_{measured} / dB')
legend('Ideal', 'AGC off', 'AGC on', 'Location', 'southeast')
