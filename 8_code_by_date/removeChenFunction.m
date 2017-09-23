% ChenZhe 2015-04-16
% use this function to add this folder and subfolders in the search path
% if default folder does not exist, need to select one
function []=removeCustomTool()

a = 'D:\UMich Folder\21 Custom Matlab Tool\chenMatlabFunction';
if exist(a,'dir')
    rmpath(genpath(a));
    disp('removed chenFunction folders');
else
    disp('select main custom folder')
    a = uigetdir();
    rmpath(genpath(a));
    disp('removed custom folders');
end

end