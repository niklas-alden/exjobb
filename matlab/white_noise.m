%%
% clear all;
% clf;
% in_file = 'Speech_all';
% in = audioread([in_file '.wav']);
% 
% for snr = [50, 40, 35, 30, 25, 20]
%     noise = awgn(in, snr);
%     
%     if 1 == 0
%         audiowrite([in_file '_snr=' num2str(snr) '.wav'], noise, 16e3);
%     end
%    
% end

%%
clear all;
a = ones(1,5e5).*0.1;
a(1e5:2e5) = 1;
a(3e5:4e5) = 1;
an = wgn(1,length(a),0); % FEL
an = an./max(abs(an));
ax = a .* an;
plot(ax)

sound(ax, 48e3)
audiowrite('white_noise_steps.wav', ax, 48e3);