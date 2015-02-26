clf; clear all;
[B, A] = def_iir_filter(); 

bits = 16 - 1;
filter_bits = 10 - 1;
B_matlab = int32(B .* 2^filter_bits);
A_matlab = int32(A .* 2^filter_bits);

B_eq = int32(B .* 2^filter_bits); 
A_eq = int32(A .* 2^filter_bits);

% load handel; in = y;
in = audioread('Speech_all.wav'); 
% in = audioread('p50_male.wav'); 
% in = ones(1,1200).*1e-4; in(50:600) = 1;
in_fix = int16(round(in(1:end) .* (2.^bits)));

y2 = filter(double(B_eq), double(A_eq), double(in_fix));

t = 1:length(in_fix);

y = zeros(size(in_fix), 'int32');
y_pre = int32(0);
y_pre_pre = int32(0);
x_pre = int32(0);
x_pre_pre = int32(0);

for n = t
    y(n) = int32(int32(int32(B_eq(1)) * int32(in_fix(n)))...
               + int32(int32(B_eq(2)) * int32(x_pre))...
               + int32(int32(B_eq(3)) * int32(x_pre_pre))...
               - int32(int32(A_eq(2)) * int32(y_pre))...
               - int32(int32(A_eq(3)) * int32(y_pre_pre)));
    y(n) = y(n) ./ 2^filter_bits;
    x_pre_pre = int32(x_pre);
    x_pre = int32(in_fix(n));
    y_pre_pre = int32(y_pre);
    y_pre = int32(y(n));
end

% y = zeros(size(in));
% y_pre = 0;
% y_pre_pre = 0;
% x_pre = 0;
% x_pre_pre = 0;
% 
% for n = t
%     y(n) = B(1)*in(n) + B(2)*x_pre + B(3)*x_pre_pre - A(2)*y_pre - A(3)*y_pre_pre;
%     x_pre_pre = x_pre;
%     x_pre = in(n);
%     y_pre_pre = y_pre;
%     y_pre = y(n);
% end

in_fix_no_filter = double(in_fix) ./ 2^bits;

y2_scaled = y2 ./ 128;
out_matlab_filter = double(y2_scaled) ./ 2^bits;

y_scaled = y ./ 128;
out = double(y_scaled) ./ 2^bits;

clf
subplot(211)
plot(t, in, t, out_matlab_filter, 'r--')
subplot(212)
plot(t, in, t, out, 'r--')

