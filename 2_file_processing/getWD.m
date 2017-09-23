% [ZChen note] Works for images taken in the TESCAN, requiring .hdr files

folderName = uigetdir('','choose the folder');
%%
f1 = 'Ti7Al_#B2_fov_';
f2 = '_stop_';
f3 = '-tif.hdr';
fovNum = {'001','002','003','004','005','006';
    '012','011','010','009','008','007';
    '013','014','015','016','017','018';
    '024','023','022','021','020','019';
    '025','026','027','028','029','030';
    '036','035','034','033','032','031'};
stopNum = {'001','002','003','004','005','006','007','008','009','010'};

for iStop = 1:10
    for iR = 1:6
        for iC = 1:6
            fileName = [f1,fovNum{iR,iC},f2,stopNum{iStop},f3];            
            
            textCell = textread([folderName '\' fileName], '%s');
            
            temp = textCell{strncmpi(textCell,'StageX',6)};
            temp = temp(8:end);
            temp = str2double(temp)*1000; % unit in 'mm'
            stageX(iR,iC,iStop) = temp;
                        
            temp = textCell{strncmpi(textCell,'StageY',6)};
            temp = temp(8:end);
            temp = str2double(temp)*1000; % unit in 'mm'
            stageY(iR,iC,iStop) = temp;
            
            temp = textCell{strncmpi(textCell,'WD',2)};
            temp = temp(4:end);
            temp = str2double(temp)*1000; % unit in 'mm'
            imgWD(iR,iC,iStop) = temp;
        end
    end
end

figure; hold on;
for iStop = 6:10
   surf(stageX(:,:,iStop),stageY(:,:,iStop),WD(:,:,iStop))
end
save('Ti7Al_#B2_WD_data','stageX','stageY','imgWD');
%%
for iStop = 6:10
    meanStageX = mean(stageX(:,:,iStop),1);
    meanWD = mean(imgWD(:,:,iStop),1);
    mdl = fitlm(meanStageX,meanWD);
    slope = mdl.Coefficients.Estimate(2);
    theta = atand(slope)
    %    deltaX = (x+u)*(1/cosd(theta)-1)   % error in deltaXFinal or deltaU
    sind(theta)*tand(theta/2)   % approximate error in exx
end