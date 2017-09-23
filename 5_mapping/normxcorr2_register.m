% chenzhe, 2017-08-01
% similar to fft_register.  crop = [rstart, rend, cstart, cend], negative means crop from right/down.

function [r_shift, c_shift, img2_out_shifted] = normxcorr2_register(img1, img2, crop1, crop2)
img2_in = img2;
r1a = 0;r1b=0;c1a=0;c1b=0;r2a=0;r2b=0;c2a=0;c2b=0;
% initial crop data
if exist('crop1','var')
    r1a = mod(crop1(1),size(img1,1));
    r1b = mod(crop1(2),size(img1,1));
    c1a = mod(crop1(3),size(img1,2));
    c1b = mod(crop1(4),size(img1,2));
    img1 = img1(1+r1a:1+r1b,1+c1a:1+c1b);
end
if exist('crop2','var')
    r2a = mod(crop2(1),size(img2,1));
    r2b = mod(crop2(2),size(img2,1));
    c2a = mod(crop2(3),size(img2,2));
    c2b = mod(crop2(4),size(img2,2));
    img2 = img2(1+r2a:1+r2b,1+c2a:1+c2b);
end

% img1 = mat2gray(img1);
% img2 = imhistmatch(mat2gray(img2),img1);
% myplot(img1);myplot(img2);

% make img2 >= img1.  If img_2 is smaller, pad.
[nR,nC] = size(img1);
img = zeros(max(size(img1,1),size(img2,1)), max(size(img1,2),size(img2,2)));
img(1:size(img2,1),1:size(img2,2)) = img2;
img2 = img;
% myplot(img1);myplot(img2);

% normxcorr2
CCabs = normxcorr2(img1,img2);
% figure;surf(CCabs,'edgecolor','none'),set(gca,'ydir','reverse');
[r_shift, c_shift] = find(CCabs == max(CCabs(:)))
% img1 wrt img2
r_shift = r_shift - nR;
c_shift = c_shift - nC;
% img2 wrt img1
r_shift = -r_shift;
c_shift = -c_shift;
% consider initial cut
r_shift = r_shift + r1a - r2a;
c_shift = c_shift + c1a - c2a;

img2_out_shifted = circshift(img2_in,[r_shift,c_shift]);
end