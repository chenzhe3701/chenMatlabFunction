% chenzhe, 2017-11-21
% adjust colorbar according to the value in M
function [clim,caxis_handle] = ca(M)

clim = quantile(M(:),[0.005, 0.995]);
caxis(gca, [clim(1), clim(2)]);
caxis_handle = colorbar;
% axis equal;

end