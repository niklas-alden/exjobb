clear all;
clf;
in_file1 = 'white_noise_steps';
in_file2 = 'p50_male';
in1 = audioread([in_file1 '.wav']);
in2 = audioread([in_file2 '.wav']);

plot(in1)
hold on;
plot(in2, 'r')