clf;
[B, A] = def_iir_filter();
load handel;
in = y;
y2 = filter(B, A, in)./100;
t = 1:length(in);

y = zeros(size(in));
y_pre = 0;
y_pre_pre = 0;
x_pre = 0;
x_pre_pre = 0;

for n = 1:length(in)
    x = in(n);
    y(n) = -A(2)*y_pre - A(3)*y_pre_pre + B(1)*x + B(2)*x_pre + B(3)*x_pre_pre;
    x_pre_pre = x_pre;
    x_pre = x;
    y_pre_pre = y_pre;
    y_pre = y(n);
end

subplot(211)
plot(t, y2, t, in, 'r')
subplot(212)
plot(t, in, t, y./128, 'r--')