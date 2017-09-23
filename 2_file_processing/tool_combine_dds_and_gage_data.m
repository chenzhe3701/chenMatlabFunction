% Zhe Chen, 2015-2-5
% This should work for K&W stage data, because the tensile data only record when
% test is running, thus the time is much shorter than strain gage time,
% so both data sets need to be sectioned, and 'align' time.
% Function: generate [Time, Load, Stress, Displacement, Strain] data,
% by combining information from tensile file, and strain gage reading
% rate of reading is (10pt/s or other) for tensile data. 1pt/s for strain gage data.
% So RATERATIO=10 (or other). Required input data: CSV files:
% tensile data column_1-4: Time(just copy to new data), Load(just copy to new data),
% Elongation(i.e., Displacement), Stress
% strain data column_1-4: Time(space holder for ref.),
% microstrain(space holder for ref.), strain, time
%
% Note: pre-process strain gage data, delete all rows when pausing,
% Make sure in DDS tensile data, elongation is monotonic increase.  If not, modify it.

[tensileFileName, tensileFilePath] = uigetfile('*.CSV','choose tensile file.CSV');
[strainFileName, strainFilePath] = uigetfile('*.CSV','choose strain file.CSV');
%%
clear tensileSection;
clear strainSection;
tensileData = csvread([tensileFilePath,tensileFileName],1,0);
strainData = csvread([strainFilePath,strainFileName],1,0);
% Section tensile data
RATERATIO = 1;
sectionThreshold = 3;
iRow = 1;
rowStart = 1;
iLoad = 1;
useDiff = 0;
loadDiff = diff(tensileData(:,2));

while iRow < size(tensileData,1)
    if useDiff     % if change in load is > 1.5 average change of previous two steps, this is a stop
        if loadDiff(iRow) > -10     % This can change, check if necessary !!!
            iRow = iRow + 1;
        else
            rowEnd = iRow;
            tensileSection{iLoad} = tensileData(rowStart:rowEnd,:);
            rowStart = rowEnd + 1;
            iRow = rowStart;
            iLoad = iLoad+1;
        end
        
    else
        if (tensileData(iRow,2) < tensileData(iRow+1,2) + sectionThreshold)
            iRow = iRow+1;
        else
            rowEnd = iRow;
            tensileSection{iLoad} = tensileData(rowStart:rowEnd,:);
            rowStart = rowEnd + 1;
            iRow = rowStart;
            iLoad = iLoad+1;
        end
    end
end
rowEnd = iRow;
tensileSection{iLoad} = tensileData(rowStart:rowEnd,:);
% Section strain data, using time
iRow = 1;
rowStart = 1;
iLoad = 1;
while iRow < size(strainData,1)
    if strainData(iRow,4)+2 > strainData(iRow+1,4)
        iRow = iRow+1;
    else
        rowEnd = iRow;
        strainSection{iLoad} = strainData(rowStart:rowEnd,:);
        rowStart = rowEnd + 1;
        iRow = rowStart;
        iLoad = iLoad+1;
    end
end
rowEnd = iRow;
strainSection{iLoad} = strainData(rowStart:rowEnd,:);

% make sure strain data lie within bound set by tensile data.
% If one strain data more, eliminate 1st one.  If two strain data more, eliminate 1st and last one.
% Then, make the 5th column in strainSection filled with stress data, 6th column in strainSection filled with displacement.
% Then, make the 5th column in tensileSection filled with strain data.  Use displacement to interpolate/extrapolate.
nStrainSection = length(strainSection);
for iLoad = 1:nStrainSection;
    nRowTensile = size(tensileSection{iLoad},1);
    nTensRowTensile = ceil(size(tensileSection{iLoad},1)/RATERATIO);
    nRowStrain = size(strainSection{iLoad},1);
    if nRowStrain == nTensRowTensile + 1
        strainSection{iLoad} = strainSection{iLoad}(2:end,:);
    elseif nRowStrain >= nTensRowTensile + 2
        strainSection{iLoad} = strainSection{iLoad}(2:nTensRowTensile+1,:);
    end
    nRowStrain = size(strainSection{iLoad},1);
    
    if iLoad==1 % for 1st section, match last point.
        indexJump = length(tensileSection{1})-1-RATERATIO*(length(strainSection{1})-1);
        strainSection{iLoad}(1:nRowStrain,5) = tensileSection{iLoad}((1:nRowStrain)*RATERATIO-(RATERATIO-1)+indexJump,4);
        strainSection{iLoad}(1:nRowStrain,6) = tensileSection{iLoad}((1:nRowStrain)*RATERATIO-(RATERATIO-1)+indexJump,3);
    else
        strainSection{iLoad}(1:nRowStrain,5) = tensileSection{iLoad}((1:nRowStrain)*RATERATIO-(RATERATIO-1),4);
        strainSection{iLoad}(1:nRowStrain,6) = tensileSection{iLoad}((1:nRowStrain)*RATERATIO-(RATERATIO-1),3);
    end
    tensileSection{iLoad}(:,5) = interp1(strainSection{iLoad}(:,6),strainSection{iLoad}(:,3),tensileSection{iLoad}(:,3),'linear','extrap');
end
if nStrainSection < length(tensileSection)
    for iLoad = nStrainSection+1 : length(tensileSection)
        tensileSection{iLoad}(:,5) = interp1(strainSection{nStrainSection}(:,6),strainSection{nStrainSection}(:,3),tensileSection{iLoad}(:,3),'linear','extrap');
    end
end

% make new data (which is summarized data)
strainNewData = [];
for iLoad = 1:length(strainSection)
    strainNewData = [strainNewData; strainSection{iLoad}(:,[3,6,5])]; %%%%%% [strain, displacement, stress]
end
tensileNewData = [];
for iLoad = 1:length(tensileSection)
    tensileNewData = [tensileNewData; tensileSection{iLoad}(:,1:5)]; %%%%%% [time, force, displacement, stress, strain]
end
% make strain in tensileNewData increasing only
for iRow=1:size(tensileNewData,1)-1
    if tensileNewData(iRow,5) > tensileNewData(iRow+1,5)
        tensileNewData(iRow+1,5) = tensileNewData(iRow,5);
    end
end

% plot to illustrate
figure;hold;
plot(strainNewData(:,1),strainNewData(:,3),'.');
plot(strainNewData(:,1),strainNewData(:,3));
xlabel('Strain,mm/mm');ylabel('Stress,MPa');title('Strain gage reading');
figure;hold;
plot(tensileNewData(:,5),tensileNewData(:,4),'.');
plot(tensileNewData(:,5),tensileNewData(:,4));
xlabel('Strain,mm/mm');ylabel('Stress,MPa');title('Stress vs. Strain plot')
