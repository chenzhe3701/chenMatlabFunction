% [gID3D,gDepth3D,gWidth3D,gVolume3D,gDiameter3D,gAspect3D,gNeighbor3D,gEdge3D,depth3D,width3D,volume3D,diameter3D,aspect3D]...
%    = get_3D_geometric_info(gID, ID, gDiameter, gNeighbors,gNNeighbors, gEdge, layerDepth)
%
% gID{} is the gID for different layers
% ID is the ID for every pixel for the top layer
% g[Property]3D is for all the grains.  But [Property]3D is only for top layer
%
% Zhe Chen, 2015-08-10 revised

function [gID3D,gDepth3D,gWidth3D,gVolume3D,gDiameter3D,gAspect3D,gNeighbor3D,gEdge3D,depth3D,width3D,volume3D,diameter3D,aspect3D]...
    = get_3D_geometric_info(gID, ID, gDiameter, gNeighbors,gNNeighbors, gEdge, layerDepth)

% Find all unique IDs in all layers, make some properties for all this grains
nEBSDfiles = length(layerDepth);
gID3D = [];    
for iEBSDfiles = 1:nEBSDfiles
    gID3D = [gID3D; gID{iEBSDfiles}];
end
gID3D = unique(gID3D);


gDepth3D = zeros(length(gID3D),1);    % how deep the grain is
gWidth3D = zeros(length(gID3D),1);    % avg witdh in X-Y plan.  I.e., volumn/depth
gVolume3D = zeros(length(gID3D),1);   % accumulated volume through each layer
gNeighbor3D = cell(length(gID3D),1);
gEdge3D = zeros(length(gID3D),1);
for iEBSDfiles = 1:nEBSDfiles
    for iGrain = 1:length(gID3D)
        rowIndex = gID{iEBSDfiles}==gID3D(iGrain);
        if sum(rowIndex)    % if this grain exist in this layer
            gDepth3D(iGrain) = gDepth3D(iGrain) + layerDepth(iEBSDfiles);
            gVolume3D(iGrain) = gVolume3D(iGrain) + layerDepth(iEBSDfiles)*pi()/4*(gDiameter{iEBSDfiles}(rowIndex))^2;
            gNeighbor3D{iGrain} = [gNeighbor3D{iGrain},gNeighbors{iEBSDfiles}(rowIndex,1:gNNeighbors{iEBSDfiles}(rowIndex))];
            gNeighbor3D{iGrain} = unique(gNeighbor3D{iGrain});
            gEdge3D(iGrain) = gEdge{iEBSDfiles}(rowIndex)|gEdge3D(iGrain);     % Using bit or operation. If edge grain in one layer, then it is edge.
%             if iEBSD == nEBSDfiles  % if it is the bottom layer, then it is on edge.  Use this when have enough thickness (more complete data)
%                 gEdge3D(iGrain) = 1;
%             end
        end
    end
end
gWidth3D = 2*(gVolume3D./gDepth3D/pi()).^(1/2);   % assume columnar grain, width is the diameter of cross section in x-y plane
gDiameter3D = 2*(gVolume3D*3/4/pi()).^(1/3);    % assume ball shape grain,
gAspect3D = gWidth3D./gDepth3D;

% assign data from 3D average to all pixels on the Top layer (can modify to give bottom layers)
depth3D = assign_field_to_cell(ID,gID3D,gDepth3D,gEdge3D);
width3D = assign_field_to_cell(ID,gID3D,gWidth3D,gEdge3D);
volume3D = assign_field_to_cell(ID,gID3D,gVolume3D,gEdge3D);
diameter3D = assign_field_to_cell(ID,gID3D,gDiameter3D,gEdge3D);
aspect3D = assign_field_to_cell(ID,gID3D,gAspect3D,gEdge3D);