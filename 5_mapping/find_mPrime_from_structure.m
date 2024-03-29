% input (1) ID, (2) neighborID: matrix or array showing it's ID and it's neighbor's ID
% (3) mPrimeStruct, generated by other function
function [mPm, mP3m] = find_mPrime_from_structure(ID, neighborID, mPrimeStruct)

[nRow,nColumn]=size(ID);
mP3m = zeros(nRow,nColumn);
mPm = zeros(nRow,nColumn);

for iRow = 1:nRow
    for iColumn=1:nColumn
            index1 = find(ID(iRow,iColumn)==mPrimeStruct.g1);
            if ~isempty(index1)
                index2 = find(neighborID(iRow,iColumn) == mPrimeStruct.g2{index1});
                if ~isempty(index2)
                    mP3m(iRow,iColumn) = mPrimeStruct.mP3m{index1}(index2);
                    mPm(iRow,iColumn) = mPrimeStruct.mPm{index1}(index2);
                end
           end
    end
end

display('found mPrime for each point');
display(datestr(now));

end