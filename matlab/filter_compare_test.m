clf; clear all;
[B, A] = def_iir_filter(); %A = A./128; B = B./128;
bits = 15;
B_eq = int32(B .* 2^bits);
A_eq = int32(A .* 2^bits);
% [B, A] = high_pass_filter();
% load handel;
audio_in = audioread('Speech_all.wav'); 
in_fix = int16(round(audio_in(1:end) .* (2.^bits)));
% in = ones(1,1200).*1e-4; in(50:600) = 1;

% y2 = filter(B, A, double(in_fix));
t = 1:length(in_fix);

y = zeros(size(in_fix), 'int32');
y_pre = int32(0);
y_pre_pre = int32(0);
x_pre = int32(0);
x_pre_pre = int32(0);

for n = t
    y(n) = int32(int32(int32(-A_eq(2))* int32(y_pre))...
               - int32(int32(A_eq(3)) * int32(y_pre_pre))...
               + int32(int32(B_eq(1)) * int32(in_fix(n)))...
               + int32(int32(B_eq(2)) * int32(x_pre))...
               + int32(int32(B_eq(3)) * int32(x_pre_pre)));
    y(n) = y(n) ./ 2^bits;
    x_pre_pre = int32(x_pre);
    x_pre = int32(in_fix(n));
    y_pre_pre = int32(y_pre);
    y_pre = int32(y(n));
end

% y2_scaled = y2 ./ 128;
in_fix_no_filter = double(in_fix) ./ 2^bits;
% out_matlab_filter = double(y2_scaled) ./ 2^15;

y_scaled = y ./ 1;
out = double(y_scaled) ./ 2^bits;
% for n = 1:length(in)
%     x = in(n);
%     y(n) = -A(2)*y_pre + B(1)*x + B(2)*x_pre;
%     x_pre = x;
%     y_pre = y(n);
% end

clf
% subplot(211)
% plot(t, out_matlab_filter, t, in_fix_no_filter, 'r--')
% subplot(212)
% plot(t, out, t, in_fix_no_filter, 'r--')
plot(t, in_fix_no_filter, t, out, 'r--')

