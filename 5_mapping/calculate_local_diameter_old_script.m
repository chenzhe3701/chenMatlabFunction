topInteractionRadius = 30; % micron
topInteractionRadiusIndex = topInteractionRadius/ebsdStepSize;

clear 'interactionRadius';
clear 'interactionRadiusIndex';
interactionRadius(1) = topInteractionRadius;
interactionRadiusIndex(1) = round(topInteractionRadius/ebsdStepSize);
% so, Undeformed layer will always have a depth of such as 1.  Deeper layer
% considered being effective from position of the previous layer.
for iLayer = 2:nEBSDfiles
    if isreal(sqrt(topInteractionRadius^2-(sum(layerDepth(1:(iLayer-1))))^2))
        interactionRadius(iLayer) = sqrt(topInteractionRadius^2-(sum(layerDepth(1:(iLayer-1))))^2);
        interactionRadiusIndex(iLayer) = round(interactionRadius(iLayer)/ebsdStepSize);
    end
end

[nRow, nColumn] = size(x{1});
misoLocalByVol = zeros(nRow,nColumn)*nan;   % initialize
nbDiaLocalByVol = zeros(nRow,nColumn)*nan;
misoLocalByGb = zeros(nRow,nColumn)*nan;
nbDiaLocalByGb = zeros(nRow,nColumn)*nan;

for iRow = (1+interactionRadiusIndex(1)):(nRow-interactionRadiusIndex(1))
    for iColumn = (1+interactionRadiusIndex(1)):(nColumn-interactionRadiusIndex(1))   % skip points near boarder
        pStructure = structure3D(ID{1}(iRow,iColumn)==gID3D); % copy the 3D structure to this point, then modify
        % to check if converge, disable the following four lines.
        pStructure.neighbor = [pStructure.neighbor, ID{1}(iRow,iColumn)];
        pStructure.neighborDiameter = [pStructure.neighborDiameter, 0 * gDiameter3D(ID{1}(iRow,iColumn)==gID3D)];   % set the diameter of itself=0, the other part of multiplication is the real diameter (used before, but decided to change)
        pStructure.neighborVolume = [pStructure.neighborVolume, 0 * gVolume3D(ID{1}(iRow,iColumn)==gID3D)];   % set the volume of itself=0, the other part of multiplication is the real volume (used before, but decided to change)
        pStructure.misorientation = [pStructure.misorientation,0];  % misorientation between it and itself is 0
        pStructure.nbVolCount = zeros(1,length(pStructure.neighbor));   % initialize, to hold each neighbor's Vol
        pStructure.nbGbCount = zeros(1,length(pStructure.neighbor));    % initialize, to hold each neighbor's Gb length
        for iLayer = 1:length(interactionRadiusIndex)   % for each layer
            rowIndex = (iRow - interactionRadiusIndex(iLayer)):(iRow+interactionRadiusIndex(iLayer));    % for this local region
            columnIndex = (iColumn - interactionRadiusIndex(iLayer)):(iColumn + interactionRadiusIndex(iLayer));
            % if within interactin volume.  For localRegion with ~distOK, set everything to 0
            distOK = ((x{iLayer}(rowIndex,columnIndex)-x{1}(iRow,iColumn)).^2 + (y{iLayer}(rowIndex,columnIndex)-y{1}(iRow,iColumn)).^2).^(1/2) < interactionRadius(iLayer);
            localID = ID{iLayer}(rowIndex, columnIndex);
            localID(~distOK) = 0;
            localBoundaryID = boundaryID{iLayer}(rowIndex, columnIndex);
            localBoundaryID(~distOK) = 0;
            localNeighborID = neighborID{iLayer}(rowIndex, columnIndex);
            localNeighborID(~distOK) = 0;
            for iNeighbor=1:length(pStructure.neighbor)
                tempNbID = pStructure.neighbor(iNeighbor);
                volIDAgree = (localID==tempNbID);
                pStructure.nbVolCount(tempNbID == pStructure.neighbor) =  pStructure.nbVolCount(tempNbID == pStructure.neighbor) + sum(volIDAgree(:))*layerDepth(iLayer);
                gbIDAgree = ((localNeighborID==ID{1}(iRow,iColumn))&(localBoundaryID==tempNbID));   % find g.b. in neighbor grain
                pStructure.nbGbCount(tempNbID == pStructure.neighbor) = pStructure.nbGbCount(tempNbID == pStructure.neighbor) + sum(gbIDAgree(:))*layerDepth(iLayer);
            end
            
        end
        nbDiaLocalByVol(iRow,iColumn) = dot(pStructure.neighborDiameter,pStructure.nbVolCount)/sum(pStructure.nbVolCount);
        misoLocalByVol(iRow,iColumn) = dot(pStructure.misorientation,pStructure.nbVolCount)/sum(pStructure.nbVolCount);
        nbDiaLocalByGb(iRow,iColumn) = dot(pStructure.neighborDiameter,pStructure.nbGbCount)/sum(pStructure.nbGbCount);
        misoLocalByGb(iRow,iColumn) = dot(pStructure.misorientation,pStructure.nbGbCount)/sum(pStructure.nbGbCount);
    end
    disp(iRow);
    disp(datestr(now));
end