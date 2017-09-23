% make images into video
% chenzhe 2016-6-1
folder=uigetdir();
fNames=dir([folder,'/*.tif']);
outputVideo = VideoWriter([folder,'/out.avi']);
outputVideo.FrameRate=2;
open(outputVideo);
for ii=1:15
img=uint8(imread([folder,'/',fNames(ii).name])/256);
writeVideo(outputVideo,img);
end
close(outputVideo);