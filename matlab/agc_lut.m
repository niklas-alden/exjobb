% %%
function [gain] = agc_lut(~)
    n = 100;
    P_in = 1:n;

    lut = ones(n,7);
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
    
    % tanh 1, index 3
    a = 0.015;
    b = 82;
    y_tanh = b .* (1 - exp(-a.*2.*P_in)) ./ (1 + exp(-a.*2.*P_in));
    lut(57:end, 3) = y_tanh(57:end) ./ P_in(57:end);
    
    % tanh 2, index 4
    a = 0.015;
    b = 65; 
    y_tanh = b .* (1 - exp(-a.*2.*P_in)) ./ (1 + exp(-a.*2.*P_in));
    lut(1:end, 4) = y_tanh(1:end) ./ P_in(1:end);
  
    % polynomial 1, index 5
    x_poly = [60 61 105 106];
    y_poly = [60 61 82 82];
    p_coeff = polyfit(x_poly, y_poly, 2);
    yy = polyval(p_coeff, P_in);
    lut(62:end, 5) = yy(62:end) ./ P_in(62:end);
    
    % dB ideal, index 6
    for i = 1:n
        if i > 82
            lut(i,6) = 10^8.2 / 10^(i/10);
        end
    end
    
    % polynomial 2, index 7
    x_poly = [38 56 75 80];
    y_poly = [40 46 42 40];
    p_coeff = polyfit(x_poly, y_poly, 3);
    yy = polyval(p_coeff, P_in);
    lut(43:end, 7) = yy(43:end) ./ P_in(43:end);
    
    % return prefered lookup table
    % 2 = ideal
    % 3 = tanh 1
    % 4 = tanh 2
    % 5 = polynomial 1
    % 6 = dB ideal
    % 7 = polynomial 2
    gain = lut(:,5);

% PLOT
if 1 == 1
    clf;
    figure(2)
    subplot(211)
    plot(P_in, P_in'.*lut(P_in,2), 'b')     % 2
    hold on
    grid on
    plot(P_in, P_in'.*lut(P_in,3), 'g')     % 3
    plot(P_in, P_in'.*lut(P_in,4), 'g--')   % 4
    plot(P_in, P_in'.*lut(P_in,5), 'r')     % 5
    plot(P_in, P_in'.*lut(P_in,6), 'r--')   % 6
    plot(P_in, P_in'.*lut(P_in,7), 'r.')    % 7
    legend('2','3','4','5','6','7','Location','northwest')
    xlabel('P_{in}')
    ylabel('P_{out}')
    subplot(212)
    plot(P_in, lut(:,2:5))
    legend('2','3','4','5','Location','southwest')
    xlabel('P_{in}')
    ylabel('gain')
    grid on
end

% EXPORT TO FILE
if 1 == 1
    export_curve = 6;
    fileID = fopen('matlab_gain_lut.txt','wt');
    fprintf(fileID, '%1.15f\n', lut(:,export_curve));
    fclose(fileID);
end

% %% polynomial
% % clf
% % x_poly = [60 61 105 106];
% % y_poly = [60 61 82 82];
% % p_coeff = polyfit(x_poly, y_poly, 2);
% % xx = linspace(0,130, 131);
% % yy = polyval(p_coeff, xx);
% % 
% % plot(xx,yy, xx,xx,'r--',xx,82,'r--')
% % grid on
% % axis([0 130 0 85]);
% 
% clf
% x_poly = [10^6.0 10^10.5 10^10.6];
% y_poly = [10^6.0 10^8.2 10^8.2];
% p_coeff = polyfit(x_poly, y_poly, 2);
% xx = linspace(0,10^13.0);
% yy = polyval(p_coeff, xx);
% 
% % plot(xx,yy, xx,xx,'r--',xx,82,'r--')
% plot(10.*log10(real(xx)), 10.*log10(real(yy)))
% grid on
% % axis([0 130 0 85]);

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