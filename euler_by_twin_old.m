% euler_d = euler_by_twin_plane(euler_d,ss,relationType(optional) )
% relationType: (1) reflection in K1
% (2) rotation of 180 degree about eta1
% (3) reflection in plane normal to eta1
% (4) rotation of 180 degree about direction normal to K1
%
% ss = 3x2 vector = [twin plane normal; twin direction]
%
% chenzhe 2016-9-17 notes

function euler_d = euler_by_twin(euler_d,ss,varargin)

if (size(ss,1)==2) && (size(ss,2)==3)
    n = ss(1,:)';
    m = ss(2,:)';
else
    error(-1,'twin plane is a vector in 3D');
end

try 
    euler_d = reshape(euler_d,1,3);
catch
    error(-1,'euler angle is a vector of length=3');
end

n = n/norm(n);
m = m/norm(m);

if isempty(varargin)
    relationType = 4;
else
    relationType = varargin{1};
end

switch relationType
    case 1
        RTwin = eye(3) - 2*(n*n');
        display('Warning, this is reflection !');
    case 2
        RTwin = 2*(m*m')-eye(3);
    case 3
        RTwin = eye(3) - 2*(m*m');
        display('Warning, this is reflection !');
    case 4
        RTwin = 2*(n*n')-eye(3);
end


MTwin = RTwin'; % RTwin is symmetric, so this does not matter

euler = euler_d/180*pi;
M = angle2dcm(euler(1),euler(2),euler(3),'zxz');
M = MTwin*M;
[euler(1),euler(2),euler(3)] = dcm2angle(M,'zxz');
euler_d = euler/pi*180;
