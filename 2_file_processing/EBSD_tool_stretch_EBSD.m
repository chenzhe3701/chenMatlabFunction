clear;
% control points on undeformed scan
cpTo = [148,86;
796,70;
148,668;
779,654;];
% control points on deformed scan
cpFrom = [85,143;
832,144;
98,717;
816,713;
];
t = maketform('projective',cpFrom,cpTo);

[EBSDfileName1, EBSDfilePath1] = uigetfile('.csv','choose the EBSD file (csv format, from type-1 grain file)');
[EBSDfileName2, EBSDfilePath2] = uigetfile('.csv','choose the EBSD file (csv format, from type-2 grain file)');

% read CSV data
EBSDdata1 = csvread([EBSDfilePath1, EBSDfileName1],1,0);
columnIndex1 = find_variable_column_from_CSV_grain_file(EBSDfilePath1, EBSDfileName1, {'x-um','y-um'});

EBSDdata2 = csvread([EBSDfilePath2, EBSDfileName2],1,0);
columnIndex2 = find_variable_column_from_CSV_grain_file(EBSDfilePath2, EBSDfileName2, {'x-um','y-um'});

% find CSV headers
header1 = find_CSV_header([EBSDfilePath1,EBSDfileName1]);
header2 = find_CSV_header([EBSDfilePath2,EBSDfileName2]);

% stretch CSV grain file type-2 and wrote to file
EBSDdata2(:,[columnIndex2(1),columnIndex2(2)]) = tformfwd(t,EBSDdata2(:,[columnIndex2(1),columnIndex2(2)]));
csvwrite([EBSDfilePath2, strtok(EBSDfileName2,'.'), '-stretched.csv'],EBSDdata2,1,0);
xlswrite([EBSDfilePath2, strtok(EBSDfileName2,'.'), '-stretched.csv'],header2);

% process CSV grain file type-1
XY = EBSDdata1(:,[columnIndex1(1),columnIndex1(2)]);
stretched = tformfwd(t, XY);
for iColumn = 1:size(EBSDdata1,2)
    if (iColumn~=columnIndex1(1))&&(iColumn~=columnIndex1(2))
        F = scatteredInterpolant(stretched,EBSDdata1(:,iColumn),'nearest','none');
        EBSDdata1(:,iColumn) = F(XY);
    end
end
csvwrite([EBSDfilePath1, strtok(EBSDfileName1,'.'), '-stretched.csv'],EBSDdata1,1,0);
xlswrite([EBSDfilePath1, strtok(EBSDfileName1,'.'), '-stretched.csv'],header1);


