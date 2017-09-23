% given a series of files, switch the sequence of parts in filename.
% i.e., change 'stop_1_fov_2' to 'fov_2_stop_1'.
% You can keep a copy of the old file, or it will be moved as a new file.
%
% chenzhe, 2016-08-08

strParts = [];
SE = make_FOV_string(0,4,0,26,1,'raster')
RC = make_FOV_string(0,4,0,26,1,'rc')
fileNamePrefix = 'WE43_T6_C1_'
fmt = '.ang'

folder = uigetdir('','select source folder');
folder2 = uigetdir('','select new folder');

for ii = 1:length(SE(:))
    
        oldName = [fileNamePrefix,RC{ii},fmt];
        newName = [fileNamePrefix,SE{ii},fmt];
        copyfile([folder,'\',oldName],[folder2,'\',newName],'f');
    
end