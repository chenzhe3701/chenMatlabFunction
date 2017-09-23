% chenzhe 2016-3-17
% convert (hkil) to (XYZ) based on c_a ratio
% (XYZ) is the plane notation in cartesian coordinate, so its plane normal is
% also [X,Y,Z]

function XYZ = hkil2XYZ(varargin)
if size(varargin{1},2) == 4
    h = varargin{1}(:,1);
    k = varargin{1}(:,2);
    i = varargin{1}(:,3);
    l = varargin{1}(:,4);
else
    display('input size wrong! should be n*4.');
end
if size(varargin,2)==2
    c_a = varargin{2};
else
    c_a=1.58;
    display('use c_a=1.58 for Ti');
end

X = h;
Y = (2*k + h)/sqrt(3);
Z = l/c_a;
XYZ = [X,Y,Z];

end