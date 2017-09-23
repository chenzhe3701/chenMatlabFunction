% calculate quaternion.  checked that the values are the same
for ir = 1:13
    for ic = 1:15
        eulers = [phi1_0(ir,ic),phi_0(ir,ic),phi2_0(ir,ic);
    phi1_a(ir,ic),phi_a(ir,ic),phi2_a(ir,ic);
    phi1_b(ir,ic),phi_b(ir,ic),phi2_b(ir,ic);
    phi1_c(ir,ic),phi_c(ir,ic),phi2_c(ir,ic);
    phi1_d(ir,ic),phi_d(ir,ic),phi2_d(ir,ic);
    phi1_e(ir,ic),phi_e(ir,ic),phi2_e(ir,ic);]/pi*180;

    quat_0(ic*13-13+ir,:) = angle2quat(eulers(1,1),eulers(1,2),eulers(1,3),'zxz');
    quat_a(ic*13-13+ir,:) = angle2quat(eulers(2,1),eulers(2,2),eulers(2,3),'zxz');
    quat_b(ic*13-13+ir,:) = angle2quat(eulers(3,1),eulers(3,2),eulers(3,3),'zxz');
    quat_c(ic*13-13+ir,:) = angle2quat(eulers(4,1),eulers(4,2),eulers(4,3),'zxz');
    quat_d(ic*13-13+ir,:) = angle2quat(eulers(5,1),eulers(5,2),eulers(5,3),'zxz');
    quat_e(ic*13-13+ir,:) = angle2quat(eulers(6,1),eulers(6,2),eulers(6,3),'zxz');
    
    end
end
sum(quat_0~=quat_a)
sum(quat_0~=quat_b)
sum(quat_0~=quat_c)
sum(quat_0~=quat_e)

%% plot small prisms to confirm the euler angles describe the same orientation
for ir = 1:13
    for ic = 1
        eulers = [phi1_0(ir,ic),phi_0(ir,ic),phi2_0(ir,ic);
%     phi1_a(ir,ic),phi_a(ir,ic),phi2_a(ir,ic);
%     phi1_b(ir,ic),phi_b(ir,ic),phi2_b(ir,ic);
%     phi1_c(ir,ic),phi_c(ir,ic),phi2_c(ir,ic);
    phi1_e(ir,ic),phi_e(ir,ic),phi2_e(ir,ic);]/pi*180;
    
    for irc = 1:size(eulers,1)
        if irc==1
            hcp_cell_checkAng(eulers(irc,:),1)
        else
            hcp_cell_checkAng(eulers(irc,:),0)
        end
    end
    
    end
end
