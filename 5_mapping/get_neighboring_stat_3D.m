% [gAvgMisoByGb3D, gAvgMisoByVol3D, gAvgNbDiaByGb3D, gAvgNbDiaByVol3D, gMisoStdByGb3D, gMisoStdByVol3D, gNbDiaStdByGb3D, gNbDiaStdByVol3D]...
%     = get_neighboring_stat_3D(structure3D)
%
% grain average misorientation of neighbors weighted by (1) common GB, or (2) neighbors Volume
% grain average neighbors' diameter weighted by (3) common GB, or (4) neighbors volume
% (5)-(8) the Std of (1)-(4)
%
% Zhe Chen, 2015-08-10 revised.

function [gAvgMisoByGb3D, gAvgMisoByVol3D, gAvgNbDiaByGb3D, gAvgNbDiaByVol3D, gMisoStdByGb3D, gMisoStdByVol3D, gNbDiaStdByGb3D, gNbDiaStdByVol3D]...
    = get_neighboring_stat_3D(structure3D)

for ii=1:length(structure3D)    % get gID3D
   gID3D(ii,1) = structure3D(ii).ID; 
end
gAvgMisoByGb3D = zeros(length(gID3D),1)*nan;
gAvgMisoByVol3D = zeros(length(gID3D),1)*nan;
gAvgNbDiaByGb3D = zeros(length(gID3D),1)*nan;
gAvgNbDiaByVol3D = zeros(length(gID3D),1)*nan;
gMisoStdByGb3D = zeros(length(gID3D),1)*nan;
gMisoStdByVol3D = zeros(length(gID3D),1)*nan;
gNbDiaStdByGb3D = zeros(length(gID3D),1)*nan;
gNbDiaStdByVol3D = zeros(length(gID3D),1)*nan;
for iGrain = 1:length(gID3D)
   gAvgMisoByGb3D(iGrain) = dot(structure3D(iGrain).misorientation, structure3D(iGrain).gbArea)/sum(structure3D(iGrain).gbArea(:));     % weighted by gbArea
   gAvgNbDiaByGb3D(iGrain) = dot(structure3D(iGrain).neighborDiameter, structure3D(iGrain).gbArea)/sum(structure3D(iGrain).gbArea(:));
   % gAvgNbDiaByGb3D(iGrain) = (dot(structure3D(iGrain).neighborVolume, structure3D(iGrain).gbArea)/sum(structure3D(iGrain).gbArea(:))/4/pi()*3).^(1/3)*2;   % Another way is to calculate avg volume, then convert to diameter, weighted by gbArea
   gAvgMisoByVol3D(iGrain) = dot(structure3D(iGrain).misorientation, structure3D(iGrain).neighborVolume)/sum(structure3D(iGrain).neighborVolume(:));    %weighted by Vol
   gAvgNbDiaByVol3D(iGrain) = dot(structure3D(iGrain).neighborDiameter, structure3D(iGrain).neighborVolume)/sum(structure3D(iGrain).neighborVolume(:));
   % gAvgNbDiaByVol3D(iGrain) = (dot(structure3D(iGrain).neighborVolume, structure3D(iGrain).neighborVolume)/sum(structure3D(iGrain).neighborVolume(:))/4/pi()*3).^(1/3)*2;   % Another way is to calculate avg volume, then convert to diameter, weighted by Vol

    tempMisoByGbSample = [];
    tempNbDiaByGbSample = [];
    for ii = 1:length(structure3D(iGrain).gbArea)
        if sum(structure3D(iGrain).gbArea)>0   % if sum of gbArea is a number, and >0
            tempMisoByGbSample = [tempMisoByGbSample, ones(1,round(100*structure3D(iGrain).gbArea(ii)/sum(structure3D(iGrain).gbArea))) * structure3D(iGrain).misorientation(ii)];
            tempNbDiaByGbSample = [tempNbDiaByGbSample, ones(1,round(100*structure3D(iGrain).gbArea(ii)/sum(structure3D(iGrain).gbArea))) * structure3D(iGrain).neighborDiameter(ii)];
        end
    end
    gMisoStdByGb3D(iGrain) = std(tempMisoByGbSample);
    gNbDiaStdByGb3D(iGrain) = std(tempNbDiaByGbSample);
    
    tempMisoByVolSample = [];
    tempNbDiaByVolSample = [];
    for ii = 1:length(structure3D(iGrain).neighborVolume)
       if sum(structure3D(iGrain).neighborVolume) > 0
          tempMisoByVolSample = [tempMisoByVolSample, ones(1, round(100*structure3D(iGrain).neighborVolume(ii)/sum(structure3D(iGrain).neighborVolume))) * structure3D(iGrain).misorientation(ii)];
          tempNbDiaByVolSample = [tempNbDiaByVolSample, ones(1, round(100*structure3D(iGrain).neighborVolume(ii)/sum(structure3D(iGrain).neighborVolume))) * structure3D(iGrain).neighborDiameter(ii)];
       end
    end
    gMisoStdByVol3D(iGrain) = std(tempMisoByVolSample);
    gNbDiaStdByVol3D(iGrain) = std(tempNbDiaByVolSample);
end

display('Found avgMisorientation and avgNbDiameters, and Std, weighed by GB/Vol.');
display(datestr(now));
end