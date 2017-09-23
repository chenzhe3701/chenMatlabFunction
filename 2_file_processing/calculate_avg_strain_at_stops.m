% chenzhe 2016-10-11
% choose the folder which contains the DIC files, calculate the avg strain:
% [exx, exy, eyy, eeffective] at each stop

directory = uigetdir('','find the folder that contains the merged DIC file');
fileNames = dir([directory,'\*.mat']);
fileNames = struct2cell(fileNames);
fileNames = fileNames';
fileNames = fileNames(:,1);
strain = [];
for iFile = 1:length(fileNames)
    load([directory,'\',fileNames{iFile}],'exx','exy','eyy','sigma');
    ind = (sigma==-1);
    exx(ind) = NaN;
    exy(ind) = NaN;
    eyy(ind) = NaN;
    eeff = sqrt(2/3*(exx.^2+2*exy.^2+eyy.^2));
    exx = exx(~isnan(exx));
    exy = exy(~isnan(exy));
    eyy = eyy(~isnan(eyy));
    eeff = eeff(~isnan(eeff));
    strain = [strain; nanmean(exx(:)),nanmean(exy(:)),nanmean(eyy(:)),nanmean(eeff(:))];
end
strain