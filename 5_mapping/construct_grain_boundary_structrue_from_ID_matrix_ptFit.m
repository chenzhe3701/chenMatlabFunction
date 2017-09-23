% chenzhe, 2016-3-11
% the grain boundary normal is calculated by finding and fitting all of the
% points on the grain boundary
%
function gbStruct = construct_grain_boundary_structrue_from_ID_matrix_ptFit(ID_,X,Y)

[~, boundaryID, neighborID,~,~] = find_boundary_from_ID_matrix(ID_);  % find g.b.

gbInd = (boundaryID~=0);
gbMat = [boundaryID(gbInd),neighborID(gbInd),X(gbInd),Y(gbInd)];
gbMat = sortrows(gbMat,[1,2]);
gbId_1 = gbMat(1,1);
gbId_2 = gbMat(1,2);
iRowStart = 1;
iRow = 1;
rowNum = 1;
while iRow<=length(gbMat)
    if (gbMat(iRow,1)~=gbId_1)||(gbMat(iRow,2)~=gbId_2)
        gbStruct.g1(rowNum) = gbId_1;
        gbStruct.g2(rowNum) = gbId_2;
        gbX = gbMat(iRowStart:(iRow-1),3);
        gbY = gbMat(iRowStart:(iRow-1),4);
        
        md = fitlm(gbX,gbY);
        k = md.Coefficients.Estimate(2);
        gbStruct.normal(rowNum,:) = [-k(1),1,0];
        gbStruct.length(rowNum) = length(gbX)
        
        if range(gbX)>range(gbY)
            [~,ind1] = min(gbX);
            [~,ind2] = max(gbX);
        else
            [~,ind1] = min(gbY);
            [~,ind2] = max(gbY);
        end        
        gbStruct.line(rowNum,:) = [gbX(ind1),gbY(ind1),gbX(ind2),gbY(ind2)];
        
        iRowStart = iRow;
        rowNum = rowNum + 1;
        gbId_1 = gbMat(iRow,1);
        gbId_2 = gbMat(iRow,2);
    end
    iRow = iRow+1;
end
gbStruct.g1 = gbStruct.g1';
gbStruct.g2 = gbStruct.g2';
gbStruct.length = gbStruct.length';