% function [f,a,c] = myplot(varargin)
% format example: myplot(e1),myplot(e1,boundaryTF),myplot(x,y,e1),myplot(x,y,e1,boundaryTF)
%
% 2015-12-2 revised
%
% chenzhe, 2018-02-08, based on myplot(). Add a slider to adjust upper
% limit. 2 limits, but not good.


function [f,a,c,H] = myplotc2(varargin)
k = nargin;
for ii=1:k
    if iscell(varargin{ii})  % if have multiple layers
        answer = inputdlg(['Data # ',num2str(ii),' has multiple layers. Which layer to plot?'],'Choose Layer',1,{'1'});
        layer = str2num(answer{1});
        M{ii} = varargin{ii}{layer};
    else
        M{ii} = varargin{ii};
    end
end

ratio = ceil(length(M{1})/3000);    % reduce ratio if necessary
if ratio > 1
    display(['matrix is big, use reduced ratio = ',num2str(ratio)]);
    for ii=1:length(M)
        M{ii} = M{ii}(1:ratio:end,1:ratio:end);
    end
end
if ~isempty(M{1}(isinf(M{1})))
    M{1}(isinf(M{1})) = nan;
end
limit_y_low = 1;
limit_x_low = 1;
[limit_y_high, limit_x_high] = size(M{1});

f=figure;
switch k
    case 1
        [x,y] = meshgrid(1:size(M{1},2),1:size(M{1},1));
        set(f,'position',[50,50,800,600]);
        surf(x,y,double(M{1}),'edgecolor','none');
        c=colorbar;
        caxis(caxis);
        title(strrep(inputname(1),'_','\_'));
        m = M{1};
    case 2
        [x,y] = meshgrid(1:size(M{1},2),1:size(M{1},1));
        set(f,'position',[50,50,800,600]);
        if size(M{1},3)==3
            p = M{1};
            p = p(:,:,1);
            surf(x,y,p,double(M{1}),'edgecolor','none');
        else
            surf(x,y,double(M{1}),'edgecolor','none');
            c=colorbar;
            caxis(caxis);
        end
        hold;
        boundaryTF = M{2};
        boundaryTF(boundaryTF==0)=NaN;
%         boundaryTF = boundaryTF * max(max(M{1}(:),10000));
        surf(x,y,double(boundaryTF)* max([M{1}(:);10000]));
        title(strrep(inputname(1),'_','\_'));
        m = M{1};
    case 3
        x = M{1};
        y = M{2};
        limit_x_low = min(x(:));
        limit_x_high = max(x(:));
        limit_y_low = min(y(:));
        limit_y_high = max(y(:));
        set(f,'position',[50,50,800,600]);
        surf(x,y,double(M{3}),'edgecolor','none');
        c=colorbar;
        caxis(caxis);
        title(strrep(inputname(3),'_','\_'));
        m = M{3};
    case 4
        x = M{1};
        y = M{2};
        limit_x_low = min(x(:));
        limit_x_high = max(x(:));
        limit_y_low = min(y(:));
        limit_y_high = max(y(:));
        set(f,'position',[50,50,800,600]);
        surf(x,y,double(M{3}),'edgecolor','none');
        c=colorbar;
        caxis(caxis);
        hold;
        boundaryTF = M{4};
        boundaryTF(boundaryTF==0)=NaN;
%         boundaryTF = boundaryTF * max(max(M{3}(:),10000));
        surf(x,y,double(boundaryTF)* max([M{3}(:);10000]));
        title(strrep(inputname(3),'_','\_'));
        m = M{3};
end
axis equal;
a=gca;
set(a,'Ydir','reverse','xLim',[limit_x_low,limit_x_high],'yLim',[limit_y_low,limit_y_high]);
view(0,90);
m2 = m(~isnan(m));
try
    clim = quantile(m2,[0.005,0.995]);
    caxis(clim);
end

H = uicontrol('Parent',f,...
    'Style','slider',...
    'Units','normalized',...
    'Position',[c.Position(1) + 4*c.Position(3), c.Position(2), c.Position(3), c.Position(4)],...
    'Min',c.Limits(1),'Max',c.Limits(2),'Value',c.Limits(2),'SliderStep',[norm(c.Limits)/200,norm(c.Limits)/200]);
L = uicontrol('Parent',f,...
    'Style','slider',...
    'Units','normalized',...
    'Position',[c.Position(1) + 2*c.Position(3), c.Position(2), c.Position(3), c.Position(4)],...
    'Min',c.Limits(1),'Max',c.Limits(2),'Value',c.Limits(1),'SliderStep',[norm(c.Limits)/200,norm(c.Limits)/200]);

if(exist('boundaryTF','var'))
    H.Callback = {@Hcallback,f,a,c,L,x,y,boundaryTF};
    L.Callback = {@Lcallback,f,a,c,H,x,y,boundaryTF};
else
    H.Callback = {@Hcallback,f,a,c,L};
    L.Callback = {@Lcallback,f,a,c,H};
end



end

function Hcallback(source,event,f,a,c,L,x,y,boundaryTF)
    % get value of the slider
    set(source,'Min',c.Limits(1),'Max',c.Limits(2),...
        'Position',[c.Position(1) + 4*c.Position(3), c.Position(2), c.Position(3), c.Position(4)]);
    value = source.Value;
    limL = L.Value;
    if limL>=value
       set(L,'Value',value-norm(c.Limits)/200); 
       limL = L.Value;
    end
    set(a,'zlim', [limL,value]);
    if(exist('boundaryTF','var'))
        surf(x,y,a.ZLim(2)*double(boundaryTF));
    end
end

function Lcallback(source,event,f,a,c,H,x,y,boundaryTF)
    % get value of the slider
    set(source,'Min',c.Limits(1),'Max',c.Limits(2),...
        'Position',[c.Position(1) + 2*c.Position(3), c.Position(2), c.Position(3), c.Position(4)]);
    value = source.Value;
    limH = H.Value ;
    if limH<=value
       set(H,'Value',value+norm(c.Limits)/200); 
       limH = t.Value;
    end
    set(a,'zlim', [value,limH]);
    if(exist('boundaryTF','var'))
        surf(x,y,a.ZLim(2)*double(boundaryTF));
    end
end







