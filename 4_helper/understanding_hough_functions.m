% Chenzhe 2016-1-22
% It looks like:
%
% houghpeaks find the maximum in the H matrix 
% Peaks = houghpeaks(H, # of peaks, threshold), H is mat from hough transform
%
% lines = houghlines(BW_binary_mat,Theta,Rho,Peaks, ...) 
% houghlines: Theta, Rho, Peaks together can define a line, so houghlines
% tries to find the intersection of this reconstructed line and the
% 'existing' line, i.e., high intensity region on the BW map -> so that is
% the line houghlines() found.

close all;
I = imread('cc.tif');
I = I(:,:,1:3);
I = rgb2gray(I);

% this is I, effectively
I = ones(100)*255;
I(:,4) = 30;
I = uint8(I);

% show original figure
figure;imshow(I);

% create binary image
BW = edge(I,'canny');
figure;imshow(BW);

% create Hough tansform using the binary image
[H,T,R] = hough(BW);
figure;
imshow(imadjust(mat2gray(H)),'XData',T,'YData',R,...
    'InitialMagnification','fit');
title('Hough Transform of the Image');
xlabel('\theta');ylabel('\rho');
axis on; axis normal; hold on;

% Find peaks in the Hough transform of the image.
P = houghpeaks(H,2,'threshold',ceil(0.5*max(H(:))));    % index
x = T(P(:,2)); y = R(P(:,1));
plot(x,y,'s','color','g');

% Find lines (, and plot them)
P2 = P;
P2 = [143,91;    146,92];   % this is used to study houghlines
lines = houghlines(BW,T,R,P2,'FillGap',20,'MinLength',4);

% % the following 'hacks' the houghlines() function:
% % find the intersection of H's lines and (T,R,P)-defined lines
% lines = houghlines(ones(100)*255*0.1,T,R,P2,'FillGap',20,'MinLength',4);

figure,imshow(I),hold on;
for kk = 1:length(lines)
   xy = [lines(kk).point1; lines(kk).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
   
   % plot beginning of lines
%    plot(xy(1,1),xy(1,2),'o','LineWidth',2,'color','yellow');
end
