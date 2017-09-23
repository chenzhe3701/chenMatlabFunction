% [dToBoundary3D,dToTriple3D,neighborID3D] = find_d_to_boundary_3D(x,y,boundaryID,ID,dToBoundary,dToTriple,neighborID,layerDepth)
%
% For 3D info, find d_to_boundary/center/triple point
%
% Zhe Chen, 2015-11-3
% for each grain, find the distance to this grain's boundary on each layer, then compare

% Zhe Chen, 2015-08-11 revised
% Zhe Chen, 2015-08-24 2nd revision.  It was good idea to make the
% sub-layer as possible grain boundary, but this could lead to error in
% finding mPrime, etc, neighbor relationships because the sub-layer grain
% may not be in the neighborStructure.  So, I disabled this.

function [dToBoundary3D,dToTriple3D,neighborID3D] = find_d_to_boundary_3D(x,y,boundaryID,ID,dToBoundary,dToTriple,neighborID,layerDepth)

cumLayerDepth = cumsum(layerDepth);
dToBoundaryAtLayer = dToBoundary;
dToTripleAtLayer = dToTriple;
neighborIDAtLayer = neighborID;
nEBSDfiles = length(dToBoundary);
% from this point, XXX3D are info for pixels on the 1st layer

gID = unique(boundaryID{1}(:));
gID = gID(gID~=0);
for iLayer = 2:nEBSDfiles
    
    dToTripleAtLayer{iLayer} = sqrt(dToTripleAtLayer{iLayer}.^2+cumLayerDepth(iLayer).^2);
        
    for iGrain = 1:length(gID)
        % find index range of a small matrix containing the grain of interest
        indC_min = find(sum((ID{1}==gID(iGrain))+(ID{2}==gID(iGrain)), 1), 1, 'first');
        indC_max = find(sum((ID{1}==gID(iGrain))+(ID{2}==gID(iGrain)), 1), 1, 'last');
        indR_min = find(sum((ID{1}==gID(iGrain))+(ID{2}==gID(iGrain)), 2), 1, 'first');
        indR_max = find(sum((ID{1}==gID(iGrain))+(ID{2}==gID(iGrain)), 2), 1, 'last');
        
        nRow = indR_max - indR_min + 1;
        nColumn = indC_max - indC_min + 1;
        
        dToBoundaryPatch = ones(nRow,nColumn)*inf;
        IDPatch = ID{1}(indR_min:indR_max,indC_min:indC_max);
        boundaryTFPatch = double(logical(boundaryID{iLayer}(indR_min:indR_max,indC_min:indC_max)==gID(iGrain)));
        dToBoundaryPatch(boundaryTFPatch==1)=0;
        boundaryXPatch = x{1}(indR_min:indR_max,indC_min:indC_max).*boundaryTFPatch;
        boundaryYPatch = y{1}(indR_min:indR_max,indC_min:indC_max).*boundaryTFPatch;
        xPatch = x{1}(indR_min:indR_max,indC_min:indC_max);
        yPatch = y{1}(indR_min:indR_max,indC_min:indC_max);
        
        
        % neighborIDAtLayer{iLayer}(ID{iLayer}~=ID{1}) = ID{iLayer}(ID{iLayer}~=ID{1});   % 2015-8-24 note: This is to make the sub-layer as neighbor.  It is good idea, but may introduce trouble in finding mPrime, etc.
        
        f1 = [0 0 0; 1 0 0; 0 0 0];     % filters, each corresponds to one adjacent point
        f2 = [0 1 0; 0 0 0; 0 0 0];
        f3 = [0 0 0; 0 0 1; 0 0 0];
        f4 = [0 0 0; 0 0 0; 0 1 0];
        ff = [0 1 0; 1 0 1; 0 1 0];
        diff = 1;
        % distance to grain boundary
        iLoop = 1;
        while (iLoop<10)||(diff>10^(-2))
            boundaryXtoAdd = zeros(size(dToBoundaryPatch));      % temporarily store coord of closest gb point
            boundaryYtoAdd = zeros(size(dToBoundaryPatch));
            tempDtoBoundary = dToBoundaryPatch;
            
            sampleInd = randperm(4);    % randomly change sequence of the four filters in f
            f = zeros([size(f1),4]);
            f(:,:,sampleInd(1))=f1;f(:,:,sampleInd(2))=f2;f(:,:,sampleInd(3))=f3;f(:,:,sampleInd(4))=f4;
            
            for ii=1:4
                convX = conv2(boundaryXPatch,f(:,:,ii),'same');      % check neighbor's nearest g.b points
                convY = conv2(boundaryYPatch,f(:,:,ii),'same');
                xDiff = abs(xPatch-convX);
                yDiff = abs(yPatch-convY);
                manhDistB = xDiff + yDiff;
                eucDistB = sqrt(xDiff.^2 + yDiff.^2);
                
                % label all points, if new boundaryX,Y assigned, then dToBoundary decrease
                tB = (eucDistB<tempDtoBoundary)&(convX~=0)&(convY~=0);
                boundaryXtoAdd(tB) = convX(tB);
                boundaryYtoAdd(tB) = convY(tB);
                tempDtoBoundary(tB) = eucDistB(tB);
            end
            
            boundaryXPatch(logical(boundaryXtoAdd)) = boundaryXtoAdd(logical(boundaryXtoAdd));
            boundaryYPatch(logical(boundaryYtoAdd)) = boundaryYtoAdd(logical(boundaryYtoAdd));
            dToAdd = sqrt((xPatch-boundaryXtoAdd).^2 + (yPatch-boundaryYtoAdd).^2);
            old_d_to_boundary = dToBoundaryPatch;
            
            dToBoundaryPatch(logical(boundaryXtoAdd)) = dToAdd(logical(boundaryXtoAdd));
            
            diff = abs(old_d_to_boundary - dToBoundaryPatch);
            diff = nansum(diff(:));
            iLoop = iLoop+1;
        end
        dToBoundaryPatch = sqrt(dToBoundaryPatch.^2+cumLayerDepth(iLayer).^2);
        dToBoundaryAtLayer{iLayer}(ID{1}==gID(iGrain)) = dToBoundaryPatch(IDPatch==gID(iGrain));
    end
    
end


for iLayer = 1:nEBSDfiles
    dToBoundary3D(:,:,iLayer) = dToBoundaryAtLayer{iLayer};
    dToTriple3D(:,:,iLayer) = dToTripleAtLayer{iLayer};
    neighborID3D(:,:,iLayer) = neighborIDAtLayer{iLayer};
end
[dToBoundary3D,ind_dToBoundary3D_layer] = min(dToBoundary3D,[],3);
[dToTriple3D,ind_dToTriple3D_layer] = min(dToTriple3D,[],3);

% find linear_index for nearest neighbor in neighborID3D
[nRow,nColumn,nLayer] = size(neighborID3D);
[columnVec, rowVec] = meshgrid(1:nColumn,1:nRow);
ind_linear = sub2ind([nRow,nColumn,nLayer],rowVec(:),columnVec(:),ind_dToBoundary3D_layer(:));
neighborID3D = reshape(neighborID3D(ind_linear),nRow,nColumn);

% added 2015-9-28.  Interpolate dToBoundary from some known points at the g.b.

display('found d_to_boundary/triple in 3D');
display(datestr(now));
end
