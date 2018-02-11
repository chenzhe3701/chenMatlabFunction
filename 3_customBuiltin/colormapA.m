% based on built-in colormap()
% make lowest black and highest white
% chenzhe, 2018-02-10

function map = colormapA(mapIn)
if nargin==0
    mapIn = 'default';
end
colormap(mapIn);
map = colormap;
colormap([0 0 0;
    map;
    1 1 1;]);
map = colormap;
end