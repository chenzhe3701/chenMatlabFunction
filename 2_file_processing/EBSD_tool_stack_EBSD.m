% criterion for same grain is  small misorientation, similar grain size, similar ellipticity
clear;

% data files
nEBSDfiles = inputdlg('how many layers of EBSD data in total?','input',1,{'5'});
nEBSDfiles = str2num(nEBSDfiles{1});
for iEBSDfiles = 1: nEBSDfiles
    [EBSDfileName1{iEBSDfiles}, EBSDfilePath1{iEBSDfiles}] = uigetfile('.csv',['choose the EBSD file (csv format, from type-1 grain file), layer-',num2str(iEBSDfiles)]);
    [EBSDfileName2{iEBSDfiles}, EBSDfilePath2{iEBSDfiles}] = uigetfile('.csv',['choose the EBSD file (csv format, from type-2 grain file), layer-',num2str(iEBSDfiles)]);
end
% angle criterion for grains in adjacent layers to be considered as the same grain
criticalAngle = ones(nEBSDfiles,1)*20;
criticalAngle(1) = 20;

%% manually determined same grains, {layer}[grain on top, grain on bottom].  Preassign impossible conditions to fill field.
for iEBSDfiles = 1:nEBSDfiles
    assignPair{iEBSDfiles} = [-10000 -10000];
end
assignPair{1} = [110,118;
166,168;
];
assignPair{2} = [227,271;
];

assignPair{3} = [124,127;
293,281;
];


%
for iEBSDfiles = 1: nEBSDfiles          % read EBSD data for all the layers
    EBSDdata1{iEBSDfiles} = csvread([EBSDfilePath1{iEBSDfiles}, EBSDfileName1{iEBSDfiles}],1,0);
    EBSDdata2{iEBSDfiles} = csvread([EBSDfilePath2{iEBSDfiles}, EBSDfileName2{iEBSDfiles}],1,0);
    columnIndex1{iEBSDfiles} =  find_variable_column_from_CSV_grain_file(EBSDfilePath1{iEBSDfiles}, EBSDfileName1{iEBSDfiles}, {'grain-ID'});
    columnIndex2{iEBSDfiles} =  find_variable_column_from_CSV_grain_file(EBSDfilePath2{iEBSDfiles}, EBSDfileName2{iEBSDfiles}, {'grainId','phi1-d','phi-d','phi2-d','n-neighbor+id','ellipticity','grain-dia-um'});
end

% reassign grain ID so that they are unique
for iEBSDfiles = 2:nEBSDfiles
    increment = max(EBSDdata2{iEBSDfiles-1}(:,columnIndex2{iEBSDfiles-1}(1)));
    EBSDdata1{iEBSDfiles}(:,columnIndex1{iEBSDfiles}(1)) = EBSDdata1{iEBSDfiles}(:,columnIndex1{iEBSDfiles}(1)) + increment;
    EBSDdata2{iEBSDfiles}(:,columnIndex2{iEBSDfiles}(1)) = EBSDdata2{iEBSDfiles}(:,columnIndex2{iEBSDfiles}(1)) + increment;
    nColumn = size(EBSDdata2{iEBSDfiles},2);
    EBSDdata2{iEBSDfiles}(:,(columnIndex2{iEBSDfiles}(5)+1):nColumn) = EBSDdata2{iEBSDfiles}(:,(columnIndex2{iEBSDfiles}(5)+1):nColumn) + (EBSDdata2{iEBSDfiles}(:,(columnIndex2{iEBSDfiles}(5)+1):nColumn)~=0)*increment;
    
    assignPair{iEBSDfiles-1}(:,2) = assignPair{iEBSDfiles-1}(:,2) + increment;
    assignPair{iEBSDfiles}(:,1) = assignPair{iEBSDfiles}(:,1) + increment;
    
end

% identify the same grain on adjacent layer
for iEBSDfiles = 1:(nEBSDfiles-1)       % for each Layer
    sizeDiffHistory = 100000*ones(max(EBSDdata2{iEBSDfiles+1}(:,columnIndex2{iEBSDfiles+1}(1))),1);     % initialize an array indicating history of grain size difference, default = 10000 (very big)
    for iTopGrain = 1:size(EBSDdata2{iEBSDfiles},1)    % for each grain in this Layer
        topID = EBSDdata2{iEBSDfiles}(iTopGrain,columnIndex2{iEBSDfiles}(1));      % the ID of the grain on top layer
        euler = [EBSDdata2{iEBSDfiles}(iTopGrain,columnIndex2{iEBSDfiles}(2)),EBSDdata2{iEBSDfiles}(iTopGrain,columnIndex2{iEBSDfiles}(3)),EBSDdata2{iEBSDfiles}(iTopGrain,columnIndex2{iEBSDfiles}(4))];
        
        areaIndex = (EBSDdata1{iEBSDfiles}(:,columnIndex1{iEBSDfiles}(1))==topID);      % find the grain IDs on the next layer in the same area
        bottomID = EBSDdata1{iEBSDfiles+1}(areaIndex,columnIndex1{iEBSDfiles+1}(1));
        bottomID = bottomID(~isnan(bottomID));
        bottomID = unique(bottomID);    % these are the grain IDs on the next layer in the same area
        
        sameGrainTF = zeros(size(bottomID,1),1);    % initialize boolean indicating if the subgrain is the same grain as the top grain,
        misAngle = ones(size(bottomID,1),1)*200;    % initialize array indicating misorientation angle, default = 200 (big)
        overlayArea = zeros(size(bottomID,1),1);    % initialize array indicating overlayed area, default = 0 (small, no overlay)
        ellipticityDiff = ones(size(bottomID,1),1)*100;     % initialize array indicating ellipticity difference, default = 100 (big)
        for iBottomGrain = 1:length(bottomID)      % for each grain in this bottom layer, calculate if misorientation is smaller than criterion
            rowIndex2 = find(EBSDdata2{iEBSDfiles+1}(:,columnIndex2{iEBSDfiles+1}(1))==bottomID(iBottomGrain)); % row index of bottom layer grain in type-2 data
            eulerBottom = [EBSDdata2{iEBSDfiles+1}(rowIndex2,columnIndex2{iEBSDfiles+1}(2)),EBSDdata2{iEBSDfiles+1}(rowIndex2,columnIndex2{iEBSDfiles+1}(3)),EBSDdata2{iEBSDfiles+1}(rowIndex2,columnIndex2{iEBSDfiles+1}(4))];
            [tempAngle,tempAxis] = calculate_misorientation_hcp(euler,eulerBottom);
            misAngle(iBottomGrain) = tempAngle;
            if misAngle(iBottomGrain) < criticalAngle(iEBSDfiles)
                sameGrainTF(iBottomGrain) = 1;
                overlayArea(iBottomGrain) = sum(EBSDdata1{iEBSDfiles+1}(areaIndex,columnIndex1{iEBSDfiles+1}(1))==bottomID(iBottomGrain));
                ellipticityDiff(iBottomGrain) = abs(EBSDdata2{iEBSDfiles}(iTopGrain,columnIndex2{iEBSDfiles}(6))-EBSDdata2{iEBSDfiles+1}(rowIndex2,columnIndex2{iEBSDfiles+1}(6)));
            end
        end
        
        % if there is a same grain, find the subgrain with the smallest misorientation, largest overlay area, to the top grain, and modify its ID
        if sum(assignPair{iEBSDfiles}(:,1)==topID)  % if topID belongs to one of the pre-assigned pairs, then change !!!!
            rowIndex = find(assignPair{iEBSDfiles}(:,1)==topID);
            bottomID = assignPair{iEBSDfiles}(rowIndex,2);
            sizeDiffHistory(topID) = -1;                     % make it small enough
            
            rowIndex1 = (EBSDdata1{iEBSDfiles+1}(:,columnIndex1{iEBSDfiles+1}(1))==bottomID);    % rows in bottom layer type-1 data, these rows' ID need to be changed
            EBSDdata1{iEBSDfiles+1}(rowIndex1,columnIndex1{iEBSDfiles+1}(1)) = topID;
            
            rowIndex2 = find(EBSDdata2{iEBSDfiles+1}(:,columnIndex2{iEBSDfiles+1}(1))==bottomID);    % row in bottom layer type-2 data, the rows' ID need to be changed
            EBSDdata2{iEBSDfiles+1}(rowIndex2,columnIndex2{iEBSDfiles+1}(1)) = topID;
            
            if sum(assignPair{iEBSDfiles+1}(:,1)==bottomID) % change the next assignPair if necessary
                rowIndex = find(assignPair{iEBSDfiles+1}(:,1)==bottomID);
                assignPair{iEBSDfiles+1}(rowIndex,1)=topID;
            end
            
            
            % then, search in EBSDdata2 for all grains who have this grain as neighbor, change their 'n-neighbor+id' info
            [nRow,nColumn] = size(EBSDdata2{iEBSDfiles+1});
            for iRow = 1:nRow
                neighbors = EBSDdata2{iEBSDfiles+1}(iRow,(columnIndex2{iEBSDfiles+1}(5)+1):nColumn);
                neighbors(neighbors == bottomID) = topID;
                EBSDdata2{iEBSDfiles+1}(iRow,(columnIndex2{iEBSDfiles+1}(5)+1):nColumn)=0;
                neighbors = neighbors(neighbors ~= 0);
                neighbors = unique(neighbors);
                lengthNeighbors = length(neighbors);
                EBSDdata2{iEBSDfiles+1}(iRow,columnIndex2{iEBSDfiles+1}(5))=lengthNeighbors;
                EBSDdata2{iEBSDfiles+1}(iRow,(columnIndex2{iEBSDfiles+1}(5)+1):(columnIndex2{iEBSDfiles+1}(5)+lengthNeighbors)) = neighbors;
            end
        elseif sum(sameGrainTF)     % no pre-assign, but there is at least one meet the misorientation criterion
            misAngleScore = zeros(length(sameGrainTF),1);
            overlayScore = zeros(length(sameGrainTF),1);
            ellipticityDiffScore = zeros(length(sameGrainTF),1);
            totalScore = zeros(length(sameGrainTF),1);
            [~,misAngleSeq] = sort(misAngle,'ascend');
            misAngleScore(misAngleSeq) = 1:length(misAngleSeq);
            [~,overlaySeq] = sort(overlayArea,'descend');
            overlayScore(overlaySeq) = 1:length(overlaySeq);
            [~,ellipticityDiffSeq] = sort(ellipticityDiff,'ascend');
            ellipticityDiffScore(ellipticityDiffSeq) = 1:length(ellipticityDiffSeq);
            totalScore = misAngleScore + overlayScore + ellipticityDiffScore;
            [~,sortedIndex] = sort(totalScore,'ascend');      % consider 3 factors, sort candidates based on score.  Smaller score means higher probability of being same grain
            
            % If grain 1 and 2 are on top layer, grain 3 is on bottom layer.  Grain 3 was first identified to be the same as grain 1, their size diff is 100.
            % Later, new grain 1 on bottom layer (old grain 3) was again identified to be the same as grain 2, but this time, their size diff is 1000.  Then, it should not be changed again.
            % This part keep a record of the sizeDiffHistory of the grain who is on bottom layer and its ID was changed.  Compare to determine if it needs to be changed again.
            % Check from the most likely candidate, if changed, then jump out of the loop.
            iCandidate = 1;
            while iCandidate < sum(sameGrainTF)+1
                indexInBottomID = sortedIndex(iCandidate);
                sizeDiff = abs(EBSDdata2{iEBSDfiles}(iTopGrain,columnIndex2{iEBSDfiles}(7)) - EBSDdata2{iEBSDfiles+1}((EBSDdata2{iEBSDfiles+1}(:,columnIndex2{iEBSDfiles+1}(1))==bottomID(indexInBottomID)),columnIndex2{iEBSDfiles+1}(7)));
                
                if find(assignPair{iEBSDfiles}(:,2)==bottomID(indexInBottomID)) % if this bottom grain has pre-assignment, then don't change, make sizeDiff big
                    sizeDiff = 100000;
                end
                
                if sizeDiff < sizeDiffHistory(bottomID(indexInBottomID))    % if size is more similar, THEN change !!!!!!!!!!
                    sizeDiffHistory(topID) = sizeDiff;                     % If sizeDiff is small, then the bottom grain is changed to the same ID as the top grain.  Then assign this size difference to this sizeDiffHistory element.
                    rowIndex1 = (EBSDdata1{iEBSDfiles+1}(:,columnIndex1{iEBSDfiles+1}(1))==bottomID(indexInBottomID));    % rows in bottom layer type-1 data, these rows' ID need to be changed
                    EBSDdata1{iEBSDfiles+1}(rowIndex1,columnIndex1{iEBSDfiles+1}(1)) = topID;
                    
                    rowIndex2 = find(EBSDdata2{iEBSDfiles+1}(:,columnIndex2{iEBSDfiles+1}(1))==bottomID(indexInBottomID));    % row in bottom layer type-2 data, the rows' ID need to be changed
                    EBSDdata2{iEBSDfiles+1}(rowIndex2,columnIndex2{iEBSDfiles+1}(1)) = topID;
                    
                    if sum(assignPair{iEBSDfiles+1}(:,1)==bottomID(indexInBottomID)) % change the next assignPair if necessary
                        rowIndex = find(assignPair{iEBSDfiles+1}(:,1)==bottomID(indexInBottomID));
                        assignPair{iEBSDfiles+1}(rowIndex,1)=topID;
                    end
                    
                    % then, search in EBSDdata2 for all grains who have this grain as neighbor, change their 'n-neighbor+id' info
                    [nRow,nColumn] = size(EBSDdata2{iEBSDfiles+1});
                    for iRow = 1:nRow
                        neighbors = EBSDdata2{iEBSDfiles+1}(iRow,(columnIndex2{iEBSDfiles+1}(5)+1):nColumn);
                        neighbors(neighbors == bottomID(indexInBottomID)) = topID;
                        EBSDdata2{iEBSDfiles+1}(iRow,(columnIndex2{iEBSDfiles+1}(5)+1):nColumn)=0;
                        neighbors = neighbors(neighbors ~= 0);
                        neighbors = unique(neighbors);
                        lengthNeighbors = length(neighbors);
                        EBSDdata2{iEBSDfiles+1}(iRow,columnIndex2{iEBSDfiles+1}(5))=lengthNeighbors;
                        EBSDdata2{iEBSDfiles+1}(iRow,(columnIndex2{iEBSDfiles+1}(5)+1):(columnIndex2{iEBSDfiles+1}(5)+lengthNeighbors)) = neighbors;
                    end
                    iCandidate=sum(sameGrainTF)+1;
                else
                    iCandidate=iCandidate+1;
                end
                
            end
        end
        
    end
end

%% output stacked data (mainly, each layer is maintained, but IDs are unique!)
for iEBSDfiles = 1:nEBSDfiles
    header1 = find_CSV_header([EBSDfilePath1{iEBSDfiles},EBSDfileName1{iEBSDfiles}]);
    header2 = find_CSV_header([EBSDfilePath2{iEBSDfiles},EBSDfileName2{iEBSDfiles}]);
    
    csvwrite([EBSDfilePath1{iEBSDfiles}, strtok(EBSDfileName1{iEBSDfiles},'.'), '-stacked.csv'],EBSDdata1{iEBSDfiles},1,0);
    xlswrite([EBSDfilePath1{iEBSDfiles}, strtok(EBSDfileName1{iEBSDfiles},'.'), '-stacked.csv'],header1);
    csvwrite([EBSDfilePath2{iEBSDfiles}, strtok(EBSDfileName2{iEBSDfiles},'.'), '-stacked.csv'],EBSDdata2{iEBSDfiles},1,0);
    xlswrite([EBSDfilePath2{iEBSDfiles}, strtok(EBSDfileName2{iEBSDfiles},'.'), '-stacked.csv'],header2);
end

%% run on WS2.  Not weighted version.  Old.
% find average neighbor size
% avgNeighborDiameter = zeros(size(EBSDdata1{1},1),1);
% nNeighbors = zeros(size(EBSDdata1{1},1),1);
% for iRow = 1:size(EBSDdata2{1},1)
%     currentID = EBSDdata2{1}(iRow,columnIndex2{1}(1));
%     neighborSizes = [];
%     for iEBSDfiles = 1:nEBSDfiles
%         indexRow = find(EBSDdata2{iEBSDfiles}(:,columnIndex2{iEBSDfiles}(1))==currentID);
%         nNeighborsInLayer = EBSDdata2{iEBSDfiles}(indexRow,columnIndex2{iEBSDfiles}(5));
%         neighbors = EBSDdata2{iEBSDfiles}(indexRow,[(columnIndex2{iEBSDfiles}(5)+1):(columnIndex2{iEBSDfiles}(5)+nNeighborsInLayer)]);
%         for iNeighbors = 1:nNeighborsInLayer
%            neighborSizes = [neighborSizes,EBSDdata2{iEBSDfiles}(find(EBSDdata2{iEBSDfiles}(:,columnIndex2{iEBSDfiles}(1))==neighbors(iNeighbors)),columnIndex2{iEBSDfiles}(7))];
%         end
%     end
%     currentAvgNeighborSize = mean(neighborSizes);
%     currentNNeighbors = length(neighborSizes);
%     avgNeighborDiameter(EBSDdata1{1}(:,columnIndex1{1}(1))==currentID, 1) = currentAvgNeighborSize;
%     nNeighbors(EBSDdata1{1}(:,columnIndex1{1}(1))==currentID, 1) = currentNNeighbors;
% end


% thick = [1,6,25,20,10];
% gID3D = [];    % in order to find all IDs in all layers
% for iEBSDfiles = 1:nEBSDfiles
%     gID3D = [gID3D; EBSDdata2{iEBSDfiles}(:,columnIndex2{iEBSDfiles}(1))];
% end
% gID3D = unique(gID3D);
% gDepth = zeros(length(gID3D),1);
% gWidth = zeros(length(gID3D),1);
% gVolumn3D = zeros(length(gID3D),1);
% gNeighbor3D = cell(length(gID3D),1);
% for iEBSDfiles = 1:nEBSDfiles
%     for iGrain = 1:length(gID3D)
%         rowIndex = EBSDdata2{iEBSDfiles}(:,columnIndex2{iEBSDfiles}(1))==gID3D(iGrain);
%         if sum(rowIndex)    % if this grain exist in this layer
%             gDepth(iGrain) = gDepth(iGrain)+thick(iEBSDfiles);
%             gWidth(iGrain) = gWidth(iGrain)*(iEBSDfiles-1)/iEBSDfiles + EBSDdata2{iEBSDfiles}(rowIndex, columnIndex2{iEBSDfiles}(7))/iEBSDfiles;
%             gVolumn3D(iGrain) = gVolumn3D(iGrain) + thick(iEBSDfiles)*pi()*(EBSDdata2{iEBSDfiles}(rowIndex,columnIndex2{iEBSDfiles}(7)))^2;
%             gNeighbor3D{iGrain} = [gNeighbor3D{iGrain},EBSDdata2{iEBSDfiles}(rowIndex,(columnIndex2{iEBSDfiles}(5)+1):(columnIndex2{iEBSDfiles}(5)+ EBSDdata2{iEBSDfiles}(rowIndex,columnIndex2{iEBSDfiles}(5))))];
%             gNeighbor3D{iGrain} = unique(gNeighbor3D{iGrain});
%         end
%     end
% end
% gDiameter3D = (gVolumn3D*3/4/pi()).^(1/3);
% gAspect3D = gWidth./gDepth;

%% calculate grain size weighed misorientation
% misorientationSized = zeros(length(EBSDdata2{1}),1);
% misorientationValue = cell(max(gID3D),1);
% misorientationWeight = cell(max(gID3D),1);
% for iEBSDfiles = 1:nEBSDfiles
%     for iRow = 1:length(EBSDdata2{iEBSDfiles})
%         currentID = EBSDdata2{iEBSDfiles}(iRow,columnIndex2{iEBSDfiles}(1));
%         neighborID = EBSDdata2{iEBSDfiles}(iRow,(columnIndex2{iEBSDfiles}(5)+1):(columnIndex2{iEBSDfiles}(5)+ EBSDdata2{iEBSDfiles}(iRow,columnIndex2{iEBSDfiles}(5))));
%         nNeighborID = length(neighborID);
%         rowIndex1 = find(EBSDdata2{iEBSDfiles}(:,columnIndex2{iEBSDfiles}(1))==currentID);
%         euler1 = EBSDdata2{iEBSDfiles}(rowIndex1,[columnIndex2{iEBSDfiles}(2),columnIndex2{iEBSDfiles}(3),columnIndex2{iEBSDfiles}(4)]);
%         for ii = 1:nNeighborID
%             rowIndex2 = find(EBSDdata2{iEBSDfiles}(:,columnIndex2{iEBSDfiles}(1))==neighborID(ii));
%             euler2 = EBSDdata2{iEBSDfiles}(rowIndex2,[columnIndex2{iEBSDfiles}(2),columnIndex2{iEBSDfiles}(3),columnIndex2{iEBSDfiles}(4)]);
%             theta = calculate_misorientation_hcp(euler1,euler2);
%             misorientationValue{currentID} = [misorientationValue{currentID},theta];
%             weight = EBSDdata2{iEBSDfiles}(rowIndex2,columnIndex2{iEBSDfiles}(7));
%             weight = weight^2;
%             misorientationWeight{currentID} = [misorientationWeight{currentID},weight];
%         end
%     end
% end
% kk=1;
% for ii=1:length(misorientationValue)
%     if ~isempty(misorientationValue{ii})
%         temp1{kk}=misorientationValue{ii};
%         temp2{kk}=misorientationWeight{ii};
%         kk = kk+1;
%     end
% end
% clear 'misorientationValue';
% clear 'misorientationWeight';
% misorientationValue = temp1;
% misorientationWeight = temp2;
% for ii=1:length(misorientationValue)
%     misorientationV(ii) = sum(misorientationValue{ii}.*misorientationWeight{ii}/sum(misorientationWeight{ii}));
% end
% misorientationV = misorientationV';






