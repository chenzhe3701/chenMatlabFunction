function uniqueBoundaryID = construct_unique_boundary_ID(ID)


boundaryTF = zeros(size(ID,1),size(ID,2));      % if pixel is on grain boundary, then this value will be 1
boundaryID = zeros(size(ID,1),size(ID,2));      % this indicate the grain ID of the grain which the grain boundary belongs to
neighborID = zeros(size(ID,1),size(ID,2));      % for grain boundary points, this is the grain ID of the neighboring grain

a = repmat(ID,1,1,9);           % shift ID matrix to find G.B/T.P
a(:,1:end-1,2) = a(:,2:end,2);  % shift left
a(:,2:end,3) = a(:,1:end-1,3);  % shift right
a(1:end-1,:,4) = a(2:end,:,4);  % shift up
a(2:end,:,5) = a(1:end-1,:,5);  % shift down
a(1:end-1,1:end-1,6) = a(2:end,2:end,6);    % shift up-left
a(2:end,2:end,7) = a(1:end-1,1:end-1,7);    % shift down-right
a(1:end-1,2:end,8) = a(2:end,1:end-1,8);    % shift up-right
a(2:end,1:end-1,9) = a(1:end-1,2:end,9);    % shift down-left

for ii=2:9
    shiftedA = a(:,:,ii);
    
    thisBoundaryTF = (ID~=shiftedA)&(~isnan(ID))&(~isnan(shiftedA));    % it is a boundary based on info from this layer.  Have to be a number to be considered as g.b.
    boundaryTF = boundaryTF | thisBoundaryTF;   % update boundaryTF using OR relationship
    
    thisNeighborID = shiftedA .* thisBoundaryTF;    % neighborID based on info from this layer
    thisNeighborID(isnan(thisNeighborID)) = 0;
        
    useNew = ((neighborID==0)&(thisNeighborID~=0)) | ((neighborID>0) & (0<thisNeighborID) & (thisNeighborID<neighborID)); % (old==0)and(new~=0)  OR  (old>0)and(0<new<old)
    neighborID = neighborID.*(1-useNew) + thisNeighborID .* useNew;    
end
boundaryID_2 = ID .* boundaryTF; 
boundaryID(~isnan(ID))=boundaryID_2(~isnan(ID));    % take ~nan values

% boundaryTF = double(boundaryTF);

uniqueBoundaryID = boundaryID*1000 + neighborID;

display('constructed unique GB ID, max ID should be <1000, otherwise modify code');
display(datestr(now));