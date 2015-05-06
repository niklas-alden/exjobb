% %%
function [gain] = agc_lut(~)
    n = 100;
    P_in = 1:n;

    lut = ones(n,4);

    % ideal, index 1
    max = 82;
    for i = 1:n
        if i > max
            lut(i,1) = 10^(max/10) / 10^(i/10);
        end
    end 

        
    % dB polynomial 1, index 2
    for i = 1:n
        if i > max
            lut(i,2) = 10^(max/10) / 10^(i/10);
        end
    end
    x_poly = [62 74 77 85];
    y_poly = [62 60 75 42];
    p_coeff = polyfit(x_poly, y_poly, 2);
    yy = polyval(p_coeff, P_in);
    lut(71:84, 2) = yy(71:84) ./ P_in(71:84);
    
    
    % dB polynomial 2, index 3
    for i = 1:n
        if i > max
            lut(i,3) = 10^(max/10) / 10^(i/10);
        end
    end
    x_poly = [40 55 70 90];
    y_poly = [35 55 60 20];
    p_coeff = polyfit(x_poly, y_poly, 2);
    yy = polyval(p_coeff, P_in);
    lut(61:86, 3) = yy(61:86) ./ P_in(61:86);
    
    % dB polynomial 3, index 4
    for i = 1:n
        if i > max
            lut(i,4) = 10^(max/10) / 10^(i/10);
        end
    end
    x_poly = [38 56 75 90];
    y_poly = [40 46 42 15];
    p_coeff = polyfit(x_poly, y_poly, 2);
    yy = polyval(p_coeff, P_in);
    lut(46:89, 4) = yy(46:89) ./ P_in(46:89);
    
    % return prefered lookup table
    % 2 = ideal
    % 3 = polynomial 1
    % 4 = polynomial 2
    % 5 = polynomial 3
    gain = lut(:,4);

% PLOT
if 1 == 1
    clf;
    figure(2)
    subplot(211)
    plot(P_in, 10.*log10((10.^(P_in./10))'.*(lut(P_in,1))), 'b')
    hold on
    plot(P_in, 10.*log10((10.^(P_in./10))'.*(lut(P_in,2))), 'r')
    plot(P_in, 10.*log10((10.^(P_in./10))'.*(lut(P_in,3))), 'g')
    plot(P_in, 10.*log10((10.^(P_in./10))'.*(lut(P_in,4))), 'm')
    xlabel('P_{in} / dB')
    ylabel('P_{out} / dB')
    grid on
    legend('ideal (1)','poly1 (2)','poly2 (3)','poly3 (4)','Location','northwest')    
    subplot(212)
    plot(P_in, lut(:,:))
    grid on
    legend('ideal (1)','poly1 (2)','poly2 (3)','poly3 (4)','Location','northwest')
    xlabel('P_{in} / dB')
    ylabel('gain')
end

% EXPORT TO FILE
if 1 == 0
    export_curve = 2;
    fileID = fopen('matlab_gain_lut.txt','wt');
    fprintf(fileID, '%1.15f\n', lut(:,export_curve));
    fclose(fileID);
end