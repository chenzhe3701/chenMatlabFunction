% cellData = assign_field_to_cell(ID,gID,fieldData,gEdge)
%
% fieldData are data corresponding to gID, and gEdge indicates if the grain is on edge.
% If the grain is on edge, the grain data will not be assigned to pixels, because the info is considered to be incomplete.
% ID is a matrix defines how the map is divided based on grian ID

% Zhe Chen, 2015-08-10 revised.

function cellData = assign_field_to_cell(ID,gID,fieldData,gEdge)
    if nargin < 4
        gEdge = zeros(size(ID));
        disp('no gEdge data provided, assume all points not on edge');
    end
    cellData = zeros(size(ID))*nan;
    for iGrain = 1:length(gID)
        if gEdge(iGrain)~=1
            cellData(ID==gID(iGrain))=fieldData(iGrain);
        end
    end
end