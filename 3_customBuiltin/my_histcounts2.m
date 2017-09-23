% ChenZhe 2016-2-1 
% N = my_histcounts2(x,y,Xedges,Yedges) x, y are the two attributes of a
% data point. Categorize all these data points into bins, based on the two
% attributes.
% Partitions X and Y into bins with the bin edges specified by Xedges and
% Yedges. N(i,j) counts the value [X(k),Y(k)] if Xedges(i) ¡Ü X(k) <
% Xedges(i+1) and Yedges(j) ¡Ü Y(k) < Yedges(j+1) 
% Use discretize and histcounts to mimic histcounts2, limited format

function N = my_histcounts2(x,y,Xedges,Yedges)

bins = discretize(y,Yedges);
for ii = 1:length(Yedges)-1
    N(ii,:) = histcounts(x(find(bins==ii)),Xedges);
end
    
