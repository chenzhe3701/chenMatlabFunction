
function eulerd_out = find_closest_orientation_hcp(eulerd_in, eulerd_ref)
% function eulerd_out = find_closest_orientation_hcp(eulerd_in, eulerd_ref)
%
% amaong the geometrically equivalent orientations of eulerd_in, what is
% the closest orientation to eulerd_ref without considering symmetry.
% chenzhe, 2020-11-08
%
% eulerd_in: input euler angle in degrees, 'zxz' convention
% eulerd_ref: reference direction
% eulerd_out: result

% for debug
% eulerd_ref = [220, 23, 12];
% eulerd_in = [40,158,47];

% hcp symmetry operator in quaternion
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

% convert to radian
euler_ref = eulerd_ref/180*pi;
euler_in = eulerd_in/180*pi;
% convert to quaternion
q_ref = angle2quat(euler_ref(1), euler_ref(2), euler_ref(3), 'zxz');
q_in = angle2quat(euler_in(1), euler_in(2), euler_in(3), 'zxz');

% all symmetrical quaternions of eulerd_in
equivalent_quats_in = quatmultiply(q_in, S);
% misorientation between (1) eulerd_ref and (2) all equivalents of eulerd_in 
delta = quatmultiply(quatconj(q_ref), equivalent_quats_in);
% convert misorientation into axis_angle notation
axis_angle = quat2axang(delta);
% get the misorientation angle, i.e., the 4th element
thetad = axis_angle(:,4)/pi*180;

[~,ind] = min(abs(thetad));

quat_out = quatmultiply(q_in, S(ind,:));
m = quat2dcm(quat_out);
[a,b,c] = dcm2angle(m,'zxz');
euler_out = [a,b,c];
eulerd_out = euler_out/pi*180;
