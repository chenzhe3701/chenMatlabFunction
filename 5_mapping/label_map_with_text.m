% hf = label_map_with_ID(X,Y,ID,hf,target_ID)
%
% X: matrix of x coordinates
% Y: matrix of y coordinates
% ID: matrix of ID 
% hf: handle of figure
% 'target_ID': target id number
% 'color': string for text color
% 'text': text string
%
% Combine two functions 'label_map_with_ID' and 'label_grain'
% if no 'target_ID' provided, label all grains.
% 
% chenzhe, 2018-09-03

function hf = label_map_with_text(X,Y,ID,hf,varargin)


p = inputParser;

addRequired(p,'X');
addRequired(p,'Y');
addRequired(p,'ID');
addRequired(p,'hf');
addParameter(p,'target_ID',[]);
addParameter(p,'color',[]);
addOptional(p,'text',[]);

parse(p,X,Y,ID,hf,varargin{:});

X = p.Results.X;
Y = p.Results.Y;
ID = p.Results.ID;
hf = p.Results.hf;
target_ID = p.Results.target_ID;
color = p.Results.color;
text_string = p.Results.text;

set(0,'currentfigure',hf);

hold on;

if isempty(target_ID)
    target_ID = unique(ID(:));
    target_ID = target_ID(target_ID~=0);
end
if isempty(color)
	color = 'k';
end

ID_reduced = ID(1:10:end,1:10:end);
X_reduced = X(1:10:end,1:10:end);
Y_reduced = Y(1:10:end,1:10:end);
z = gca;
z = z.ZLim(2);
for ii = 1:length(target_ID)
    id = target_ID(ii);
    ind = (ID_reduced==id);
    x = mean(X_reduced(ind));
    y = mean(Y_reduced(ind));
    text(x,y,z,{[num2str(id) ':']; text_string},'color',color,'fontsize',18);
end

hold off;

end