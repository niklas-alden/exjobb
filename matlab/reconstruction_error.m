%%
clear all; 
clf;
bits = 3;
t1 = linspace(1,3,1000);%0:0.001:3;
t2 = t1(1:10:end);%linspace(1,3,100);%0:0.1:3;

in = sin(2.*pi.*t1) + sin(3.5.*pi.*t1) + sin(4.*pi.*t1) + sin(5.*pi.*t1);
in = in./max(in);

in_fix = int16(in .* 2^bits);
in_fix2 = zeros(size(in_fix));
for i = 2:length(t1)
    if mod(i,10) == 0
        in_fix2(i) = in_fix(i);
    else
        in_fix2(i) = in_fix2(i-1);
    end
end
% 
% in_fix3 = in_fix2(1:10:end);
% p1 = polyfit(t2, in_fix3, 20);
% in_fix4 = polyval(p1, t1);

out = double(in_fix2) ./ 2^bits;
out_sample = out(1:10:end);
noise = in - out;

plot(t1, in, 'b', 'LineWidth', 3)
hold on
% grid on
stem(t2, out_sample, 'k', 'LineWidth', 2, 'MarkerFaceColor', 'g')
plot(t1, out, 'k--', 'LineWidth', 2)
% plot(t2, out(1:100:end), 'g', 'LineWidth', 2)
plot(t1, noise, 'r', 'LineWidth', 1)

axis([1.61 2.29 -0.8 0.8])
set(gca, 'XTickLabelMode', 'manual', 'XTickLabel', []);
set(gca, 'YTickLabelMode', 'manual', 'YTickLabel', []);
xlabel('Time','FontSize',14)
ylabel('Magnitude','FontSize',14)
h_legend = legend('Location','northwest','original signal', 'sampled signal', 'recreated signal', 'quantization error');
set(h_legend,'FontSize',14);
legend('boxoff')

%%
% t1 = 0:0.001:3;
% t2 = 0:0.1:3;
% t3 = 0:0.01:3;
% in = sin(2.*pi.*t1) + sin(3.5.*pi.*t1) + sin(4.*pi.*t1) + sin(5.*pi.*t1);
% in = in./max(in);
% 
% in_fix = int16(in .* 2^3);
% out = double(in_fix) ./ 2^3;
% 
% plot(t1, in, t1, out)