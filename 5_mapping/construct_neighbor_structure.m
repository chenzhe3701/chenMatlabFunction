% neighborStruct = construct_neighbor_structure(EBSDfilePath2,EBSDfileName2)
% neighborStruct is a structure
% neighborStruct.g1 is a 1 x nn array of grain IDs.
% neighborStruct.g2 is a nn x 1 cell array. 
% Cell g2{ii} contains a row
% vector, which contains g1(ii)'s neighbor grain IDs.
% Zhe Chen, 2015-08-04 revised
%
% chenzhe, 2017-08-31, update so that instead of just being able to read
% '.csv' grain file, the grain file now can be '.txt'
% But now requires functions:
% find_variable_column_from_CSV_grain_file()
% grain_file_read()
% find_variable_column_from_grain_file_header()

function neighborStruct = construct_neighbor_structure(EBSDfilePath2,EBSDfileName2)

if strcmpi(EBSDfileName2(end-3:end),'.csv')
    EBSDdata2 = csvread([EBSDfilePath2, EBSDfileName2],1,0);
    columnIndex = find_variable_column_from_CSV_grain_file(EBSDfilePath2, EBSDfileName2, {'grainId','n-neighbor+id'});
elseif strcmpi(EBSDfileName2(end-3:end),'.txt')
    [EBSDdata2,EBSDheader2] = grain_file_read([EBSDfilePath2, EBSDfileName2]);
    columnIndex = find_variable_column_from_grain_file_header(EBSDheader2, {'grainId','n-neighbor+id'});
end


gID = EBSDdata2(:,columnIndex(1));
g2Column = columnIndex(2);

neighborStruct.g1 = gID;
for ii=1:length(gID)
    neighborStruct.g2{ii} = EBSDdata2(ii,g2Column+1:g2Column+EBSDdata2(ii,g2Column))';      % grain 2 info starting from column index = g2Column+1
end


display('constructed_neighbor_structure');
display(datestr(now));
end
