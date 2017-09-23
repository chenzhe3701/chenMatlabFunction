% maxFreq = fft_data(A, fs)
% fs = sampling frequency of the data
% find the maximum frequency of the data
% chenzhe, 2017-07-20

function maxFreq = fft_data(A, fs)

% fs = sampling frequency
% recordTime = in seconds
recordTime = length(A)/fs;
N = fs * recordTime;   % number of points for FFT
dN = fs/N;     % delta frequency, i.e., freq interval.  Corresponding to real time frequency, not data frequency

A_fft = abs(fftshift(fft(A, N)));   % freq domain, DC in center

Ns = -fix(N/2):ceil(N/2)-1;     % an array for the dataFreq, DC in center
freqs = Ns*dN;                  % array for freqs, DC in center

figure; plot(freqs, A_fft); xlabel('freqs,Hz');

% find peak: simply the maximum
amp = max(A_fft);
ind = find(amp == A_fft,1,'last');
maxFreq = freqs(ind);

