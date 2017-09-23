% 
% use euler angle, crystal symmetry, to calculate misorientation angle
% 
% chenzhe, 2017
function [theta_r, theta_d] = calculate_misorientation_euler_r(euler1_r, euler2_r, CS)
    switch CS
        case {'HCP','hcp','Hcp'}
            [S, ~] = hcp_symmetry();
        case {'FCC','fcc','Fcc'}
            [S, ~] = fcc_symmetry();
    end
    
    q = angle2quat(euler1_r(1), euler1_r(2), euler1_r(3),'zxz');
    Q = angle2quat(euler2_r(1), euler2_r(2), euler2_r(3),'zxz');
    
    delta = quatmultiply(quatconj(q),Q);
    
    for ii = 1:length(S)
        theta_r(ii,:) = quat2axang(quatmultiply(delta,S(ii,:)));        % using function from robotics...ToolBox
    end
    theta_r = theta_r(:,4);
    
    theta_r = min(abs(theta_r));
    theta_d = theta_r/pi*180;

end