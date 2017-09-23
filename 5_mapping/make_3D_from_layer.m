% Input gID3D and gID{all layers}
% other inputs are grain info for each layer, such as gPhi1, gPhi, gPhi2
% Output is to get unique info for each grain in all 3D layers
% the sequence is the same as gID3D
% outputs are sth like gPhi13D, gPhi3D, gPhi23D, ...

% Zhe Chen, 2015-08-22 revised

function [varargout] = make_3D_from_layer(gID3D,gID,varargin)

nLayers = length(gID);
nVarArgIn = length(varargin);

for ii=1:nVarArgIn          % For each Input grainData
    cellIn = varargin{ii};      % such as gPhi{}
    mOut = zeros(length(gID3D),1)*nan;      % such as gPhi3D = [];
    
    for jj=1:nLayers        % For each layer
       mIn = cellIn{jj};        % such as mIn = gPhi{1}
       gID_layer = gID{jj};      % such as gIDLayer = gID{1}
       
       for kk = 1:length(gID_layer)    % For each grain, check
           index = find(gID3D == gID_layer(kk));
           if isnan(mOut(index))
              mOut(index) = mIn(kk);    % assignment always based on 1st time appeared 
           end
       end
       
    end
   
    varargout{ii} = mOut;
end

end