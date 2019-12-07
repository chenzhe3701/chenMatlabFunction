% IPFMap = generate_IPF_map(ID,gID,gPhi1,gPhi,gPhi2,direction)
%
% ID is a vector or matrix. 
% [gID, gPhi's] are the info for Euler angles for each grain
% direction is a vector (row or column) or direction you are interested in
% IPFMap is a (:,:,3) matrix showing RGB color
%
% Uses calculate_IPF_color_hcp()
%
% Zhe Chen 2015-08-04 revised
%
% chenzhe, 2019-10-29, modify to take input phi_sys = 1x3 vector.

function IPFMap = generate_IPF_map(ID,gID,gPhi1,gPhi,gPhi2, phi_sys, direction)
    R = ones(size(ID));
    G = ones(size(ID));
    B = ones(size(ID));
    for iGrain = 1:length(gID)
        currentID = gID(iGrain);
        RGB = calculate_IPF_color_hcp([gPhi1(iGrain),gPhi(iGrain),gPhi2(iGrain)], phi_sys, [direction(1),direction(2),direction(3)]);
        index = (ID==currentID);
        R(index) = RGB(1);
        G(index) = RGB(2);
        B(index) = RGB(3);
    end
    IPFMap(:,:,1) = R;
    IPFMap(:,:,2) = G;
    IPFMap(:,:,3) = B;
end