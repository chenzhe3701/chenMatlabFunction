% choose current folder into a folder with Vic2D output .mat file
% then for each .mat file, load and plot the exx,exy,eyy
%
% chenzhe, 2017-01-25

folder = pwd;
files = dir([folder,'\*.mat']);


for jj = 2:4
load([folder,'\',files(jj).name]);

% ii = 2*floor(jj/3)+mod(jj,3);
% if mod(jj,3)==0
%     kk = 'r';
% else
%     kk = [];
% end

ii = jj-1;

[f,a,c] = myplot(exx);
caxis([-0.015 0.015]);
set(get(c,'title'),'string','exx')
print([folder,'\fig_',num2str(ii),'_exx.tif'],'-dtiff')
close all;

[f,a,c] = myplot(exy);
caxis([-0.015 0.015]);
set(get(c,'title'),'string','exy')
print([folder,'\fig_',num2str(ii),'_exy.tif'],'-dtiff')
close all;

[f,a,c] = myplot(eyy);
caxis([-0.015 0.015]);
set(get(c,'title'),'string','eyy')
print([folder,'\fig_',num2str(ii),'_eyy.tif'],'-dtiff')
close all;
end