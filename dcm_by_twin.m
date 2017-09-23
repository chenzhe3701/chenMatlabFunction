% [MTwin, RTwin] = dcm_by_twin(ss, relationType(optional))
% relationType: (1) reflection in K1
% (2) rotation of 180 degree about eta1
% (3) reflection in plane normal to eta1
% (4) rotation of 180 degree about direction normal to K1
function [MTwin, RTwin] = dcm_by_twin(ss, varargin)

if (size(ss,1)==2)&&(size(ss,2)==3)
    n = ss(1,:)';
    m = ss(2,:)';
else
    error(-1,'twin plane is a vector in 3D');
end

if isempty(varargin)
    relationType = 4;
else
    relationType = varargin{1};
end

n = n/norm(n);
m = m/norm(m);

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

