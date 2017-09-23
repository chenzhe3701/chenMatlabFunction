% ChenZhe 2015-04-16
% use this function to add this folder and subfolders in the search path
% if default folder does not exist, need to select one
function a = addChenFunction()

a = 'D:\UMich Folder\21 Custom Matlab Tool\chenMatlabFunction\';
if exist(a,'dir')
    addpath(genpath(a));
    disp('added Chen Functions');
else
    disp('select main custom folder')
    a = uigetdir();
    addpath(genpath(a))
end

end