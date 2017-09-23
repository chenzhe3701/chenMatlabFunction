% thetad = calculate_misorientation_quaternion_hcp(q, Q)
% 
% q and Q are vectors 1x4 dimension.  they are quaternions.
% thetad is the misorientation in degree.
% The hcp symmetry is considered.
% this is rough but can be faster than using quat2axang

% Zhe Chen, 2015-08-20 revised.

function thetad = calculate_misorientation_quaternion_hcp_rough_legacy(q, Q)
q = quatnormalize(q);
Q = quatnormalize(Q);
% HCP symmetry operation.  Derived from code by varying EulerAngles.  To 
% understand, combine with the cubic_symmetry code, and convert to
% angle-axis pairs for better understanding, and better visualization.
S = [1, 0, 0, 0;
    sqrt(3)/2, 0, 0, 1/2;
    1/2, 0, 0, sqrt(3)/2;
    0, 0, 0, -1;
    1/2, 0, 0, -sqrt(3)/2;
    sqrt(3)/2, 0, 0, -1/2;
    0, 1, 0, 0;
    0, sqrt(3)/2, -1/2, 0;
    0, 1/2, -sqrt(3)/2, 0;
    0, 0, 1, 0;
    0, 1/2, sqrt(3)/2, 0;
    0, sqrt(3)/2, 1/2, 0];

% q = [1, 0, 0, 0];     % these are for initial programming
% Q = [sqrt(3)/2, 0, 0, 0.5000];

% delta = [q*Q', q(1)*Q(2:4) - Q(1)*q(2:4) - cross(q(2:4),Q(2:4))];   % using definition
delta = quatmultiply(quatconj(q),Q);       % using function from aero...toolbox

% method 1: 
for ii = 1:length(S)
    x = delta;
    y = S(ii,:);
    % Delta(ii,:) = [x(1)*y(1)-dot(x(2:4),y(2:4)), x(1)*y(2:4)+x(2:4)*y(1)+cross(x(2:4),y(2:4))];     % using definition
    Delta(ii,:) = quatmultiply(x,y);       % using function from aero...toolbox
end
thetad = 2*acosd( Delta(:,1) );

% % method 2:
% for ii = 1:length(S)
%     thetad(ii,:) = quat2axang(quatmultiply(delta,S(ii,:)));        % using function from robotics...ToolBox
% end
% thetad = thetad(:,4)/pi*180

thetad(thetad>180) = thetad(thetad>180)-360;
thetad = min(abs(thetad));

