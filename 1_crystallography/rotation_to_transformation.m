% convert rotation axis=v, angle=theta into transformation matrix M
% function M = rotation_to_transformation(v=[v1,v3,v3], theta_degree)
% chenzhe 2016-6-1

function M = rotation_to_transformation(v,theta)
    v1 = v(1);
    v2 = v(2);
    v3 = v(3);
    R = [v1*v1*(1-cosd(theta))+cosd(theta), v1*v2*(1-cosd(theta))-v3*sind(theta), v1*v3*(1-cosd(theta))+v2*sind(theta);
        v1*v2*(1-cosd(theta))+v3*sind(theta), v2*v2*(1-cosd(theta))+cosd(theta), v2*v3*(1-cosd(theta))-v1*sind(theta);
        v1*v3*(1-cosd(theta))-v2*sind(theta), v2*v3*(1-cosd(theta))+v1*sind(theta), v3*v3*(1-cosd(theta))+cosd(theta)];
    M = R';

end

