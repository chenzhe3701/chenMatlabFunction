% [quaternion,q0,q1,q2,q3] = euler_to_quaternion(phi1,phi,phi2)
% qMat4 is a vector
% q0, q1, q2, q3 are the 4 dimensions of the quaternion
% Later I find this function has a better built-in functin
% [q] = angle2quat(phi1_r,phi_r,phi2_r,'zxz')

% Zhe Chen, 2015-08-23 revised.

function [qMat4,q0,q1,q2,q3] = euler_to_quaternion(phi1,phi,phi2)

mPhi1 = arrayfun(@(x) [cosd(x) cosd(x-90) 0; cosd(x+90) cosd(x) 0; 0 0 1], phi1, 'UniformOutput',false);
mPhi = arrayfun(@(x) [1 0 0; 0 cosd(x) cosd(x-90); 0 cosd(x+90) cosd(x)], phi, 'UniformOutput',false);
mPhi2 = arrayfun(@(x) [cosd(x) cosd(x-90) 0; cosd(x+90) cosd(x) 0; 0 0 1], phi2, 'UniformOutput',false);
RMatrix = cellfun(@(x1,x2,x3) (x1*x2*x3)', mPhi2, mPhi, mPhi1, 'UniformOutput',false);   % g is the 'transformation matrix' defined in continuum mechanics: x=g*X, X is Global corrdinate
quaternion = cellfun(@derotation_to_quaternion, RMatrix, 'uniformOutput', false);
qMat4 = cell2mat(quaternion);
q0 = qMat4(:,1:4:end);
q1 = qMat4(:,2:4:end);
q2 = qMat4(:,3:4:end);
q3 = qMat4(:,4:4:end);
