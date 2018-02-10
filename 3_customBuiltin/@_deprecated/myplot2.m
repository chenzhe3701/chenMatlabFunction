% function [f,a,c] = myplot(varargin)
% format example: myplot(e1),myplot(e1,boundaryTF),myplot(x,y,e1),myplot(x,y,e1,boundaryTF)
%
% 2015-12-2 revised

function [f,a,c] = myplot2(M,varargin)

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

ratio = ceil(length(M)/3000);    % reduce ratio if necessary
if ratio > 1
    display(['matrix is big, use reduced ratio = ',num2str(ratio)]);
    M = M(1:ratio:end,1:ratio:end);
    TF = TF(1:ratio:end,1:ratio:end);
    X = X(1:ratio:end,1:ratio:end);
    Y = Y(1:ratio:end,1:ratio:end);
end


limit_x_low = min(X(:));
limit_x_high = max(X(:));
limit_y_low = min(Y(:));
limit_y_high = max(Y(:));
if f==-1
    f=figure;
end
hold on;
set(f,'position',[50,50,800,600]);
surf(X,Y,M,'edgecolor','none','facealpha',facealpha);
c=colorbar;
caxis(caxis);
% hold;
TF(TF==0)=NaN;
TF = TF * max(max(M(:),10000));
surf(X,Y,double(TF));

axis equal;
a=gca;
set(a,'Ydir','reverse','xLim',[limit_x_low,limit_x_high],'yLim',[limit_y_low,limit_y_high]);
view(0,90);

end
