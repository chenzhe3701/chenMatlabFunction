%%
% choose image
[f,p] = uigetfile('*.*','choose image');
img = imread([p,'\',f]);
% choose type-2 grain file
[f,p] = uigetfile('*.csv','choose grain file');
inputText = csvread([p,'\',f],1,0);
gID = inputText(:,1);
gX = inputText(:,8);
gY = inputText(:,9);

%%
close all
resRatio = 2;
targetID = 534
ind = find(gID==targetID);
hold on; axis equal; set(gca,'ydir','reverse');
image(img);
text(gX(ind)*resRatio,gY(ind)*resRatio,num2str(targetID));