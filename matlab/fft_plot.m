function [ ] = fft_plot( x1,x2 )
%FFT_PLOT Plot FFT of two signals

% Sampling frequency
% Fs = 16000; % Nedos test files    
Fs = 8192; % Handel 
L = length(x1);                     % Length of signal


NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y1 = fft(x1,NFFT)/L;
Y2 = fft(x2,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);

% Plot single-sided amplitude spectrum.
clf
plot(f,2*abs(Y1(1:NFFT/2+1)), f,2*abs(Y2(1:NFFT/2+1)), 'r--') 
title('Single-Sided Amplitude Spectrum of y(t)')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')

end

