layer=inputdlg('Which layer to plot?','Choose layer',1,{'1'});
layer = str2double(layer{1});
figure;
set(gcf,'position',[20,20,1040,780]);
image(IPF{layer});
axis equal;
text(gCenterX{layer},gCenterY{layer},num2str(gID{layer}),'fontweight','bold','fontsize',11)
