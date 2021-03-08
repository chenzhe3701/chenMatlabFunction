% Convert euler angle to rotation axis-angle representation
% 
% The converstion is:
% angle->dcm, using custom function 'angle2dcm',
% dcm->quat, using 'dcm2quat', 
% quat->axang, using 'quat2axang'
% 
% axang = [v1, v2, v3, theta_r]
% v(rotation axis) = [v1, v2, v3] 
% rod(rodrigues vector) = v * tan(theta/2)
%
% chenzhe, 2021-03-08

function [axang, v, thetad, rod] = angle2axang(r1, r2, r3, varargin)

M = angle2dcm(r1, r2, r3, varargin{:});

% using custom function dcm2axang
[axang, rod] = dcm2axang(M);

v = [axang(1),axang(2),axang(3)];
theta = axang(4);
thetad = theta/pi*180;

end