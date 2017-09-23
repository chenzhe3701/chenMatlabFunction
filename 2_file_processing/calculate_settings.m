% This defines the overlay relationship, ebsdpoint(x,y) * tMatrix = sempoint(x,y)
% start point, we can have: cpSEM, cpEBSD, xColSEM,yRowSEM, xColEBSD,yRowEBSD 
% FOV, xFOV,yFOV, xTransFOV,yTransFOV (fov center position, and translation 

%% SEM -> EBSD
% have cpSEM, cpEBSD
tform = fitgeotrans(cpSEM,cpEBSD,'projective');

% have xColSEM,yRowSEM, the pt marker position ?
input = [xColSEM(:),yRowSEM(:)];
output = transformPointsForward(tform,input);
% calculate xCol_SEMtoEBSD,yRow_SEMtoEBSD, transform pt markers to EBSD position ? 
[nR,nC] = size(xColSEM);
xCol_SEMtoEBSD = round(reshape(output(:,1),nR,nC));
yRow_SEMtoEBSD = round(reshape(output(:,2),nR,nC));
% have xFOV,yFOV, calculate xColSEM_local, yRowSEM_local. This is dependent on image size, so might need change 
[nR,nC] = size(FOV);
xColSEM_local = cell(nR,nC);
yRowSEM_local = cell(nR,nC);
for iR = 1:nR
   for iC = 1:nC
      xColSEM_local{iR,iC} = round(xColSEM(iR:iR+1,iC:iC+1)-xFOV(iR,iC) + 2048); 
      yRowSEM_local{iR,iC} = round(yRowSEM(iR:iR+1,iC:iC+1)-yFOV(iR,iC) + 2048); 
   end
end


%% save
save('Ti7Al#B2_36FOVs_setting',...
    'cpEBSD','cpSEM','ebsdStepSizeTarget','layerDepth',...
    'FOV','xColSEM','yRowSEM','xCol_SEMtoEBSD','yRow_SEMtoEBSD',...
    'xFOV','yFOV','xTransFOV','yTransFOV',...
    'xColSEM_local','yRowSEM_local');