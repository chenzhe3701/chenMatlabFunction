% overlayDirection = 1     EBSD to SEM
semSizeX=2048;
semSizeY=2048;
xtemp=X(1:3:end);
ytemp=Y(1:3:end);
boundaryTFtemp=boundaryTF(1:3:end);
xtemp=xtemp(boundaryTFtemp~=0);
ytemp=ytemp(boundaryTFtemp~=0);
boundaryTFtemp = boundaryTFtemp(boundaryTFtemp~=0);
scatter3(xtemp,ytemp,1000*boundaryTFtemp,1,'k');
hold;
surf(X,Y,ep1,'edgecolor','none');
colorbar;
xlim([1,semSizeX]);
ylim([1,semSizeY]);
caxis([0,0.3]);
axis square;
set(gca,'ydir','reverse');
view(0,90);
clear('xtemp','ytemp','boundaryTFtemp','semSizeX','semSizeY');
