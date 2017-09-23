% PM: phase matrix
% boundaryTF: is it a phase boundary
% boundaryPhase: for phase boundary, what phase it is
% ID: generate unique ID for each 'grain' (continuous region of the same phase is a grain.

function [boundaryTF, boundaryPhase, ID] = find_boundary_ID_from_phase_matrix(PM)

boundaryTF = zeros(size(PM));      % if pixel is on grain boundary, then this value will be 1
boundaryPhase = zeros(size(PM));      % this indicate the grain ID of the grain which the grain boundary belongs to

a = repmat(PM,1,1,9);           % shift ID matrix to find G.B/T.P
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
    
    thisBoundaryTF = (PM~=shiftedA)&(~isnan(PM))&(~isnan(shiftedA));    % it is a boundary based on info from this layer.  Have to be a number to be considered as g.b.
    boundaryTF = boundaryTF | thisBoundaryTF;   % update boundaryTF using OR relationship

end
boundaryID_2 = PM .* boundaryTF; 
boundaryPhase(~isnan(PM))=boundaryID_2(~isnan(PM));    % take ~nan values

boundaryTF = double(boundaryTF);

display('found phaseBoundary and phaseBoundaryID');

ID = one_pass_label(PM);
display('found phaseBoundary and generated unique ID');



