% find local grain IDs based on input ID_matrix, target index, half_window_size
%
% chenzhe, 2017-04-09

function local_ids = find_local_ids(ID,ind,hws)     % hws = half_window_size
[nR,nC] = size(ID);
[iR,iC] = ind2sub([nR,nC],ind);
cols = (-hws:hws) + iC;
cols = cols((cols>=1)&(cols<=nC));
rows = (-hws:hws) + iR;
rows = rows((rows>=1)&(rows<=nR));
local_ids = ID(rows,cols);
local_ids = unique(local_ids(:));
end