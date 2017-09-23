% q = derotation(rotation_matrix_or_euler_in_degree)
% Note: angle2quat is a better built-in function!
%
% Unit in Degree!!!
% Input the Rotation matrix (A), or Euler angles A=[phi1,phi,phi2] in degree
% q = [q0,q1,q2,q3]
% thetad = rotation angle
% v = rotation axis, v is unit vector
% q0 = cosd(thetad/2); q1 = sind(thetad/2)*v(1); q2 = sind(thetad/2)*v(2); q3 = sind(thetad/2)*v(3);

% Zhe Chen, 2015-08-23 revised

function q = derotation_to_quaternion(rotation_matrix_or_euler_in_degree)

m = size(rotation_matrix_or_euler_in_degree,1);
if m == 3
    R = rotation_matrix_or_euler_in_degree;
elseif m == 1
    phi1 = rotation_matrix_or_euler_in_degree(1);
    phi = rotation_matrix_or_euler_in_degree(2);
    phi2 = rotation_matrix_or_euler_in_degree(3);
    
    Mphi1 = [cosd(phi1) sind(phi1) 0; -sind(phi1) cosd(phi1) 0; 0 0 1];
    Mphi = [1 0 0 ; 0 cosd(phi) sind(phi); 0 -sind(phi) cosd(phi);];
    Mphi2 = [cosd(phi2) sind(phi2) 0; -sind(phi2) cosd(phi2) 0; 0 0 1];
    M = Mphi2 * Mphi * Mphi1;
    R = M.';
else
    return;
end

if (det(R)-1)<0.000001
    v=[R(2,3)-R(3,2); R(3,1)-R(1,3); R(1,2)-R(2,1)];
    v = v/norm(v);          % v has to be unit vector
    c = trace(R)/2-0.5;
    s = (R(2,1)-v(1)*v(2)*(1-c))/v(3);
    thetad = acosd(c);
    if s<0
        thetad = -thetad;
    end
else
    display('det(A) ~= 1')
    v = [NaN;NaN;NaN];
    thetad = NaN;
end

if thetad<0
    v = -v;
    thetad = -thetad;
end

q0 = cosd(thetad/2);
q1 = sind(thetad/2)*v(1);
q2 = sind(thetad/2)*v(2);
q3 = sind(thetad/2)*v(3);
q = [q0,q1,q2,q3];

