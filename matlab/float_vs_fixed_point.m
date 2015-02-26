clear all; close all;
% bits = 16;
load handel;
in = y;
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
subplot(211)
plot(variance);
grid on;
subplot(212)
semilogy(variance); 
grid on