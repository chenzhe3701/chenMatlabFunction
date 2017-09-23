% chenzhe 2016-3-17
% convert [x,y,z] to [u,v,t,w] based on c_a ratio
% u,v,t,w is the four-index notation in hcp.
% x,y,z is the cartesian notation, axis are orthogonal.

function uvtw = xyz2uvtw(varargin)
if size(varargin{1},2) == 3
    x = varargin{1}(:,1);
    y = varargin{1}(:,2);
    z = varargin{1}(:,3);
else
    display('input size wrong! Should be n*3');
end
if size(varargin,2)==2
    c_a = varargin{2};
else
    c_a=1.58;
    display('use c_a=1.58 for Ti');
end



u = 2*x/3;
v = y/sqrt(3)-x/3;
w = z/c_a;
t = -u-v;
uvtw = [u,v,t,w];
end