clear all;
clf;

P_ideal =   [55:82 ones(1,28).*82];
P_ref =    [59.5 65   69   74   79   83   88   92   96   101  106];
P_peltor = [66   73.1 75.1 76.5 80.3 80.4 80.6 81.2 81.3 81.5 81.5];
P_fpga =   [59.5 67   69.4 72.7 78.2 80.8 80.9 79.4 78.8 79.1 79.4];
P_ideal_cmp = [P_ref(1:5), ones(1,6).*82];

figure(1)
plot(55:110, P_ideal, 'black--', 'Linewidth', 2)
hold on;
grid on
plot(P_ref, P_peltor, 'bd-', 'Linewidth', 2)
plot(P_ref, P_fpga, 'rs-', 'Linewidth', 2)
axis([59 107 59 85])
xlabel('P_{noise} (dB)')
ylabel('P_{measured} (dB)')
legend('Ideal', 'Reference (Peltor Tactical 7)', 'This thesis (FPGA + Peltor Tactical 7-SH)', 'Location', 'southeast')

figure(2)
plot(P_ref, zeros(size(P_ref)), 'black--', 'Linewidth', 2)
hold on;
grid on;
plot(P_ref, (P_peltor-P_ideal_cmp), 'b-d', 'Linewidth', 2)
plot(P_ref, (P_fpga-P_ideal_cmp), 'r-s', 'Linewidth', 2)
axis([59 107 -5 10])
xlabel('P_{noise} (dB)')
ylabel('Differense from ideal curve (dB)')
legend('Ideal', 'Reference (Peltor Tactical 7)', 'This thesis (FPGA + Peltor Tactical 7-SH)', 'Location', 'northeast')
