% input (1) neighborID: a matrix/array showing it's neighbor's ID
% (2) gID, (3) gDiameter: arrays indicating grain ID and it's corresponding grain diameter
function neighborDiameter = find_neighborDiameter(neighborID,gID,gDiameter)

[nRow,nColumn]=size(neighborID);
neighborDiameter = zeros(nRow,nColumn);

for iRow = 1:nRow
    for iColumn=1:nColumn
            index1 = find(neighborID(iRow,iColumn)==gID);
            if ~isempty(index1)
                index1 = index1(1);
                neighborDiameter(iRow, iColumn) = gDiameter(index1);
           end
    end
end

display('found neighborDiameter each point');
display(datestr(now));

end