% Zhe Chen, 2015-11-6
% select an image base (deformed?), select strain file, plot strain map, gb map
% and SEM map overlayed

display('This code has control points that might need modification accordingly !!! ');
[f1, p1] = uigetfile('*.tif','select SEM image');
[f2, p2] = uigetfile('','select strain file');
[f3, p3] = uigetfile('.csv','choose the EBSD grain file (csv format)');

%%
cpEBSD = [136,336;  243,338;  139,430;  245,435];
cpSEM = [341,359;  3742,431;  335,3712;  3754,3892];
tform = maketform('projective',cpEBSD,cpSEM);

EBSDdata = csvread([p3,'\',f3],1,0);
unique_x = unique(EBSDdata(:,4));
step_size = unique_x(2) - unique_x(1);
mResize = (max(EBSDdata(:,4)))/step_size + 1;
nResize = (max(EBSDdata(:,5)))/step_size + 1;
x_EBSD = reshape(EBSDdata(:,4),mResize,nResize)';
y_EBSD = reshape(EBSDdata(:,5),mResize,nResize)';
ID_EBSD = reshape(EBSDdata(:,9),mResize,nResize)';
[x_EBSD_fwd, y_EBSD_fwd] = tformfwd(tform,[x_EBSD(:),y_EBSD(:)]);
F = scatteredInterpolant(x_EBSD_fwd, y_EBSD_fwd, ID_EBSD(:), 'nearest');

img = imread([p1,'\',f1],'tif');
[x_SEM,y_SEM] = meshgrid(0:size(img,1)-1,0:size(img,2)-1);
x_low = min(unique(x_SEM(:)));
x_high = max(unique(x_SEM(:)));
y_low = min(unique(y_SEM(:)));
y_high = max(unique(y_SEM(:)));
if size(img,3)<3
    cmap = linspace(0,1,65536)'*[1 1 1];
    img = ind2rgb(img, cmap);
end

load([p2,'\',f2]);
ID_fwd = F(x,y);
[boundaryTF_fwd,~,~,~,~] = find_boundary_from_ID_matrix(ID_fwd);
% myFilter = fspecial('gaussian',5);
% boundaryTF_fwd = conv2(boundaryTF_fwd, myFilter, 'same');
boundaryTF_fwd(~boundaryTF_fwd)=nan;

u(sigma==-1)=nan;
v(sigma==-1)=nan;
exx(sigma==-1)=nan;
x_surf = x+u;
y_surf = y+v;
boundary_surf = ones(size(x_surf)).*boundaryTF_fwd*100;
%%
figure;hold on; 

image([x_low,x_high],[y_low,y_high],img,'AlphaData', .8);
surf(x_surf,y_surf,exx+1, exx, 'FaceAlpha', .6, 'LineStyle', 'none');
plot3(x_surf(:),y_surf(:),boundary_surf(:),'.','markersize',4,'color',[.9 .9 .9]);

axis square;
set(gca,'xlim',[x_low,x_high],'ylim',[y_low,y_high],'ydir','reverse','xTickLabel','','yTickLabel','','xTick','','yTick','');view([0,90]);
c_min = nanmean(exx(:)) - 2 * nanstd(exx(:));
c_max = nanmean(exx(:)) + 2 * nanstd(exx(:));
caxis([c_min,c_max]); colormap default; cbar = colorbar;
set(cbar,'fontsize',18,'visible','off');
title(cbar,'\epsilon_x_x','fontsize',18);

% print('outputimage','-dtiff','-r600');

