% Zhe Chen, 2016-6-13
% 
% This should work for K&W stage data, because the tensile data only record when
% test is running, thus the time is much shorter than strain gage time,
% so both data sets need to be sectioned, and 'align' time.
% 
% Function: generate [Time, Load, Stress, Displacement, Strain] data,
% by combining information from tensile file, and strain gage reading
% rate of reading is (10pt/s or other) for tensile data. 1pt/s for strain gage data.
% So RATERATIO=10 (or other). 
% 
% Required input data: CSV files:
% 
% tensile data column_1-4: Time(just copy to new data), Load(just copy to new data),
% Elongation(i.e., Displacement), Stress
% 
% strain data column_1-4: Time(space holder for ref.),
% microstrain(space holder for ref.), strain, time
%
% Note: pre-process strain gage data, delete all rows when pausing,
% Align the starting time of each section.

[tensileFileName, tensileFilePath] = uigetfile('*.CSV','choose tensile file.CSV');
[strainFileName, strainFilePath] = uigetfile('*.CSV','choose strain file.CSV');
%%
clear tensileSection;
clear strainSection;
clear newData;
tensileData = csvread([tensileFilePath,tensileFileName],1,0);
strainData = csvread([strainFilePath,strainFileName],1,0);

% Section tensile data, based on label in column 5
nSections = max(tensileData(:,5));
for iSection = 1:nSections
   rowStart(iSection)= find(tensileData(:,5) == iSection, 1, 'first');
   if iSection > 1
       rowEnd(iSection-1) = rowStart(iSection)-1;
   end
   rowEnd(nSections) = size(tensileData,1);
end

for iSection = 1:nSections
    tensileSection{iSection} = tensileData(rowStart(iSection):rowEnd(iSection),:);
end
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

%
% make sure strain data lie within bound set by tensile data.
% If one strain data more, eliminate 1st one.  If two strain data more, eliminate 1st and last one.
% Then, make the 5th column in strainSection filled with stress data, 6th column in strainSection filled with displacement.
% Then, make the 5th column in tensileSection filled with strain data.  Use displacement to interpolate/extrapolate.

for iSection = 1:length(strainSection)
   standardTime = strainSection{iSection}(:,4) - (strainSection{iSection}(1,4)- tensileSection{iSection}(1,1)) ;
   standardStrain = strainSection{iSection}(:,3) ;
   fillStrain = interp1(standardTime, standardStrain, tensileSection{iSection}(:,1), 'linear', 'extrap') ;  % estimate strain based on time-gageStrain data
   newData{iSection} = tensileSection{iSection};
   newData{iSection}(:,5) = fillStrain;
   F = fit( newData{iSection}(:,3), fillStrain, 'poly1');    % fit disp = x, strain = y
end

% fill rest strain based on displacement
for iSection = iSection+1 : length(tensileSection)
    newData{iSection} = tensileSection{iSection};
    newData{iSection}(:,5) = F( newData{iSection}(:,3) );
end

outData = [];
% plot to illustrate
figure;hold on;
for iSection = 1:length(newData)
    plot(newData{iSection}(:,5),newData{iSection}(:,4),'.');
    outData = [outData;newData{iSection}];
end
xlabel('Strain,mm/mm');ylabel('Stress,MPa');title('Strain gage reading');

