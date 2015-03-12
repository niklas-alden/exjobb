clear all;
clf;

i = 1:1e3:0.5e9;
% i = 1:100;
i_db = 10.*log10(i) -82;

subplot(211)
semilogx(i_db)
grid on
subplot(212)
loglog(i)
grid on