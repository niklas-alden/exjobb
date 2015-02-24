clf;
[B, A] = def_iir_filter(); %A = A./128; B = B./128;
% [B, A] = high_pass_filter();
load handel;
in = int32(y.*2^16);
% in = ones(1,1200).*1e-4; in(50:600) = 1;
y2 = filter(B, A, double(in));
t = 1:length(in);

y = zeros(size(in), 'int32');
y_pre = int32(0);
y_pre_pre = int32(0);
x_pre = int32(0);
x_pre_pre = int32(0);

% y_pre = int32(0);
% x_pre = int32(0);


for n = 1:length(in)
    x = in(n);
    y(n) = int32(-A(2)*int32(y_pre) - A(3)*int32(y_pre_pre) + B(1)*int32(x) + B(2)*int32(x_pre) + B(3)*int32(x_pre_pre));
    x_pre_pre = int32(x_pre);
    x_pre = int32(x);
    y_pre_pre = int32(y_pre);
    y_pre = int32(y(n));
end

% for n = 1:length(in)
%     x = in(n);
%     y(n) = -A(2)*y_pre + B(1)*x + B(2)*x_pre;
%     x_pre = x;
%     y_pre = y(n);
% end

clf
% subplot(211)
% plot(t, y2, t, in, 'r--')
% subplot(212)
plot(t, y, t, in, 'r--')
x_power = sum(in.^2)./length(in)
y_power = sum(y.^2)./length(y)