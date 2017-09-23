% Test a method to identify slip trace position automatically
%
% Zhe Chen, 2016-1-23

close all;
strainFile ='H:\Ti7Al #B6 DIC_FOVs_merged_highRes\Ti7Al_#B6_new_stop_011';
load(strainFile,'exx');  
load('Ti7Al_#B6_EbsdToSemForTraceAnalysis')

%%
ID_current = 241;              % id of current grain
% ID_current = gIDwithTrace(iS);
ind_current = find(ID_current == gID3D);    % an index of row

ind_pool = ismember(ID{1}, ID_current);
indC_min = find(sum(ind_pool, 1), 1, 'first');
indC_max = find(sum(ind_pool, 1), 1, 'last');
indR_min = find(sum(ind_pool, 2), 1, 'first');
indR_max = find(sum(ind_pool, 2), 1, 'last');

nRow = indR_max - indR_min + 1;
nColumn = indC_max - indC_min + 1;

e_current = exx(indR_min:indR_max, indC_min:indC_max);  % strain of this region: grain + neighbor. Look at 'exx' strain, but can be changed later %%%%%%%%%%%%%%%
% boundaryTF_current = boundaryTF{1}(indR_min:indR_max, indC_min:indC_max);
% x_current = X(indR_min:indR_max, indC_min:indC_max);
% y_current = Y(indR_min:indR_max, indC_min:indC_max);
ID_map_current = ID{1}(indR_min:indR_max, indC_min:indC_max);
e_grain = e_current;
e_grain(ID_map_current~=ID_current) = nan;  % 'e_grain' is strain of This grain. 'e_current' is strian of this region.
I = e_grain;

%
close all
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
% If you want to find angles, block lengths in 'NHoodSize'
P = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))),'NHoodSize',[size(H,1),3]);    % index
x = T(P(:,2)); y = R(P(:,1));
plot(x,y,'s','color','white');

% Find lines (, and plot them)
lines = houghlines(BW,T,R,P,'FillGap',50,'MinLength',10);
figure,imshow(I),hold on;
for kk = 1:length(lines)
   xy = [lines(kk).point1; lines(kk).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
   
   % plot beginning of lines
%    plot(xy(1,1),xy(1,2),'o','LineWidth',2,'color','yellow');
end

ID_current = ID_current+1;



