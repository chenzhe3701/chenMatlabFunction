% find the grain number of cells
% find the grain centroid expressed as [ind_row, ind_column].
%
% chenzhe, 2017-03-28
function [gNumCell, centroidInd_RC, uniqueID] = find_numCell_centroidInd_from_ID(ID)
    uniqueID = unique(ID(:));
    % get rid of ID=0
    if uniqueID(1)==0
        uniqueID(1) = [];
    end
    [nR,nC] = size(ID);
    [C,R] = meshgrid(1:nC, 1:nR);
    
    for ii = 1:length(uniqueID)
       currentID = uniqueID(ii);
       currentRow = find(uniqueID == currentID);
       inds = (ID==currentID);
       indR_local = R(inds);
       indC_local = C(inds);
       centroidInd_RC(currentRow,:) = round([mean(indR_local(:)),mean(indC_local(:))]); % make as integer
       gNumCell(currentRow,:) = sum(inds(:));
    end
end