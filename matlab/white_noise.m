clear all;
%clf;
in_file = 'Speech_all';
in = audioread([in_file '.wav']);

for snr = [50, 40, 35, 30, 25, 20]
    noise = awgn(in, snr);
    
    if 1 == 1
        audiowrite([in_file '_snr=' num2str(snr) '.wav'], noise, 16e3);
    end
   
end