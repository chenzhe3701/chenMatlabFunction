fs = 10000; % sampling frequency
recordTime = 4; % in seconds
nBits = 8;
nChans = 1;
r = audiorecorder(fs, nBits, nChans);

for ii=1:100
    close all;
disp('Start speaking.');
recordblocking(r, recordTime);     % recording ...
disp('End recording.');
p = play(r);   % listen

speech = getaudiodata(r, 'double'); % get data as single array
figure; plot(1/fs:1/fs:recordTime, speech); xlabel('Time,s')

Ns = fs * recordTime;
dN = fs/Ns;
speechFFT = abs(fft(speech, Ns));
figure; plot(dN:dN:fs, speechFFT); xlabel('Frequency,Hz');

% find peak: simply the maximum
[~,ind] = max(speechFFT(1:Ns/2));
maxFreq = dN * (ind-1)
trapz(speech)
end