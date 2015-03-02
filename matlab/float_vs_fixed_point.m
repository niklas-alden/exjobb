clear all; close all;
% bits = 16;
load handel;
in = y(1:10);
% in = audioread('test_mono_8000Hz_16bit_PCM.wav');
% in = rand(10000, 1);
% in = in(1:10)

max_bits = 32;
variance = zeros(max_bits,1);
for bits = 1:max_bits
    in_fixed = round(in .* 2.^(bits-1));
    out = in_fixed ./ 2.^(bits-1);
    variance(bits) = var(abs(in-out));
end

in_10 = round(in .* 2^9);
in_10_16 = in_10 .* 2^6;
in_16 = round(in .* 2^15);

t = 1:length(in);
subplot(211)
% plot(t, in, t, double(in_10_16)./2^15, 'r', t,double(in_16)./2^15), 'g';
plot(variance)
grid on;
subplot(212)
% plot(var(abs(in_10_16 - in_16)), '*'); 
semilogy(variance)
grid on