% chenzhe 2016-3-17
% convert [u,v,t,w] to [x,y,z] based on c_a ratio.
% u,v,t,w is the four-index notation in hcp.
% x,y,z is the cartesian notation, axis are orthogonal.

function xyz = uvtw2xyz(varargin)
if size(varargin{1},2) == 4
    u = varargin{1}(:,1);
    v = varargin{1}(:,2);
    t = varargin{1}(:,3);
    w = varargin{1}(:,4);
else
    display('input size wrong! should be n*4.');
end
if size(varargin,2)==2
    c_a = varargin{2};
else
    c_a=1.58;
    display('use c_a=1.58 for Ti');
end

x = 3/2 * u;
y = sqrt(3)/2*(u + 2*v);
z = w * c_a;
xyz = [x,y,z];
end