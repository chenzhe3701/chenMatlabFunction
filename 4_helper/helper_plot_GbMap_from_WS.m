xtemp=x{1}(1:1:end);
ytemp=y{1}(1:1:end);
boundaryTFtemp=boundaryTF{1}(1:1:end);
xtemp=xtemp(boundaryTFtemp~=0);
ytemp=ytemp(boundaryTFtemp~=0);
boundaryTFtemp = boundaryTFtemp(boundaryTFtemp~=0);
scatter3(xtemp,ytemp,1000*boundaryTFtemp,1,'k');
hold;
% scatter3([146;147;449;446],[173;488;184;497],[1000;1000;1000;1000],20,'b');
set (gcf,'Position',[0,0,600,600])
axis square;
grid off;axis off;box on;
set(gca,'ydir','reverse');
set(gca,'position',[0 0 1 1])
view(0,90);
clear('xtemp','ytemp','boundaryTFtemp');