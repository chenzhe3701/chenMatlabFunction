% mPrimeStruct = construct_mPrime_structure(neighborStruct, gPhi1, gPhi, gPhi2, ss, phiSys, phiError, stressTensor)
%
% revised to consider twin system.  abs(slipSysSF) but no abs for twinSysSF.
%
% Zhe Chen, 2015-08-24 revised

function mPrimeStruct = construct_mPrime_structure(neighborStruct, gPhi1, gPhi, gPhi2, ss, phiSys, phiError, stressTensor)

mPrimeStruct = neighborStruct;

nSS = size(ss,3);   % number of slip systems
for iGrain1=1:length(mPrimeStruct.g1)
    phi1G1 = gPhi1(iGrain1);        % grain 1 phi's
    phiG1 = gPhi(iGrain1);
    phi2G1 = gPhi2(iGrain1);
    
    mSys = [
        cosd(phiSys) cosd(phiSys-90) 0;
        cosd(phiSys+90) cosd(phiSys) 0;
        0 0 1];
    mError = [
        cosd(phiError(1)) cosd(phiError(1)-90) 0;
        cosd(phiError(1)+90) cosd(phiError(1)) 0;
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
    mMatrix = mPhi2*mPhi*mPhi1*mSys*mError;  % g is the 'transformation matrix' defined in continuum mechanics: x=g*X, X is Global corrdinate
        
    for iSS = 1:min(nSS,24)
        slipPlaneG1(iSS,:) = ss(1,:,iSS) * mMatrix;         % for grain 1, [slip plane normal] expressed in Global system
        slipDirectionG1(iSS,:) = ss(2,:,iSS) * mMatrix;     % for grain 1, [slip direction] expressed in Global system
        schmidFactorG1(iSS,1) = abs(slipPlaneG1(iSS,:) * stressTensor * slipDirectionG1(iSS,:)');  % Schimid factor for slip system j
    end
    
    if nSS > 24
        for iSS = 25:nSS
            slipPlaneG1(iSS,:) = ss(1,:,iSS) * mMatrix;         % for grain 1, [slip plane normal] expressed in Global system
            slipDirectionG1(iSS,:) = ss(2,:,iSS) * mMatrix;     % for grain 1, [slip direction] expressed in Global system
            schmidFactorG1(iSS,1) =slipPlaneG1(iSS,:) * stressTensor * slipDirectionG1(iSS,:)';  % Schimid factor for TWIN system j
        end
    end
    
    for iGrain2=1:length(mPrimeStruct.g2{iGrain1})
        grain2Index = find(mPrimeStruct.g1==mPrimeStruct.g2{iGrain1}(iGrain2));
        phi1G2 = gPhi1(grain2Index);        % grain 1 phi's
        phiG2 = gPhi(grain2Index);
        phi2G2 = gPhi2(grain2Index);
        
        mSys = [
            cosd(phiSys) cosd(phiSys-90) 0;
            cosd(phiSys+90) cosd(phiSys) 0;
            0 0 1];
        mError = [
            cosd(phiError(1)) cosd(phiError(1)-90) 0;
            cosd(phiError(1)+90) cosd(phiError(1)) 0;
            0 0 1];
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
        mMatrix = mPhi2*mPhi*mPhi1*mSys*mError;  % g is the 'transformation matrix' defined in continuum mechanics: x=g*X, X is Global corrdinate
        
        for iSS = 1:min(nSS,24)
            slipPlaneG2(iSS,:) = ss(1,:,iSS) * mMatrix;         % for grain 1, [slip plane normal] expressed in Global system
            slipDirectionG2(iSS,:) = ss(2,:,iSS) * mMatrix;     % for grain 1, [slip direction] expressed in Global system
            schmidFactorG2(iSS,1) = abs(slipPlaneG2(iSS,:) * stressTensor * slipDirectionG2(iSS,:)');  % Schimid factor for slip system j
        end
        if nSS > 24
            for iSS = 25:nSS
                slipPlaneG2(iSS,:) = ss(1,:,iSS) * mMatrix;         % for grain 1, [slip plane normal] expressed in Global system
                slipDirectionG2(iSS,:) = ss(2,:,iSS) * mMatrix;     % for grain 1, [slip direction] expressed in Global system
                schmidFactorG2(iSS,1) = slipPlaneG2(iSS,:) * stressTensor * slipDirectionG2(iSS,:)';  % Schimid factor for TWIN system j
            end
        end
        
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
        
        [~,sortedIndex] = sort(avgSFMatrix(:));         % sort combinations of slip system by average schmid factor
        count = 0;
        indexTemp = 1;
        mPrime3 = 0;
        while count<3 && indexTemp<(nSS*nSS+1)
            if sfG1Matrix(sortedIndex(indexTemp))>0.35 && sfG2Matrix(sortedIndex(indexTemp))>0.35 && mPrimeMatrix(sortedIndex(indexTemp))>0.6;
                count = count + 1;
                mPrime3(count) = mPrimeMatrix(sortedIndex(indexTemp));
            end
            indexTemp = indexTemp+1;
        end
        mPrimeStruct.mP3m{iGrain1}(iGrain2) = mean(mPrime3);
        mPrimeStruct.mPm{iGrain1}(iGrain2) = sum(sum(mPrimeMatrix.*sfG1Matrix.*sfG2Matrix))/sum(sum(sfG1Matrix.*sfG2Matrix));  
    end
end
display('constructed_mPrime_structure');
display(datestr(now));
end

function columnIndex = find_variable_column_from_CSV_grain_file(EBSDfilePath2, EBSDfileName2, varList)

nVariable = size(varList,2);

fid = fopen([EBSDfilePath2, EBSDfileName2],'r');
c=textscan(fid,'%s',30,'delimiter',',');
columnNames=c{1,1};
fclose(fid);
columnIndex = zeros(nVariable,1);

for iVariable=1:nVariable
    columnIndex(iVariable) = find(strcmpi(columnNames,varList{iVariable}));
end
end
