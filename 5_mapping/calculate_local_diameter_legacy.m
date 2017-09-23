function [diaLocal, nbDiaLocal, nbPlusDiaLocal, nbPlusDiaLocal2]...
    = calculate_local_diameter(topInteractionRadius, layerDepth, ebsdStepSize,ID,gID,gID3D,gDiameter3D,gEdge3D,structure3D)

% calculate neighbor diameter local weighed by volume
% topInteractionRadius = topInteractionRadius;  % interaction radius on top layer, in actual units (um)
layerDepth = layerDepth*1;
cumLayerDepth = cumsum(layerDepth);     % cummulative layer depth
layerBaseDepth = [0,cumLayerDepth(cumLayerDepth<topInteractionRadius)];
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
diaLocal = zeros(size(ID{1}));
diaGoodPixelLocal = zeros(size(ID{1}));
nbDiaLocal = zeros(size(ID{1}));
nbDiaGoodPixelLocal = zeros(size(ID{1}));
nbPlusDiaLocal = zeros(size(ID{1}));
nbPlusDiaLocal2 = zeros(size(ID{1}));
nbPlusDiaGoodPixelLocal = zeros(size(ID{1}));
for iLayer = 1:nLayers
   diameter3DL{iLayer} = assign_field_to_cell(ID{iLayer},gID3D,gDiameter3D,gEdge3D);   % 3D-diameter map for this layer.  NaN for edge grain
   % diameter3DL_withEdge{iLayer} = diameter3DL{iLayer};          % simply copy for later comparison/use
   diameter3DL_isan{iLayer} = ~isnan(diameter3DL{iLayer});      % if the diameter3D of this pixel is aNumber
   
   diameter3DL{iLayer}(~diameter3DL_isan{iLayer}) = 0;      % change NaN to 0
   
   % (1) Calculate Local Diameter
   diaConvL{iLayer} = conv2(diameter3DL{iLayer},convFilter{iLayer},'same');   % conv sum of the local diameters
   diaGoodPixelConvL{iLayer} = conv2(double(diameter3DL_isan{iLayer}),convFilter{iLayer},'same');     % conv sum of the local pixels whose dia is aNum
   
   indexFrame = diaGoodPixelConvL{iLayer} < 0.8*pi*(interactionRadiusIndex(iLayer))^2;   % in frame region, less than 80% pixels' diameter is NaN
   diaConvL{iLayer}(indexFrame) = NaN;      
   diaLocal = diaLocal + diaConvL{iLayer}*layerDepth(iLayer);                              % sum up convolved diameters in all layers
   diaGoodPixelLocal = diaGoodPixelLocal + diaGoodPixelConvL{iLayer}*layerDepth(iLayer);   % sum up good pixels in all layers
     
   % (2) Initialize (for each layer) LocalNeighborDiameter (without acontribution from the grain itself)
   nbDiaConvL{iLayer} = zeros(size(ID{1}));             
   nbDiaGoodPixelConvL{iLayer} = zeros(size(ID{1}));
   % (3) Initialize (for each layer) LocalNeighborDiameter (with contribution from the grain itself)
   nbPlusDiaConvL{iLayer} = zeros(size(ID{1}));
   nbPlusDiaConvL2{iLayer} = zeros(size(ID{1}));
   nbPlusDiaGoodPixelConvL{iLayer} = zeros(size(ID{1}));
   
   % (2)and(3) The map is constructed by info for each grain
   for iGrain = 1:length(gID{1})
       currentID = gID{1}(iGrain);
       index = (currentID==gID3D);
       currentNb = structure3D(index).neighbor;     % 'true' neighbors
       currentNbPlus = [currentNb, currentID];      % neighbors plus itself
       
       nbDiaConvTg = conv2(diameter3DL{iLayer}.*ismember(ID{iLayer}, currentNb), convFilter{iLayer}, 'same');
       nbDiaGoodPixelConvTg = conv2(diameter3DL_isan{iLayer}.*ismember(ID{iLayer}, currentNb), convFilter{iLayer}, 'same');
       nbDiaConvTg(ID{1}~=currentID) = 0;      % only get values for ThisGrain  %% rethink carefully
       nbDiaGoodPixelConvTg(ID{1}~=currentID) = 0;     % only get values for ThisGrain
       
       nbDiaConvL{iLayer} = nbDiaConvL{iLayer} + nbDiaConvTg;
       nbDiaGoodPixelConvL{iLayer} = nbDiaGoodPixelConvL{iLayer} + nbDiaGoodPixelConvTg;
       

       nbPlusDiaConvTg = conv2(diameter3DL{iLayer}.*ismember(ID{iLayer}, currentNbPlus), convFilter{iLayer}, 'same');   % (3.1) The grain itself contribute to Neighboring diameter, by using it's own diameter
       nbPlusDiaConvTg2 = conv2(diameter3DL{iLayer}.*ismember(ID{iLayer}, currentNb), convFilter{iLayer}, 'same');   % (3.2) The grain itself contribute to Neighboring diameter, by using diameter=0
       
       nbPlusDiaGoodPixelConvTg = conv2(diameter3DL_isan{iLayer}.*ismember(ID{iLayer}, currentNbPlus), convFilter{iLayer}, 'same');
       nbPlusDiaConvTg(ID{1}~=currentID) = 0;      % only get values for ThisGrain   %% rethink carefully
       nbPlusDiaConvTg2(ID{1}~=currentID) = 0;
       nbPlusDiaGoodPixelConvTg(ID{1}~=currentID) = 0;     % only get values for ThisGrain
       
       nbPlusDiaConvL{iLayer} = nbPlusDiaConvL{iLayer} + nbPlusDiaConvTg;
       nbPlusDiaConvL2{iLayer} = nbPlusDiaConvL2{iLayer} + nbPlusDiaConvTg2;
       nbPlusDiaGoodPixelConvL{iLayer} = nbPlusDiaGoodPixelConvL{iLayer} + nbPlusDiaGoodPixelConvTg;
       
       if mod(iGrain,20)==0
           disp(['finished # of grains = ', num2str(iGrain)]);
       end
   end
   nbDiaConvL{iLayer}(indexFrame) = NaN;   % for frame region, assign with NaN
   nbPlusDiaConvL{iLayer}(indexFrame) = NaN;
   nbPlusDiaConvL2{iLayer}(indexFrame) = NaN;
   
   nbDiaLocal = nbDiaLocal + nbDiaConvL{iLayer}*layerDepth(iLayer);                                        % add up all layers
   nbDiaGoodPixelLocal = nbDiaGoodPixelLocal + nbDiaGoodPixelConvL{iLayer}*layerDepth(iLayer);                 % add up all layers
   nbPlusDiaLocal = nbPlusDiaLocal + nbPlusDiaConvL{iLayer}*layerDepth(iLayer);                            % add up all layers
   nbPlusDiaLocal2 = nbPlusDiaLocal2 + nbPlusDiaConvL2{iLayer}*layerDepth(iLayer);
   nbPlusDiaGoodPixelLocal = nbPlusDiaGoodPixelLocal + nbPlusDiaGoodPixelConvL{iLayer}*layerDepth(iLayer);     % add up all layers
   
   disp(['Finished Layer = ', num2str(iLayer)]);
end

diaLocal = diaLocal./diaGoodPixelLocal;   % dia locally = (sum convolved diameters in all layers)/(sum convolved pixel #s in all layers)
nbDiaLocal = nbDiaLocal./nbDiaGoodPixelLocal;
nbPlusDiaLocal = nbPlusDiaLocal./nbPlusDiaGoodPixelLocal;
nbPlusDiaLocal2 = nbPlusDiaLocal2./nbPlusDiaGoodPixelLocal;

% myplot(diaLocal,boundaryTF{1});
% myplot(nbDiaLocal,boundaryTF{1});
% myplot(double((diaLocal-nbDiaLocal)<10^(-3)),boundaryTF{1});
% myplot(nbPlusDiaLocal,boundaryTF{1});
% myplot(nbPlusDiaLocal2,boundaryTF{1});
% myplot(double((diaLocal-nbPlusDiaLocal)<10^(-3)),boundaryTF{1});


