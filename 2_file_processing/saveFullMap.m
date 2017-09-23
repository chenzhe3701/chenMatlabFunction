% saveFullMap(M, cMin or [], cMax or [], path or '', colorBarOn(default = 0))
% This function should not be used by a 'coworker'.
% Friend is welcome to use.
% Never mind -- it's the resentment.
% chenzhe, 2017-05-15

function [] = saveFullMap(M,cMin,cMax,path,colorBarOn)
if (~exist('path','var'))||strcmpi(path,'')
    path = 'D:\';
    disp(['No save path provided, using: ',path]);
else
    if strcmp(path(end),'\')~=1
        path = [path,'\'];
    end
    if ~exist(path,'dir')
        mkdir(path);
        disp(['making dir: ', path]);
    end
end
varName = inputname(1);
map = parula;

[nR,nC] = size(M);
R = zeros(nR,nC);
G = zeros(nR,nC);
B = zeros(nR,nC);

N = size(map,1);

% scale
if (~exist('cMin','var'))||(isempty(cMin))
    cpName = varName(1);
    if sum(strcmpi(cpName,{'u','v','U','V'}))>0
        down = quantile(M(:),0.0001);
    else
        down = quantile(M(:),0.03);
    end
    disp(['no lower cLim provided, using: ',num2str(down)]);
else
    down = cMin;
end
if ~exist('cMax','var')||(isempty(cMax))
    if sum(strcmpi(varName,{'u','v','U','V'}))>0
        up = quantile(M(:),0.9999);
    else
        up = quantile(M(:),0.97);
    end
    disp(['no upper cLim provided, using: ',num2str(up)]);
else
    up = cMax;
end

M(M>up) = up;
M(M<down) = down;

% find color index
M = ceil((M-down)/(up-down)*N)+1;
M(isnan(M)) = 1;
map = [1 1 1; map];

R = map(M);
G = map(M+size(map,1));
B = map(M+size(map,1)*2);

I = cat(3,R,G,B);

% generate a colorbar
if exist('colorBarOn','var')
else
    colorBarOn = 0;
    disp('no colorbar output');
end
if colorBarOn==1
    f = figure;
    axis off;
    colormap();
    caxis([down,up]);
    h = colorbar();
    h.Position = [0.2 0.08 0.06 0.83];
    set(get(h,'title'),'string',varName);
    h.FontSize = 16;
    tempDir = 'c:\tempMatLabColorBar\';
    mkdir(tempDir);
    saveas(f,[tempDir,'colorbar.tif']);
    J = imread([tempDir,'colorbar.tif']);
    a = min(find(sum(double(J(:,:,1))-255,1),1,'first') - 10,100);
    b = find(sum(double(J(:,:,1))-255,1),1,'last') + 10;
    b = max(b-a,200);
    J = imcrop(J,[a,0,b,650]);
    J = double(J)/255;
    delete([tempDir,'colorbar.tif']);
    rmdir(tempDir);
    close(f);
    scale = size(I,1)/size(J,1);
    J = imresize(J,scale);
    J = imcrop(J,[0,0,size(J,2),size(I,1)]);
    I = [I,J];
end

% save
imwrite(I,[path,varName,'.tif']);
disp('finished saving image');

end