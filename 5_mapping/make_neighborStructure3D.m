% neighborStruct3D = make_neighborStructure3D(neighborStruct)
% make neighborStructure3D from neighborStructure{}

% Zhe Chen, 2015-08-22 revised.

function neighborStruct3D = make_neighborStructure3D(neighborStruct)

nLayer = length(neighborStruct);
grain1 = [];
for iLayer = 1:nLayer
   grain1 = [grain1;neighborStruct(iLayer).g1]; 
end
neighborStruct3D.g1 = unique(grain1);
neighborStruct3D.g2 = cell(length(neighborStruct3D.g1),1);

for iLayer = 1:nLayer
   nGrains = length(neighborStruct(iLayer).g1);     % how many grains in this layer
   
   for iGrain = 1:nGrains
       currentID = neighborStruct(iLayer).g1(iGrain);   % grain in this layer 
       ind = find (neighborStruct3D.g1==currentID);     % check if this grain is in grain3d
       neighborStruct3D.g2{ind} = [neighborStruct3D.g2{ind};neighborStruct(iLayer).g2{iGrain}];     % copy all neighbors into grain1's grain2 cell
   end
end

for ii=1:length(neighborStruct3D.g1)
   neighborStruct3D.g2{ii} = unique(neighborStruct3D.g2{ii});       % find unique neighbors
end