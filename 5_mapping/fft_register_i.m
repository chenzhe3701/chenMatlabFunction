% chenzhe, 2017-07-14
% single pixel resolution solution for image shift.
% wrt: position of img2 with respect to img1, e.g., 'ur'(up,right),'d'(down),'l'(left) etc
% crop = [crop_row_up, crop_row_down, crop_col_left, crop_col_right]
%
% use fft to find image shift
% Ref: Manuel Guizar-Sicairos, Samuel T. Thurman, and James R. Fienup
% and their codes
%
% chenzhe, 2017-08-11. search within [tolerance] pixels of [initialGuess]. 

function [r_shift, c_shift, img2_out_ffted] = fft_register_i(img1, img2,  wrt, crop1, crop2,  initialGuess, tolerance)
r1a = 0;r1b=0;c1a=0;c1b=0;r2a=0;r2b=0;c2a=0;c2b=0;

if exist('initialGuess','var')
    r_shift_i = initialGuess(1);
    c_shift_i = initialGuess(2);
end
% initial crop data
if exist('crop1','var')
    r1a = crop1(1);
    r1b = crop1(2);
    c1a = crop1(3);
    c1b = crop1(4);
    img1 = img1(1+r1a:end-r1b,1+c1a:end-c1b);
end
if exist('crop2','var')
    r2a = crop2(1);
    r2b = crop2(2);
    c2a = crop2(3);
    c2b = crop2(4);
    img2 = img2(1+r2a:end-r2b,1+c2a:end-c2b);
end
if ~exist('tolerance','var')
    tolerance = 5;
end

% if img1(100x50) is cut from left for 10 pixels, then xcorr(cuttedImg1, img1) should have peak at c=-10, i.e, 40 
r_shift_i = r_shift_i - r1a + r2a;
c_shift_i = c_shift_i - c1a + c2a;

% make them same size.  If img_2 is smaller, pad.  If larger, crop.
[nR,nC] = size(img1);
img = zeros(nR,nC);
img(1:min(size(img1,1),size(img2,1)),1:min(size(img1,2),size(img2,2))) = img2(1:min(size(img1,1),size(img2,1)),1:min(size(img1,2),size(img2,2)));
img2 = img;

% fft
t1 = fft2(img1);
t2 = fft2(img2);
CC = ifft2(t1.*conj(t2));
CCabs = abs(CC);
% keep xcorr result in valid range only
CCabs([1:(r_shift_i-tolerance),(r_shift_i + tolerance):end], :) = 0;
CCabs(:, [1:(c_shift_i-tolerance),(c_shift_i + tolerance):end]) = 0;

% figure;surf(CCabs,'edgecolor','none'),set(gca,'ydir','reverse');
[r_shift, c_shift] = find(CCabs == max(CCabs(:)),1,'first');

CCmax = CC(r_shift,c_shift)*nR*nC;

% find shift in pixel rather than index
Rs = ifftshift(-fix(nR/2):ceil(nR/2)-1);
Cs = ifftshift(-fix(nC/2):ceil(nC/2)-1);
% Rs = 0:nR-1;
% Cs = 0:nC-1;
r_shift = Rs(r_shift);
c_shift = Cs(c_shift);

% shifted image
[Cs,Rs] = meshgrid(Cs,Rs);
t2 = t2.*exp(1i*2*pi*(-r_shift*Rs/nR-c_shift*Cs/nC));
diffPhase = angle(CCmax);   % global phase diff
img2_out_ffted = abs(ifft2(t2*exp(1i*diffPhase)));

if ~exist('wrt','var')
    wrt = '';
end
if any((wrt(:)=='r')|(wrt(:)=='R'))
    if c_shift<0
        c_shift = mod(c_shift,nC);
    end
end
if any((wrt(:)=='l')|(wrt(:)=='l'))
    if c_shift>0
        c_shift = mod(c_shift,nC) - nC;
    end
end
if any((wrt(:)=='u')|(wrt(:)=='U'))
    if r_shift>0
        r_shift = mod(r_shift,nR) - nR;
    end
end
if any((wrt(:)=='d')|(wrt(:)=='D'))
    if r_shift<0
        r_shift = mod(r_shift,nR);
    end
end

r_shift = r_shift + r1a - r2a;
c_shift = c_shift + c1a - c2a;

end