structure3D = struct('ID',{},'nNeighbor',{},'neighbor',{},'misorientationArray',{{}},'misorientation',{},'gbLengthArray',{{}},'gbArea',{},'neighborDiameter',{},'neighborVolume',{},'gbAngleArray',{{}});
structure3D(length(gID3D)).ID = gID3D(length(gID3D));

for iGrain = 1:length(gID3D)    % for each grain, there is one structure recording neighbor-related information
    structure3D(iGrain).ID = gID3D(iGrain); % the field 'ID' record the ID of this grain
    for iLayer = 1:nEBSDfiles    % for each EBSD layer, need to find the current grain's neighbors
        rowIndex1 = find(gID{iLayer} == structure3D(iGrain).ID);    % find if current grain is in this layer
        if rowIndex1
            euler1 = [gPhi1{iLayer}(rowIndex1),gPhi{iLayer}(rowIndex1),gPhi2{iLayer}(rowIndex1)];
            tempNNeighbors = gNNeighbors{iLayer}(rowIndex1);  % find neighbors in this layer
            tempNeighbors = gNeighbors{iLayer}(rowIndex1,1:tempNNeighbors);
            for iTempNb = 1:tempNNeighbors
                % copy into structure: (1) neighbor-ID, (2) calculate misorientation, (3) find g.b length, (4) find g.b inclination angle?
                rowIndex2 = find(tempNeighbors(iTempNb) == gID{iLayer});
                euler2 = [gPhi1{iLayer}(rowIndex2), gPhi{iLayer}(rowIndex2),gPhi2{iLayer}(rowIndex2)];
                
                % if not exist in topper layer, add new line.  Otherwise, add to old line.
                if isempty(find(structure3D(iGrain).neighbor == tempNeighbors(iTempNb), 1))     % Not yet exist
                    structure3D(iGrain).neighbor = [structure3D(iGrain).neighbor, tempNeighbors(iTempNb)];
                    if gEdge3D(gID3D==tempNeighbors(iTempNb))==1    % if this neighbor is an edge grain, then size = NaN, becuase don't know exact size.
                        tempNeighborDiameter3D = nan;
                        tempNeighborVolume3D = nan;
                    else
                        tempNeighborDiameter3D = gDiameter3D(gID3D==tempNeighbors(iTempNb));
                        tempNeighborVolume3D = gVolume3D(gID3D==tempNeighbors(iTempNb));
                    end
                    structure3D(iGrain).neighborDiameter = [structure3D(iGrain).neighborDiameter, tempNeighborDiameter3D];
                    structure3D(iGrain).neighborVolume = [structure3D(iGrain).neighborVolume, tempNeighborVolume3D];
                    tempIndex = find(structure3D(iGrain).neighbor == tempNeighbors(iTempNb));  % find the index of this neighbor in the parent grain's neighbor array
                    structure3D(iGrain).misorientationArray{tempIndex} = calculate_misorientation_hcp(euler1,euler2);
                    structure3D(iGrain).gbLengthArray{tempIndex} = zeros(1,nEBSDfiles);     % initialize.  Each g.b has nEBSDfiles of layers, but when >0, it shows in this layer.
                    structure3D(iGrain).gbLengthArray{tempIndex}(iLayer) = sum((boundaryID{iLayer}(:)==tempNeighbors(iTempNb))&(neighborID{iLayer}(:)==gID3D(iGrain)));
                else        % does exist already
                    tempIndex = find(structure3D(iGrain).neighbor == tempNeighbors(iTempNb));  % find the (row) index of this neighbor in the parent grain's neighbors array
                    structure3D(iGrain).misorientationArray{tempIndex} = [structure3D(iGrain).misorientationArray{tempIndex}, calculate_misorientation_hcp(euler1,euler2)];
                    structure3D(iGrain).gbLengthArray{tempIndex}(iLayer) = sum((boundaryID{iLayer}(:)==tempNeighbors(iTempNb))&(neighborID{iLayer}(:)==gID3D(iGrain)));
                end
            end
        end
    end
    structure3D(iGrain).nNeighbor = length(structure3D(iGrain).neighbor);
    for iNeighbor = 1:structure3D(iGrain).nNeighbor
        structure3D(iGrain).misorientation(iNeighbor) = mean(structure3D(iGrain).misorientationArray{iNeighbor});   % a grain pair can exist in different layers.  So, average the misorientations measured in different layers
        structure3D(iGrain).gbArea(iNeighbor) =  dot(structure3D(iGrain).gbLengthArray{iNeighbor}, layerDepth);
    end
end