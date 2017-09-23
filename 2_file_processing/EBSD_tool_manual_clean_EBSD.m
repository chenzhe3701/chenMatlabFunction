clear;
% import grain file, merge fake grains, then save a new grain file (CSV format)
[EBSDfileName1, EBSDfilePath1] = uigetfile('.csv','choose the EBSD file (csv format, from type-1 grain file)');
[EBSDfileName2, EBSDfilePath2] = uigetfile('.csv','choose the EBSD file (csv format, from type-2 grain file)');
mergePair = [17,7;
20,23;
18,24;
34,25;
32,35;
36,35;
49,42;
59,42;
77,44;
64,62;
88,62;
79,65;
72,69;
80,76;
89,91;
103,94;
107,94;
101,99;
106,110;
114,111;
121,111;
125,111;
124,111;
126,111;
133,134;
160,144;
156,144;
187,173;
190,175;
178,177;
183,180;
204,188;
203,192;
210,192;
191,192;
196,192;
200,192;
199,192;
207,192;
226,215;
223,229;
228,229;
241,231;
250,231;
257,254;
261,262;
266,262;
265,281;
267,281;
271,281;
272,281;
273,281;
275,281;
277,281;
279,281;
270,281;
276,281;
285,281;
307,302;
319,311;
317,316;
318,316;
]; % [fake grain id, real grain id]

% find Header for CSV file-1 and -2
header1 = find_CSV_header([EBSDfilePath1,EBSDfileName1]);
header2 = find_CSV_header([EBSDfilePath2,EBSDfileName2]);

% read CSV data
EBSDdata1 = csvread([EBSDfilePath1, EBSDfileName1],1,0);
columnIndex1 = find_variable_column_from_CSV_grain_file(EBSDfilePath1, EBSDfileName1, {'grain-Id','phi1-r','phi-r','phi2-r','x-um','y-um'});

EBSDdata2 = csvread([EBSDfilePath2, EBSDfileName2],1,0);
columnIndex2 = find_variable_column_from_CSV_grain_file(EBSDfilePath2, EBSDfileName2,...
    {'grainId','phi1-d','phi-d','phi2-d','x-um','y-um','n-meas','area-umum','grain-dia-um','n-neighbor+id','edge'});
% plot to check
figure;
nX = length(unique(EBSDdata1(:,4)));
nY = length(unique(EBSDdata1(:,5)));
xTemp = reshape(EBSDdata1(:,4),nX,nY)';
yTemp = reshape(EBSDdata1(:,5),nX,nY)';
idTemp = reshape(EBSDdata1(:,9),nX,nY)';
surf(xTemp,yTemp,idTemp,'edgecolor','none');
set(gca,'yDir','reverse');
colorbar;
view(0,90);
%%
% edit type-1 file, change euler-angles, and grain-ID
for iPair = 1:size(mergePair,1)
    rowIndex1 = EBSDdata1(:,columnIndex1(1))==mergePair(iPair,1);   % logical array, indication old grain in file 1
    rowIndex2 = EBSDdata2(:,columnIndex2(1))==mergePair(iPair,2);   % logical array, indicating new grain in file 2
    EBSDdata1(rowIndex1,columnIndex1(1)) = EBSDdata2(rowIndex2,columnIndex2(1));
    EBSDdata1(rowIndex1,columnIndex1(2)) = EBSDdata2(rowIndex2,columnIndex2(2))/180*pi();
    EBSDdata1(rowIndex1,columnIndex1(3)) = EBSDdata2(rowIndex2,columnIndex2(3))/180*pi();
    EBSDdata1(rowIndex1,columnIndex1(4)) = EBSDdata2(rowIndex2,columnIndex2(4))/180*pi();
end
% write to modified CSV grain file type-1
csvwrite([EBSDfilePath1, strtok(EBSDfileName1,'.'), '-manual cleaned.csv'],EBSDdata1,1,0);
xlswrite([EBSDfilePath1, strtok(EBSDfileName1,'.'), '-manual cleaned.csv'],header1);

% edit type-2 file.  For grains to be merged, just delete it.  For grains to be merged in, edit (1) x-um, (2) y-um, (3) n-meas, (4) area-umum, (5) grain-dia-um, (6) n-neighbor+id, (7) edge
[nRow,nColumn] = size(EBSDdata2);
for iPair = 1:size(mergePair,1)
    rowIndex1g2 = EBSDdata1(:,columnIndex1(1)) == mergePair(iPair,2);     % logical array with many True, indicating new grain in file 1
    rowIndex2g2 = EBSDdata2(:,columnIndex2(1)) == mergePair(iPair,2);     % logical array with one True, indicating new grain in file 2
    EBSDdata2(rowIndex2g2,columnIndex2(5)) = mean(EBSDdata1(rowIndex1g2,columnIndex1(5)));      % recalculate grain center
    EBSDdata2(rowIndex2g2,columnIndex2(6)) = mean(EBSDdata1(rowIndex1g2,columnIndex1(6)));
    
    areaToNumber = EBSDdata2(1,columnIndex2(8))/EBSDdata2(1,columnIndex2(7));   % areaToNumber = area/# of measurements
    EBSDdata2(rowIndex2g2,columnIndex2(7)) = sum(rowIndex1g2);              % recalculate n-meas, area, and grain diameter
    EBSDdata2(rowIndex2g2,columnIndex2(8)) = EBSDdata2(rowIndex2g2,columnIndex2(7))*areaToNumber;   
    EBSDdata2(rowIndex2g2,columnIndex2(9)) = sqrt(EBSDdata2(rowIndex2g2,columnIndex2(8))*4/pi());
    
    % if make merge grain-A into grain-B: (1) add grain-A's neighbor into grain-B's neighbor (2) all grain-B's neighbor now has grain-A as neighbor instead of grain-B
    % the following finish (1) edit above
    rowIndex2g1 = EBSDdata2(:,columnIndex2(1))==mergePair(iPair,1);     % in type-2 file, grain-1 (old grain) rowIndex
    EBSDdata2(rowIndex2g2,columnIndex2(11)) = max(EBSDdata2(rowIndex2g2,columnIndex2(11)), EBSDdata2(rowIndex2g1,columnIndex2(11)));    % edge grain? change!
    grain1Neighbors = EBSDdata2(rowIndex2g1,(columnIndex2(10)+1):nColumn);
    grain2Neighbors = EBSDdata2(rowIndex2g2,(columnIndex2(10)+1):nColumn);
    newNeighbors = [grain1Neighbors,grain2Neighbors];
    newNeighbors(newNeighbors==mergePair(iPair,1))=[];      % delete redundant grain IDs
    newNeighbors(newNeighbors==mergePair(iPair,2))=[];
    newNeighbors(newNeighbors==0)=[];
    newNeighbors = unique(newNeighbors);
    nNewNeighbors = length(newNeighbors);
    if nNewNeighbors > nColumn-columnIndex2(10)
        EBSDdata2(:,(nColumn+1):(columnIndex2(10)+nNewNeighbors))=0;
        nColumn = columnIndex2(10) + nNewNeighbors;
    end
    EBSDdata2(rowIndex2g2,columnIndex2(10)) = nNewNeighbors;
    EBSDdata2(rowIndex2g2,(columnIndex2(10)+1):nColumn)=0;  % clear this part before writing new data
    EBSDdata2(rowIndex2g2,(columnIndex2(10)+1):(columnIndex2(10)+length(newNeighbors)))=newNeighbors;
    % the following finish (2) edit above
    for iRow = 1:nRow
        neighbors = EBSDdata2(iRow,(columnIndex2(10)+1):nColumn);
        neighbors(neighbors == mergePair(iPair,1))=mergePair(iPair,2);
        EBSDdata2(iRow,(columnIndex2(10)+1):nColumn)=0;
        neighbors = neighbors(neighbors ~= 0);
        neighbors = unique(neighbors);
        lengthNeighbors = length(neighbors);
        EBSDdata2(iRow,columnIndex2(10))=lengthNeighbors;
        EBSDdata2(iRow,(columnIndex2(10)+1):(columnIndex2(10)+lengthNeighbors)) = neighbors;
    end
end
for iPair = 1:size(mergePair,1)
    EBSDdata2(EBSDdata2(:,columnIndex2(1))==mergePair(iPair,1),:)=[];
end
% write to modified CSV grain file type-2
csvwrite([EBSDfilePath2, strtok(EBSDfileName2,'.'), '-manual cleaned.csv'],EBSDdata2,1,0);
xlswrite([EBSDfilePath2, strtok(EBSDfileName2,'.'), '-manual cleaned.csv'],header2);


% plot to check
figure;
nX = length(unique(EBSDdata1(:,columnIndex1(5))));
nY = length(unique(EBSDdata1(:,columnIndex1(6))));
xTemp = reshape(EBSDdata1(:,columnIndex1(5)),nX,nY)';
yTemp = reshape(EBSDdata1(:,columnIndex1(6)),nX,nY)';
idTemp = reshape(EBSDdata1(:,columnIndex1(1)),nX,nY)';
surf(xTemp,yTemp,idTemp,'edgecolor','none');
set(gca,'yDir','reverse');
colorbar;
view(0,90);