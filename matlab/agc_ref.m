clc
clear
close all

T    = 3;     % Time in Seconds
Fs   = 16000; % Sample Rate
Freq = 440;  % Frequency in Hertz
t = [0 : (Freq*2*pi)/Fs : Freq*2*pi*T];
x = sin(t)*0.4;
x(floor(end/3):floor(2/3*end)) = x(floor(end/3):floor(2/3*end))*2.5;
x(floor(3/4*end):floor(end)) = x(floor(3/4*end):floor(end))*2.5;

alpha = 0.01;   %fast
beta = 0.0002; %slow

P_x_fast = zeros(size(x));
P_weighted = zeros(size(x));

for n = 1 : length(x)
    P_x_fast(n+1) = (1-alpha)*P_x_fast(n) + alpha*x(n)*conj(x(n));
    P_weighted(n+1)=max(P_x_fast(n+1),P_weighted(n));

    slope = P_x_fast(n+1) - P_x_fast(n);

    if(slope <= 0)
        P_weighted(n+1) = (1-beta)*P_weighted(n+1);
    end
end

hold on
plot_size = Fs*T - 20;
plot(x(1:plot_size))
plot(P_weighted(1:plot_size), 'r')
%plot(Px_slow(1:plot_size), 'y')
%plot(y(1:plot_size), 'g')
%plot(y, 'g')
legend('Input', 'Px_{fast_up_slow_down}'); %, 'Px_{slow}', 'Output')

%soundsc(y, Fs);