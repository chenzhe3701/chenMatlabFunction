% ZChen, 2017-2-25 update for error angle = 3 vector
% Zhe Chen, 2016-3-8
% modify to satisfy euler angles for error angle
% function [mPrimeMatrix, schmidFactorG1, schmidFactorG2] = calculate_G1G2_mPrime(phi1G1, phiG1, phi2G1, phi1G2, phiG2, phi2G2,...
% phi1Sys, phiSys, phi2Sys, phiError, stressTensor)
% 
% Zhe Chen, 2016-1-18 
%
% function [mPrimeMatrix, schmidFactorG1, schmidFactorG2] = calculate_G1G2_mPrime(phi1G1, phiG1, phi2G1, phi1G2, phiG2, phi2G2,...
% phiSys, phiError, stressTensor)

function [mPrimeMatrix, schmidFactorG1, schmidFactorG2] = calculate_G1G2_mPrime(phi1G1, phiG1, phi2G1, phi1G2, phiG2, phi2G2, ...
phi1Sys, phiSys, phi2Sys, phi1Error, phiError, phi2Error, stressTensor)

% phiSys = -90;
% phiError = 0;
% stressTensor = [1 0 0; 0 0 0; 0 0 0];
% 
% phi1G1 = 282.59;        % grain 1 phi's, grain 125
% phiG1 = 40.615;
% phi2G1 = 50.67;
% phi1G2 = 215.87;        % grain 1 phi's, grain 136
% phiG2 = 50.514;
% phi2G2 = 116.11;

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

for iSS = 1:min(nSS,24)
    slipPlaneG1(iSS,:) = ss(1,:,iSS) * mMatrix;         % for grain 1, [slip plane normal] expressed in Global system
    slipDirectionG1(iSS,:) = ss(2,:,iSS) * mMatrix;     % for grain 1, [slip direction] expressed in Global system
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

sfG1Matrix = repmat(schmidFactorG1,1,nSS);
sfG2Matrix = repmat(schmidFactorG2',nSS,1);
avgSFMatrix = (sfG1Matrix + sfG2Matrix)/2;
for iSSG1 = 1:nSS
    for iSSG2 = 1:nSS
        mPrimeMatrix(iSSG1,iSSG2) = dot(slipPlaneG1(iSSG1,:),slipPlaneG2(iSSG2,:))*dot(slipDirectionG1(iSSG1,:),slipDirectionG2(iSSG2,:));
    end
end
mPrimeMatrix(1:24,1:24) = abs(mPrimeMatrix(1:24,1:24));

