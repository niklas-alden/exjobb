clear all; clf;

agc_impl_loop_filter_0dB
out_fix = out;

agc_impl_loop_filter_floating_point
out_float = out;

t = 1:length(out);

subplot(221)
plot(t, out_float, 'b')
xlabel('Sample')
ylabel('out_{floating point}')
grid on

subplot(223)
plot(t, out_fix, 'r')
xlabel('Sample')
ylabel('out_{fixed point}')
grid on

% subplot(313)
% semilogy(t, abs(out_float - out_fix), 'm')
% grid on

subplot(222)
plot(t, abs(out_float - out_fix), 'm')
xlabel('Sample')
ylabel('abs(out_{float} - out_{fix})')
grid on

subplot(224)
semilogy(t, abs(out_float - out_fix), 'm')
xlabel('Sample')
ylabel('abs(out_{float} - out_{fix})')
grid on