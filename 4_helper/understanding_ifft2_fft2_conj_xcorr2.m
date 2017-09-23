% understanding the method to use fft to calculate xcorr

clear;close all;
% f = im2double(imread('cameraman.tif'));
% deltar = 2;
% deltac = 3;
% [nr,nc]=size(f);
% Nr = ifftshift((-fix(nr/2):ceil(nr/2)-1));
% Nc = ifftshift((-fix(nc/2):ceil(nc/2)-1));
% [Nc,Nr] = meshgrid(Nc,Nr);
% g = ifft2(fft2(f).*exp(1i*2*pi*(deltar*Nr/nr+deltac*Nc/nc)));

a = rand(4);
a2 = [a,a;a a];
b = rand(4);

c = xcorr2(a2,b)
d1 = ifft2(fft2(a).*conj(fft2(b)));     % fft method to calculate xcorr2 !!!
d1 = abs(d1)
c(4:7,4:7) - d1   % note that these part equal.
% So, the fft method to calculate xcorr2 assumes a 'period' image. i.e.,
% first we make a larger, then xcorr2, the result will be same as fft


% This is not how it works, but before I figured the above out, I thought
% it might be this way.  So this part is just a record.
% [nR,nC] = size(a);
% Rs = ifftshift(-fix(nR/2):ceil(nR/2)-1);
% Cs = ifftshift(-fix(nC/2):ceil(nC/2)-1);
% [Cs,Rs] = meshgrid(Cs,Rs);
% d2 = ifft2(fft2(a).*conj(fft2(b)).*exp(1i*2*pi*(Rs/nR+Cs/nC)));
% d2 = abs(d2)

% figure;surf(c,'edgecolor','none')
% figure;surf(d1,'edgecolor','none')
% figure;surf(d2,'edgecolor','none')

