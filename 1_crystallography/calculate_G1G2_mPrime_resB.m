% Zhe Chen, 2016-3-10 
%
% [mPrimeMatrix, schmidFactorG1, schmidFactorG2, resBurgersMatrix,
% mPrimeMatrixRaw] = calculate_G1G2_mPrime_resB(phi1G1, phiG1, phi2G1,
% phi1G2, phiG2, phi2G2, phi1Sys, phiSys, phi2Sys, phiError, stressTensor,
% gbNormal)
% 
% There needs to be an 'incoming' and 'outgoing' burgers vector.  Because
% the slip direction is bidirectional, the residual burgers vector will
% depend on the direction of the two burgers vectors.  Therefore, the
% direction of grain boundary should be described.  In fact the boundary
% should be specified everywhere, but here we just simplify it to be a
% straight line.
%
% Zhe Chen, 2016-1-18 
%
% function [schmidFactorG1, schmidFactorG2, mPrimeMatrixRaw,
% resBurgersMatrixRaw, mPrimeMatrixAbs, resBurgersMatrixAbs] =
% calculate_G1G2_mPrime_resB(phi1G1, phiG1, phi2G1, phi1G2, phiG2, phi2G2,
% phi1Sys, phiSys, phi2Sys, phiError, stressTensor, gbNormal)

function [schmidFactorG1, schmidFactorG2, mPrimeMatrix, resBurgersMatrix, mPrimeMatrixAbs, resBurgersMatrixAbs] = calculate_G1G2_mPrime_resB(phi1G1, phiG1, phi2G1, phi1G2, phiG2, phi2G2, ...
phi1Sys, phiSys, phi2Sys, phi1Error, phiError, phi2Error, stressTensor, gbNormal)

% phiSys = -90, 180, 0
% phiError = 0;
% stressTensor = [1 0 0; 0 0 0; 0 0 0];

[ssa, c_a] = define_SS('Ti','notwin');
nSS = size(ssa,3);  %24

for i = 1:1:24            % Change n & m to unit vector
    n = [ssa(1,1,i)  (ssa(1,2,i)*2+ssa(1,1,i))/sqrt(3)  ssa(1,4,i)/c_a]; % Plane normal /c_a, into a Cartesian coordinate
    m = [ssa(2,1,i)*3/2  (ssa(2,1,i)+ssa(2,2,i)*2)*sqrt(3)/2  ssa(2,4,i)*c_a]; % Slip direction *c_a, into a Cartesian coordinate
    ss(1,:,i) = n/norm(n);  % slip plane, normalized
    ss(2,:,i) = m/norm(m);  % slip direction, normalized
end
mSys1 = [
    cosd(phi1Sys) cosd(phi1Sys-90) 0;
    cosd(phi1Sys+90) cosd(phi1Sys) 0;
    0 0 1];
mSys = [
    1 0 0;
    0 cosd(phiSys) cosd(phiSys-90);
    0 cosd(phiSys+90) cosd(phiSys)];
mSys2 = [
    cosd(phi2Sys) cosd(phi2Sys-90) 0;
    cosd(phi2Sys+90) cosd(phi2Sys) 0;
    0 0 1];

mError1 = [
    cosd(phi1Error) cosd(phi1Error-90) 0;
    cosd(phi1Error+90) cosd(phi1Error) 0;
    0 0 1];
mError = [
    1 0 0;
    0 cosd(phiError) cosd(phiError-90);
    0 cosd(phiError+90) cosd(phiError)];
mError2 = [
    cosd(phi2Error) cosd(phi2Error-90) 0;
    cosd(phi2Error+90) cosd(phi2Error) 0;
    0 0 1];

mPhi1 = [
    cosd(phi1G1) cosd(phi1G1-90) 0;
    cosd(phi1G1+90) cosd(phi1G1) 0;
    0 0 1];
mPhi = [
    1 0 0;
    0 cosd(phiG1) cosd(phiG1-90);
    0 cosd(phiG1+90) cosd(phiG1)];
mPhi2 = [
    cosd(phi2G1) cosd(phi2G1-90) 0;
    cosd(phi2G1+90) cosd(phi2G1) 0;
    0 0 1];
mMatrix = mPhi2*mPhi*mPhi1*mSys2*mSys*mSys1*mError2*mError*mError1;  % g is the 'transformation matrix' defined in continuum mechanics: x=g*X, X is Global corrdinate

% Normalized slip direction and slip plane normal is used to calculate
% schmid factor.  But to calculate resBurgersVector, we need to consider
% that <c+a> slip is longer than <a> slip.
burgersWeight = ones(1,nSS);
burgersWeight(13:24) = burgersWeight(13:24) * sqrt(1+c_a^2);     

for iSS = 1:min(nSS,24)
    slipPlaneG1(iSS,:) = ss(1,:,iSS) * mMatrix;         % for grain 1, [slip plane normal] expressed in Global system
    slipDirectionG1(iSS,:) = ss(2,:,iSS) * mMatrix;     % for grain 1, [slip direction] expressed in Global system
    slipDirectionG1(iSS,:) = slipDirectionG1(iSS,:) * sign(dot(slipDirectionG1(iSS,:), gbNormal));  % This makes the incoming and outgoing burgers vector pointing to the same side of the GB.
    slipDirectionG1W(iSS,:) = slipDirectionG1(iSS,:)*burgersWeight(iSS);
    schmidFactorG1(iSS,1) = abs(slipPlaneG1(iSS,:) * stressTensor * slipDirectionG1(iSS,:)');  % Schimid factor for slip system j
end

%     if nSS > 24
%         for iSS = 25:nSS
%             slipPlaneG1(iSS,:) = ss(1,:,iSS) * mMatrix;         % for grain 1, [slip plane normal] expressed in Global system
%             slipDirectionG1(iSS,:) = ss(2,:,iSS) * mMatrix;     % for grain 1, [slip direction] expressed in Global system
%             schmidFactorG1(iSS,1) =slipPlaneG1(iSS,:) * stressTensor * slipDirectionG1(iSS,:)';  % Schimid factor for TWIN system j
%         end
%     end

%     for iGrain2=1:length(mPrimeStruct.g2{iGrain1})
%         grain2Index = find(mPrimeStruct.g1==mPrimeStruct.g2{iGrain1}(iGrain2));
%         phi1G2 = gPhi1(grain2Index);        % grain 1 phi's
%         phiG2 = gPhi(grain2Index);
%         phi2G2 = gPhi2(grain2Index);
%

mPhi1 = [
    cosd(phi1G2) cosd(phi1G2-90) 0;
    cosd(phi1G2+90) cosd(phi1G2) 0;
    0 0 1];
mPhi = [
    1 0 0;
    0 cosd(phiG2) cosd(phiG2-90);
    0 cosd(phiG2+90) cosd(phiG2)];
mPhi2 = [
    cosd(phi2G2) cosd(phi2G2-90) 0;
    cosd(phi2G2+90) cosd(phi2G2) 0;
    0 0 1];
mMatrix = mPhi2*mPhi*mPhi1*mSys2*mSys*mSys1*mError2*mError*mError1;  % g is the 'transformation matrix' defined in continuum mechanics: x=g*X, X is Global corrdinate

for iSS = 1:min(nSS,24)
    slipPlaneG2(iSS,:) = ss(1,:,iSS) * mMatrix;         % for grain 1, [slip plane normal] expressed in Global system
    slipDirectionG2(iSS,:) = ss(2,:,iSS) * mMatrix;     % for grain 1, [slip direction] expressed in Global system
    slipDirectionG2(iSS,:) = slipDirectionG2(iSS,:) * sign(dot(slipDirectionG2(iSS,:), gbNormal));      % This makes the incoming and outgoing burgers vector pointing to the same side of the GB.
    slipDirectionG2W(iSS,:) = slipDirectionG2(iSS,:)*burgersWeight(iSS);
    schmidFactorG2(iSS,1) = abs(slipPlaneG2(iSS,:) * stressTensor * slipDirectionG2(iSS,:)');  % Schimid factor for slip system j
end
%         if nSS > 24
%             for iSS = 25:nSS
%                 slipPlaneG2(iSS,:) = ss(1,:,iSS) * mMatrix;         % for grain 1, [slip plane normal] expressed in Global system
%                 slipDirectionG2(iSS,:) = ss(2,:,iSS) * mMatrix;     % for grain 1, [slip direction] expressed in Global system
%                 schmidFactorG2(iSS,1) = slipPlaneG2(iSS,:) * stressTensor * slipDirectionG2(iSS,:)';  % Schimid factor for TWIN system j
%             end
%         end

mPrimeMatrix = zeros(nSS,nSS);
resBurgersMatrix = zeros(nSS,nSS);
mPrimeMatrixAbs = zeros(nSS,nSS);
resBurgersMatrixAbs = zeros(nSS,nSS);

sfG1Matrix = repmat(schmidFactorG1,1,nSS);
sfG2Matrix = repmat(schmidFactorG2',nSS,1);
avgSFMatrix = (sfG1Matrix + sfG2Matrix)/2;
for iSSG1 = 1:nSS
    for iSSG2 = 1:nSS
        mPrimeMatrix(iSSG1,iSSG2) = abs(dot(slipPlaneG1(iSSG1,:),slipPlaneG2(iSSG2,:))) * dot(slipDirectionG1(iSSG1,:),slipDirectionG2(iSSG2,:));
        resBurgersMatrix(iSSG1,iSSG2) = norm( slipDirectionG1W(iSSG1,:)-slipDirectionG2W(iSSG2,:) );
        resBurgersMatrixAbs(iSSG1,iSSG2) = min(norm( slipDirectionG1W(iSSG1,:)-slipDirectionG2W(iSSG2,:) ),  norm( slipDirectionG1W(iSSG1,:)+slipDirectionG2W(iSSG2,:) ) );
    end
end
mPrimeMatrixAbs(1:24,1:24) = abs(mPrimeMatrix(1:24,1:24));

