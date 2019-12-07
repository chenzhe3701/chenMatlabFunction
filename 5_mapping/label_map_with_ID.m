% hf = label_map_with_ID(X,Y,ID,hf,target_ID)
% X, Y, ID are matrice of the same size: coordinates and ID_map.
% hf is the handle_of_figure
%
% Combine two functions 'label_map_with_ID' and 'label_grain'
% if no 'target_ID' provided, label all grains.
% 
% chenzhe, 2018-09-03

function hf = label_map_with_ID(X,Y,ID,hf,target_ID,color_char,font_size)

set(0,'currentfigure',hf);

hold on;

if ~exist('target_ID','var')
    target_ID = unique(ID(:));
    target_ID = target_ID(target_ID~=0);
end
if ~exist('color_char','var')
	color_char = 'k';
end
if ~exist('font_size','var')
	font_size = 12;
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
    text(x,y,z,num2str(id),'color',color_char,'fontsize',font_size);
end

hold off;

end