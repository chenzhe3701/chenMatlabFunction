% 2015-1-7  
% This code is used to understand figure/axis properties
close all; clc;
a = rand(3,4);  b=rand(3,6);    c=rand(5,6);

f = figure('position',[100,100,400,400])
get(f,'position')

ax1 = axes('position',[.2, .2, .4, .4],'xlim',[0 1],'ylim',[0,1])


set(ax1,'units','pixels');
get(ax1,'position')

set(ax1,'units','normalized','position',[.1, .2, .4, .4]);
set(ax1,'units','pixels');
get(ax1,'position')

ax2 = axes('position',[0.5, 0.2, 0.4, 0.4],'xlim',[1 10])

surf(ax1,a);set(ax1,'xlim',[0 5]); view(ax1, [0,90]);

h = imline;     % even if you can have 2 axis on same figure, line can only be drawn 
pos = wait(h)   % double click to confirm
pos+ones(size(pos))
