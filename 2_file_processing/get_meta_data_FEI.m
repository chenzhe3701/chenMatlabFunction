% get meta data, and print it into a txt file

directory = uigetdir('','Select a folder that contains all the images');

fileList = dir([directory,'\*.tif']);
for ii = 1:size(fileList,1)
    
    fFolder = fileList(ii).folder;  % redundant
    fName = fileList(ii).name;
    metaDataStruct = imfinfo([fFolder,'\',fName]);
    
    field_DigitalCamera = metaDataStruct.DigitalCamera;
    field_UnknownTags = metaDataStruct.UnknownTags;
    metaDataStruct = rmfield(metaDataStruct,{'DigitalCamera','UnknownTags'});
    
    fieldNames = fieldnames(field_DigitalCamera);
    for jj = 1:length(fieldNames)
        metaDataStruct = setfield(metaDataStruct,['DigitalCamera',fieldNames{jj}],getfield(field_DigitalCamera,fieldNames{jj}));
    end
    
    fieldNames = fieldnames(field_UnknownTags);
    for jj = 1:length(fieldNames)-1
        metaDataStruct = setfield(metaDataStruct,['UnknownTags',fieldNames{jj}],getfield(field_UnknownTags,fieldNames{jj}));
    end
    
    str = field_UnknownTags.Value;  % UnknownTags has a field 'Value', which contains a string with lots of info
    str = strrep(str,char(13),'');  % char(13)+char(10) is a full new line (carriage + new line)
    while ~isempty(str)
        [token, str] = strtok(str,char(10));
        [str1,str2] = strtok(token,'=');
        if ~isempty(str2)
            str2 = str2(2:end);
            metaDataStruct = setfield(metaDataStruct,str1,str2);
        end
    end
    % at this point, metaDataSturct should contain all fields on the top level
    
    % order field
    metaDataStruct = orderfields(metaDataStruct);
    
    % remember, if extract the target field, convert to number, if necessary 
    
end
