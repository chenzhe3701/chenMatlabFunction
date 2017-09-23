% code to show image shift.
% https://www.mathworks.com/matlabcentral/fileexchange/18401-efficient-subpixel-image-registration-by-cross-correlation
f = im2double(imread('cameraman.tif'));

deltar = -3.48574;
deltac = 8.73837;
phase = 2;
[nr,nc]=size(f);
Nr = ifftshift((-fix(nr/2):ceil(nr/2)-1));
Nc = ifftshift((-fix(nc/2):ceil(nc/2)-1));
% Nr = ((-fix(nr/2):ceil(nr/2)-1));
% Nc = ((-fix(nc/2):ceil(nc/2)-1));
[Nc,Nr] = meshgrid(Nc,Nr);
g = ifft2(fft2(f).*exp(1i*2*pi*(deltar*Nr/nr+deltac*Nc/nc))).*exp(-1i*phase)
figure(1);
subplot(1,2,1);
imshow(abs(f));
title('Reference image, f(x,y)')
subplot(1,2,2);
imshow(abs(g));
title('Shifted image, g(x,y)')

%% need dtfregistration()
usfac = 100;
[output, Greg] = dftregistration(fft2(f),fft2(g),usfac);
display(output),
figure(1);
subplot(1,2,1);
imshow(abs(f));
title('Reference image, f(x,y)')
subplot(1,2,2);
imshow(abs(ifft2(Greg)));
title('Registered image, gr(x,y)')
%%
N = 200;    % number of points
Fs = 100;   % sampling frequency
n = 0: N-1;
t = [0:N-1]./Fs;  % time


fw = 0.5;     % frequency of wave
Fs = 1/(t(2)-t(1));
f = 1 * sin(2*pi*fw.*t); % function, 

deltar = 30 ;   % sampling point shift
dt = deltar/Fs;       % time shift of wave 2
f2 = 1 * sin(2*pi*fw.*(t+dt) );

F = fft(f);
F2 = fft(f2);

g = ifft( fft(f).*exp(1i*2*pi/N*(deltar*n)) );
close all; figure;

subplot(1,3,1);
hold on;  plot(t,f); hold off;
title('Reference image, f(x)')

subplot(1,3,2);
hold on;  plot(t,f2); hold off;
title('Shifted image, f2(x)')

subplot(1,3,3);
hold on;  plot(t, g); hold off;
title('Shifted image, g(x)')

