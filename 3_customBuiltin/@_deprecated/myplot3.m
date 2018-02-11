% function [f,a,c] = myplot(varargin)
% format example: myplot(e1),myplot(e1,boundaryTF),myplot(x,y,e1),myplot(x,y,e1,boundaryTF)
%
% 2015-12-2 revised
%
% chenzhe, 2017-12-6
% based on myplot2().  use imagesc() to plot.

function [f,a,c] = myplot3(M,varargin)

if iscell(M)  % if have multiple layers
    answer = inputdlg(['Data M ',num2str(ii),' has multiple layers. Which layer to plot?'],'Choose Layer',1,{'1'});
    layer = str2num(answer{1});
    M = varargin{ii}{layer};
end

p = inputParser;

addRequired(p,'M');
addOptional(p,'TF',zeros(size(M))*NaN);
addParameter(p,'X',repmat(1:size(M,2),size(M,1),1));
addParameter(p,'Y',repmat([1:size(M,1)]',1,size(M,2)));
addParameter(p,'alpha',1,@isnumeric);
addParameter(p,'handle',-1,@ishandle);
parse(p,M,varargin{:});

M = p.Results.M;
TF = p.Results.TF;
X = p.Results.X;
Y = p.Results.Y;
f = p.Results.handle;
facealpha = p.Results.alpha;

limit_x_low = min(X(:));
limit_x_high = max(X(:));
limit_y_low = min(Y(:));
limit_y_high = max(Y(:));
if f==-1
    f=figure;
end
hold on;
set(f,'position',[50,50,800,600]);

imagesc([X(1),X(end)],[Y(1),Y(end)],M,'alphadata',facealpha);
% surf(X,Y,M,'edgecolor','none','facealpha',facealpha);   % in myplot2
clim = quantile(M(:),[0.005, 0.995]);
caxis(gca, [clim(1), clim(2)]);
c = colorbar;
axis equal;
set(gca,'xLim',[limit_x_low,limit_x_high],'yLim',[limit_y_low,limit_y_high]);

% hold;
TF(TF==0)=NaN;
TF = TF * max(max(M(:),10000));
surf(X,Y,double(TF));

a = gca;
end
