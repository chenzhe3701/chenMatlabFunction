% numbers = find_numbers_from_name_cell(directory,fileType,lead_str, link_str, end_str)
%
% input names = cell of arrays
% Specify the extension of the file you are interested
% Specify the strings before, after the number you want to extract, specify
% the string used as a link.
% The output are the extracted numbers in the formated strings.
%
% chenzhe, 2016-10-10
%
% Looks like currently, the end_str does not work.  Need to improve.
% chenzhe, 2016-10-16

function numbers = find_numbers_from_folder(directory,fileType,lead_str, link_str, end_str)
numbers = [];

fileNames = dir([directory,'\*.',fileType]);
fileNames = struct2cell(fileNames);
fileNames = fileNames';
fileNames = fileNames(:,1);
    
    
for ii = 1:length(fileNames)
    str = fileNames{ii};
   while ~strncmpi(str,lead_str,length(lead_str))
       [~,str] = strtok(str,link_str);
       str = str(1+length(link_str):end);
   end
   [~,str] = strtok(str,link_str);
   str = str(1+length(link_str):end);

   [n,~] = strtok(str,[link_str,end_str]);
   n = str2num(n);
   numbers = [numbers;n];
end