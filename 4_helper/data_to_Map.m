% This code is used together with varSelector, whos output is 'outMat', etc
% This code takes outMat, refMat, NR, NC, and put outMat back to points on map
%
% Zhe Chen, 2015-9

function reconstructedMat = data_to_Map(outMat,refMat,NR,NC)

predictedMat = outMat;

nMaps = size(outMat,2);
inds = refMat(:,1);

if nMaps>1
    for ii=1:nMaps
        reconstructedMat{ii} = zeros(NR,NC)*NaN;
        reconstructedMat{ii}(inds) = predictedMat(:,ii);
    end
elseif nMaps == 1
    reconstructedMat = zeros(NR,NC)*NaN;
    reconstructedMat(inds) = predictedMat(:);
end

clear predictedMat;

% myplot(reconstructedMat{5});

end