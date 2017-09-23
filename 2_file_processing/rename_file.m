% rename_file(postFix,old_str,new_str)
% E.g., rename_file('tif', ' ', '_')
%
% Zhe Chen, 2015-9-9

function rename_file(postFix,old_str,new_str)

folder = uigetdir();
fileStruct = dir([folder,'\*.',postFix]);

for iFiles = 1:length(fileStruct)
   [~,oldName] = fileparts(fileStruct(iFiles).name);
   newName = strrep(oldName, old_str, new_str);
   if ~strcmpi(oldName,newName)
   movefile([folder,'\',oldName,'.',postFix],[folder,'\',newName,'.',postFix],'f');   
   end
end

disp('finished');
