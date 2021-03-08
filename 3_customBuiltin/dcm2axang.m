% Convert dcm to axis-angle representation
% 
% The converstion is:
% dcm->quat, using 'dcm2quat', 
% quat->axang, using 'quat2axang'
% 
% axang = [v1, v2, v3, theta_r]
% v(rotation axis) = [v1, v2, v3] 
% rod(rodrigues vector) = v * tan(theta/2)
%
% chenzhe, 2021-03-08

function [axang, v, thetad, rod] = dcm2axang(M)

% using functions in robotics toolbox
q = dcm2quat(M);
axang = quat2axang(q);
v = [axang(1), axang(2), axang(3)];
theta = axang(4);
thetad = theta/pi*180;
    

% This is an explicit method based on literature, written by myself
% I have checked for random eulers that this gives same result as the above   
method = 'non-explicit';
if strcmpi(method, 'explicit')
    R = M';
    if (det(R)-1)<0.000001
        v = [R(2,3)-R(3,2); R(3,1)-R(1,3); R(1,2)-R(2,1)];
        v = v/norm(v);      % v has to be unit vector
        c = trace(R)/2-0.5;
        s = (R(2,1)-v(1)*v(2)*(1-c))/v(3);
        thetad = acosd(c);
        if s<0
            thetad = -thetad;
        end
    else
        display('det(R) ~= 1')
        v = [NaN;NaN;NaN];
        thetad = NaN;
    end
    
    if thetad<0
        v = -v;
        thetad = -thetad;
    end
    
    theta = thetad/180*pi;
    axang = [v, theta];
end

% Rodrigues vector rho = axis * tan(angle/2)
rod = v * tand(thetad/2);

end