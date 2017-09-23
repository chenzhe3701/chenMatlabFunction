% [nbMisoLocal, nbPlusMisoLocal, nbMisoByGbLocal]...
%    = calculate_local_miso(topInteractionRadius, layerDepth, ebsdStepSize,ID,gID,gID3D,structure3D,neighborIDonGb)
%
% (0) cOrientLocal = all (maybe c-axis) orientations within a local sphere averaged by volume
% (1) nbMisoLocal: current pixel is P.  P belonga to grain A.  A has neighbors
% Bs.  Bs have volumes within a sphere.  nbDiaLocal is Bs' misorientation
% to A averaged by Bs' volumes within this sphere.
% (2) nbPlusMisoLocal: current pixel is P.  P belonga to grain A.  A has neighbors
% Bs.  Add A itself into Bs to form Cs.  Cs have volumes within a sphere.
% nbPlusDiaLocal is Cs' misorientations to A averaged by Cs' volumes within this sphere.
% Note that A's misorientation to A is 0.
% (3) nbDiaByGbLocal: same as (2) except that diameters are averaged by
% boundary area between the neighbors and A.

% Zhe Chen, 2015-8-15 revised

function [nbMisoLocal, nbPlusMisoLocal, nbMisoByGbLocal]...
    = calculate_local_miso(topInteractionRadius, layerDepth, ebsdStepSize,ID,gID,gID3D,structure3D,neighborIDonGb)

% topInteractionRadius = topInteractionRadius;  % interaction radius on top layer, in actual units (um)
layerDepth = layerDepth*1;
cumLayerDepth = cumsum(layerDepth);     % cummulative layer depth
layerBaseDepth = [0,cumLayerDepth(cumLayerDepth<topInteractionRadius)];
if length(layerBaseDepth)>length(layerDepth)
    layerBaseDepth = layerBaseDepth(1:length(layerDepth));
end
clear 'interactionRadius' 'interactionRadiusIndex' 'convFilter';

% construct convolve filters on different layers.
for iLayer = 1:length(layerBaseDepth)
    interactionRadius(iLayer) = sqrt(topInteractionRadius^2-(layerBaseDepth(iLayer))^2);     % interaction volume radius in this layer
    interactionRadiusIndex(iLayer) = max(floor(interactionRadius(iLayer)/ebsdStepSize),1);  % convert radius to # of index spanned, this value has to > 0
    
    convFilter{iLayer} = zeros(1+2*interactionRadiusIndex(1));  % initialize convFilter for this layer. size = top layer size, but will add 1's later
    
    [cc,rr] = meshgrid(1:1+2*interactionRadiusIndex(1),1:1+2*interactionRadiusIndex(1));
    inCircleTR = sqrt((rr-1-interactionRadiusIndex(1)).^2+(cc-1-interactionRadiusIndex(1)).^2) <= interactionRadiusIndex(iLayer);   % index circular region within interactionRadius in this layer
    convFilter{iLayer}(inCircleTR) = 1;     % assign 1's to elements in convFilter{thisLayer}, the elements are within Radius
    
end
nLayers = length(convFilter);   % for such interaction volume, how many layers we actually have

% construct losts of maps, for each layer, that can be used for convolution
% diaLocal = zeros(size(ID{1}));
% diaGoodPixelLocal = zeros(size(ID{1}));
nbMisoLocal = zeros(size(ID{1}));
nbMisoGoodPixelLocal = zeros(size(ID{1}));
nbPlusMisoLocal = zeros(size(ID{1}));
nbPlusMisoGoodPixelLocal = zeros(size(ID{1}));
nbMisoByGbLocal = zeros(size(ID{1}));
nbMisoByGbGoodPixelLocal =zeros(size(ID{1}));

for iLayer = 1:nLayers
%     miso3DL{iLayer} = assign_field_to_cell(ID{iLayer},gID3D,gDiameter3D,gEdge3D);   % 3D-diameter map for this layer.  NaN for edge grain
%     
%     miso3DL_isan{iLayer} = ~isnan(miso3DL{iLayer});      % if the diameter3D of this pixel is aNumber
%     
%     miso3DL{iLayer}(~miso3DL_isan{iLayer}) = 0;      % change NaN to 0
%     
%     % (1) Calculate Local Diameter
%     diaConvL{iLayer} = conv2(miso3DL{iLayer},convFilter{iLayer},'same');   % conv sum of the local diameters
%     diaGoodPixelConvL{iLayer} = conv2(double(miso3DL_isan{iLayer}),convFilter{iLayer},'same');     % conv sum of the local pixels whose dia is aNum
%     
    indexFrame = zeros(size(ID{iLayer}));
    indexFrame([1:interactionRadiusIndex(iLayer),(size(indexFrame,1)-interactionRadiusIndex(iLayer)):size(indexFrame,1)],:) = 1;    % in frame region, less than 80% pixels' diameter is NaN
    indexFrame(:,[1:interactionRadiusIndex(iLayer),(size(indexFrame,2)-interactionRadiusIndex(iLayer)):size(indexFrame,2)]) = 1;
    indexFrame = logical(indexFrame);
%     diaConvL{iLayer}(indexFrame) = NaN;
%     diaLocal = diaLocal + diaConvL{iLayer}*layerDepth(iLayer);                              % sum up convolved diameters in all layers
%     diaGoodPixelLocal = diaGoodPixelLocal + diaGoodPixelConvL{iLayer}*layerDepth(iLayer);   % sum up good pixels in all layers
    
    % (1) Initialize (for each layer) LocalNeighborDiameter (without acontribution from the grain itself)
    nbMisoConvL{iLayer} = zeros(size(ID{1}));
    nbMisoGoodPixelConvL{iLayer} = zeros(size(ID{1}));
    % (2) Initialize (for each layer) LocalNeighborDiameter (with contribution from the grain itself)
    nbPlusMisoConvL{iLayer} = zeros(size(ID{1}));
    nbPlusMisoGoodPixelConvL{iLayer} = zeros(size(ID{1}));
        
    % (3) Initialize (for each layer) LocalNeighborDiameter weighed by GrainBoundary
    nbMisoByGbConvL{iLayer} = zeros(size(ID{1}));
    nbMisoByGbGoodPixelConvL{iLayer} = zeros(size(ID{1}));
    
    % (1),(2),and(3) The map is constructed by info for each grain
    for iGrain = 1:length(gID{1})
        currentID = gID{1}(iGrain);
        index = (currentID==gID3D);
        pStructure = structure3D(index);
        currentNb = pStructure.neighbor;     % 'true' neighbors
        currentNbPlus = [currentNb, currentID];      % neighbors plus itself
        
        % make a new Map for Misorientation %%%%%%
        misoMapTg = zeros(size(ID{iLayer}));
        nbMisoGoodPixelMapTg = misoMapTg;
        nbPlusMisoGoodPixelMapTg = misoMapTg;
        nbMisoByGbGoodPixelMapTg = misoMapTg;
        for ii=1:pStructure.nNeighbor
            misoMapTg(ID{iLayer}==pStructure.neighbor(ii))=pStructure.misorientation(ii);
        end
        nbMisoGoodPixelMapTg(ismember(ID{iLayer},currentNb)) = 1;
        nbPlusMisoGoodPixelMapTg(ismember(ID{iLayer},currentNbPlus)) = 1;
        nbMisoByGbGoodPixelMapTg(neighborIDonGb{iLayer}==currentID) = 1;
        
        % calculation for (1)
        nbMisoConvTg = conv2(misoMapTg, convFilter{iLayer}, 'same');                  % Tg for 'this grain'
        nbMisoGoodPixelConvTg = conv2(nbMisoGoodPixelMapTg, convFilter{iLayer}, 'same');
        nbMisoConvTg(ID{1}~=currentID) = 0;      % only get values for ThisGrain !!!
        nbMisoGoodPixelConvTg(ID{1}~=currentID) = 0;     % only get values for ThisGrain
        
        nbMisoConvL{iLayer} = nbMisoConvL{iLayer} + nbMisoConvTg;
        nbMisoGoodPixelConvL{iLayer} = nbMisoGoodPixelConvL{iLayer} + nbMisoGoodPixelConvTg;
        
        % calculation for (2)
        nbPlusMisoConvTg = conv2(misoMapTg, convFilter{iLayer}, 'same');   % (3.1) The grain itself contribute to Neighboring diameter, by using it's own diameter
        nbPlusMisoGoodPixelConvTg = conv2(nbPlusMisoGoodPixelMapTg, convFilter{iLayer}, 'same');
        nbPlusMisoConvTg(ID{1}~=currentID) = 0;      % only get values for ThisGrain   !!!
        nbPlusMisoGoodPixelConvTg(ID{1}~=currentID) = 0;     % only get values for ThisGrain
        
        nbPlusMisoConvL{iLayer} = nbPlusMisoConvL{iLayer} + nbPlusMisoConvTg;
        nbPlusMisoGoodPixelConvL{iLayer} = nbPlusMisoGoodPixelConvL{iLayer} + nbPlusMisoGoodPixelConvTg;
        
        % calculation for (3)
        nbMisoByGbConvTg = conv2(misoMapTg.*nbMisoByGbGoodPixelMapTg, convFilter{iLayer}, 'same');
        nbMisoByGbGoodPixelConvTg = conv2(nbMisoByGbGoodPixelMapTg, convFilter{iLayer}, 'same');
        nbMisoByGbConvTg(ID{1}~=currentID) = 0;  % only get values for this grain !!!
        nbMisoByGbGoodPixelConvTg(ID{1}~=currentID) = 0;
        
        nbMisoByGbConvL{iLayer} = nbMisoByGbConvL{iLayer} + nbMisoByGbConvTg;
        nbMisoByGbGoodPixelConvL{iLayer} = nbMisoByGbGoodPixelConvL{iLayer} + nbMisoByGbGoodPixelConvTg;
        
        if mod(iGrain,20)==0
            disp(['finished # of grains = ', num2str(iGrain)]);
        end
    end
    nbMisoConvL{iLayer}(indexFrame) = NaN;   % for frame region, assign with NaN
    nbPlusMisoConvL{iLayer}(indexFrame) = NaN; 
    nbMisoByGbConvL{iLayer}(indexFrame) = NaN;
    
    nbMisoLocal = nbMisoLocal + nbMisoConvL{iLayer}*layerDepth(iLayer);                                        % add up all layers.  applies to (2), (3), (4)
    nbMisoGoodPixelLocal = nbMisoGoodPixelLocal + nbMisoGoodPixelConvL{iLayer}*layerDepth(iLayer);                 
    nbPlusMisoLocal = nbPlusMisoLocal + nbPlusMisoConvL{iLayer}*layerDepth(iLayer);
    nbPlusMisoGoodPixelLocal = nbPlusMisoGoodPixelLocal + nbPlusMisoGoodPixelConvL{iLayer}*layerDepth(iLayer);
    nbMisoByGbLocal = nbMisoByGbLocal + nbMisoByGbConvL{iLayer}*layerDepth(iLayer);
    nbMisoByGbGoodPixelLocal = nbMisoByGbGoodPixelLocal + nbMisoByGbGoodPixelConvL{iLayer}*layerDepth(iLayer);
    
    disp(['Finished Layer = ', num2str(iLayer)]);
end

% diaLocal = diaLocal./diaGoodPixelLocal;   % dia locally = (sum convolved diameters in all layers)/(sum convolved pixel #s in all layers)
nbMisoLocal = nbMisoLocal./nbMisoGoodPixelLocal;
nbPlusMisoLocal = nbPlusMisoLocal./nbPlusMisoGoodPixelLocal;
nbMisoByGbLocal = nbMisoByGbLocal./nbMisoByGbGoodPixelLocal;

display('calculated local misorientation, ..., etc');
display(datestr(now));



