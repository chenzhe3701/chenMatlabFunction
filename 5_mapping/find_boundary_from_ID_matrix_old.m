function [boundaryTF, boundaryID, neighborID, tripleTF, tripleID] = find_boundary_from_ID_matrix_old(ID)
[nRow,nColumn]=size(ID);
boundaryTF = zeros(nRow,nColumn);      % if pixel is on grain boundary, then this value will be 1
boundaryID = zeros(nRow,nColumn);    % this indicate the grain ID of the grain which the grain boundary belongs to
neighborID = zeros(nRow,nColumn);      % for grain boundary points, this is the grain ID of the neighboring grain
tripleTF = zeros(nRow,nColumn);     % if pixel is on triple point, then this value will be 1
tripleID = zeros(nRow,nColumn);     % this indicate the grain ID of the grain which the triple point belongs to

for iRow = 1:nRow
    for iColumn = 1:nColumn
        IDLocal = ID(max(iRow-1,1):min(iRow+1,nRow),max(iColumn-1,1):min(iColumn+1,nColumn));
        uniqueValue = unique(IDLocal);
        if sum(isnan(uniqueValue))
            uniqueValue = [uniqueValue(~isnan(uniqueValue));nan];
        else
            uniqueValue = uniqueValue(~isnan(uniqueValue));
        end
        if length(uniqueValue)>1
            boundaryTF(iRow,iColumn) = 1;
            boundaryID(iRow,iColumn) = ID(iRow,iColumn);
            index = find(IDLocal ~= ID(iRow,iColumn));
            index = index(1);
            neighborID(iRow,iColumn) = IDLocal(index);
        end
        if length(uniqueValue)>2
            tripleTF(iRow,iColumn) = 1;
            tripleID(iRow,iColumn) = ID(iRow,iColumn);
        end
        
        
    end
end
display('found boundaryTF and tripleTF');
display(datestr(now));
end