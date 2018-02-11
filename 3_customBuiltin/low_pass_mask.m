% function [f,a,c] = myplot(varargin)
% format example: myplot(e1),myplot(e1,boundaryTF),myplot(x,y,e1),myplot(x,y,e1,boundaryTF)
%
% 2015-12-2 revised
%
% chenzhe, 2018-02-09, plot on specific axis.
% to be finished


function [s,a] = low_pass_mask(f0,a0,varargin)
k = nargin-2;
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


pos = get(a0,'Position');
set(0,'currentFigure',f0);
a = axes('Position',pos);

switch k
    case 1
        surf(a,double(M{1}),'edgecolor','none','facecolor','w','facealpha',0.9);

        m = M{1};

    case 3
        x = M{1};
        y = M{2};
        limit_x_low = min(x(:));
        limit_x_high = max(x(:));
        limit_y_low = min(y(:));
        limit_y_high = max(y(:));

        surf(a,x,y,double(M{3}),'edgecolor','none','facecolor','w','facealpha',0.9);

        m = M{3};

end
axis equal;

set(a,'Ydir','reverse','xLim',[limit_x_low,limit_x_high],'yLim',[limit_y_low,limit_y_high]);
view(0,90);
m2 = m(~isnan(m));
set(a,'visible','off');


try
    clim = quantile(m2,[0.00,0.995]);
    caxis(clim);
end

f=figure('Position',[800 600 400 100]);
s = uicontrol('Parent',f,...
    'Style','slider',...
    'Units','normalized',...
    'Position',[0.1 0.1 0.8 0.3],...
    'Min',clim(1),'Max',clim(2),'Value',clim(1),'SliderStep',[0.005 0.005]);


t1 = uicontrol('Parent',f,'Style','edit','Units','normalized','Position',[0.1, 0.5, 0.15, 0.2],'String',num2str(clim(1)));

t2 = uicontrol('Parent',f,'Style','edit','Units','normalized','Position',[0.7, 0.5, 0.15, 0.2],'String',num2str(clim(2)));
v = uicontrol('Parent',f,'Style','text','Units','normalized','Position',[0.4, 0.5, 0.15, 0.2],'String',num2str(s.Value));

s.Callback = {@callback_s,a,a0,t1,t2,v};
t1.Callback = {@callback_t1,s};
t2.Callback = {@callback_t2,s};

end


function callback_s(source,event,a,a0,t1,t2,v)
    set(a,'Position',a0.Position);
    set(source, 'Min',str2num(t1.String),'Max',str2num(t2.String),'SliderStep',[0.005 0.005]);
    value = source.Value;
    set(a,'zlim', [value,str2num(t2.String)+eps]);
    set(v,'String',num2str(source.Value));
end

function callback_t1(source,event,s)
    set(s,'Min',str2num(source.String));
end
function callback_t2(source,event,s)
    set(s,'Max',str2num(source.String));
end







