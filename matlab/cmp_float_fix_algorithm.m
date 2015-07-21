clear all;
clf;

agc_impl_loop_filter_floating_point
out_float = out;

agc_impl_loop_filter_0dB
out_fix = out;

plot(abs(out_fix - out_float))
var(out_fix - out_float)