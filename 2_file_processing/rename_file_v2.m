% given a series of files, switch the sequence of parts in filename.
% i.e., change 'stop_1_fov_2' to 'fov_2_stop_1'.
% You can keep a copy of the old file, or it will be moved as a new file.
%
% chenzhe, 2016-08-08

strParts = [];
for ii = 1:9
    strParts{ii} = ['00',num2str(ii)];
end
for ii = 10:36
    strParts{ii} = ['0',num2str(ii)];
end

folder = uigetdir('','select source folder');
folder2 = uigetdir('','select new folder');

for iStop = 1:7
    for iFov = 1:36
        oldName = ['T5_#7_stop_',strParts{iStop},'_fov_',strParts{iFov},'.tif'];
        newName = ['T5_#7_fov_',strParts{iFov},'_stop_',strParts{iStop},'.tif'];
        movefile([folder,'\',oldName],[folder2,'\',newName],'f');
    end
end