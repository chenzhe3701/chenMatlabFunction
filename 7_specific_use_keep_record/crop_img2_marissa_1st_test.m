
start_point = [0 0];

end_point = [6144 4096];
%folder_name='F:\Images';
folder_name=uigetdir('F:\','Choose the parent image folder');

if ~strcmp(folder_name(end), '\')
    folder_name = [folder_name '\'];
end

for iR=0:3
    for iC=0:13
        folder_nameRC = [folder_name,'r',num2str(iR),'c',num2str(iC),'\'];
        save_folder_name = [folder_nameRC,'cropped\'];
        mkdir(save_folder_name);
        
        img_names = dir([folder_nameRC '*.tif']);
        img_names = struct2cell(img_names);
        img_names = img_names(1,:).';
        
        for ii=1:size(img_names,1)
            img = imread([folder_nameRC, img_names{ii}],'tif');
            img = imcrop(img,[start_point, end_point]);
            imwrite(img, [save_folder_name, img_names{ii}],'tif')
        end
        [iR,iC]
    end
    
end