% chenzhe, 2017-11-20
% This can be optimized later.
% use image() function to plot value

function [hf,hc] = imgPlot(M, cmin, cmax)
hf = figure;
% M to index
clim = quantile(M(:),[0.005, 0.995]);
if ~exist('cMin','var')
    cmin = clim(1)
    cmax = clim(2)
end

imagesc(M);
hc = colorbar;
caxis([cmin,cmax]);

end