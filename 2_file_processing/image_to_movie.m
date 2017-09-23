% chenzhe 
%
% 2016-12-23 select folder with images, make into a movie

folder = uigetdir('','select directory')

outputVideo = VideoWriter(fullfile(uigetdir('','select output folder'),'_out_video.avi'));
outputVideo.FrameRate = 1;  % frame per second
open(outputVideo)
%%
fileList = dir([folder,'\*.bmp'])
for ii = 1:length(fileList)
    i_img = imread(fullfile(fileList(ii).folder,fileList(ii).name));
    i_frame(ii) = im2frame(i_img);
    writeVideo(outputVideo,i_img);    
end
close(outputVideo);