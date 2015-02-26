clf
t = linspace(1,100,10000);
f = @(t,G) G.*sin(2.*pi.*2e3.*t);

in1 = [f(t(1:1000),0.01), f(t(1001:3000),0.1), f(t(3001:5000),0.3),...
    f(t(5001:7000),0.6), f(t(7001:9000),1), f(t(9001:end),0.01)];

in2 = zeros(size(t));
for i = 1e3:1e3:length(t)-1
    in2(i:i+10) = 1;
end

plot(t, in2)