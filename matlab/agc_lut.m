% %%
function [gain] = agc_lut(~)
    n = 100;
    P_in = 1:n;

    lut = ones(n,4);
    lut(:,1) = 1:n;

    % ideal
    max = 82;
    for i = 1:n
        if i < max
            lut(i,2) = 1;
        else
            lut(i,2) = max / P_in(i);
        end
    end
    
    % tanh
    a = 0.015;
    b = 65; % var 82 innan
    y_tanh = b .* (1 - exp(-a.*2.*P_in)) ./ (1 + exp(-a.*2.*P_in));
    lut(1:end, 3) = y_tanh(1:end) ./ P_in(1:end);

    % polynomial
    x_poly = [20 50 51];%x_poly = [60 61 105 106];
    y_poly = [20 45 45];%y_poly = [60 61 82 82];
    p_coeff = polyfit(x_poly, y_poly, 2);
    yy = polyval(p_coeff, P_in);
%     lut(62:104, 4) = yy(62:104) ./ P_in(62:104);
%     lut(105:end, 4) = lut(105:end, 2);
    lut(44:end, 4) = yy(44:end) ./ P_in(44:end);
%     lut(105:end, 4) = lut(105:end, 2);
    
    % return prefered lookup table
    % 2 = ideal
    % 3 = tanh
    % 4 = polynomial
    gain = lut(:,4);


% clf;
figure(2)
subplot(211)
plot(P_in, P_in'.*lut(P_in,2), 'b--')
hold on
grid on
plot(P_in, P_in'.*lut(P_in,3), 'g')
plot(P_in, P_in'.*lut(P_in,4), 'r')
subplot(212)
plot(P_in, lut(:,2:end))
grid on

end

% %% polynomial
% clf
% x_poly = [60 61 105 106];
% y_poly = [60 61 82 82];
% p_coeff = polyfit(x_poly, y_poly, 2);
% xx = linspace(0,130, 131);
% yy = polyval(p_coeff, xx);
% 
% plot(xx,yy, xx,xx,'r--',xx,82,'r--')
% grid on
% axis([0 130 0 85]);

% clf
% x_poly = [40 41 80 81];
% y_poly = [40 41 62 62];
% p_coeff = polyfit(x_poly, y_poly, 2);
% xx = linspace(0,130, 131);
% yy = polyval(p_coeff, xx);
% 
% plot(xx,yy, xx,xx,'r--',xx,82,'r--')
% grid on
% axis([0 130 0 85]);
% 
% 
% % %% tanh
% % clf
% a = 0.015;
% b = 82;
% x = linspace(0,130);
% y = b .* (1 - exp(-a.*2.*x)) ./ (1 + exp(-a.*2.*x));
% hold on
% plot(x,y,'g', x,x,'r--')
% % grid on
% % axis([0 130 0 85]);

% %%
% clf
% a = 0.015;
% b = 75;
% x = linspace(0,130);
% y = b .* (1 - exp(-a.*2.*x)) ./ (1 + exp(-a.*2.*x));
% hold on
% plot(x,y,'g', x,x,'r--',x,82,'r--')
% grid on
% % axis([0 130 0 85]);