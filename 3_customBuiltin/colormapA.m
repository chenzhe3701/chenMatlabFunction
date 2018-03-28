% based on built-in colormap()
% make lowest black and highest white
% chenzhe, 2018-02-10

function map = colormapA(mapIn)
if nargin==0
    mL = winter(32);
    mL = mL(32:-1:1,:);
    mH = autumn(32);
    mH = mH(1:32,:);
    mapIn = [mL;mH];    
end
colormap(mapIn);
map = colormap;
colormap([0 0 0;
    map;
    1 1 1;]);
map = colormap;
end