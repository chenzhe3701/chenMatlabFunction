% chenzhe 2016-3-17
% convert (XYZ) to (hkil) based on c_a ratio
% (hkil) is the four index-notation for hcp.
% (XYZ) is the plane notation in cartesian coordinate.
% 1/X, 1/Y, 1/Z will be the intersection of the plane to the orthogonal
% coordinate axis. So, its plane normal is also [X,Y,Z]

function hkil = XYZ2hkil(varargin)
if size(varargin{1},2) == 3
    X = varargin{1}(:,1);
    Y = varargin{1}(:,2);
    Z = varargin{1}(:,3);
else
    display('input size wrong! Should be n*3');
end
if size(varargin,2)==2
    c_a = varargin{2};
else
    c_a=1.58;
    display('use c_a=1.58 for Ti');
end

h = X;
k = (sqrt(3)*Y - X)/2;
i = (-1)*(sqrt(3)*Y+X)/2;
l = Z*c_a;
hkil = [h,k,i,l];

end