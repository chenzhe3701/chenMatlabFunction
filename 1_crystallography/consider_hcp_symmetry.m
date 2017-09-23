% chenzhe, 2016-6-20
% [eulerd,dcm,quat,rodV,V,thetad] = consider_hcp_symmetry(g)
% input a transformation matrix
% output the [euler,dcm,quat,rodV,V,theta] after considering symmetry
function [eulerd,dcm,quat,rodV,V,thetad] = consider_hcp_symmetry(g)
    [~, m_sym_hcp] = hcp_symmetry();
    for jj=1:12
       dcm = m_sym_hcp(:,:,jj)*g;
       quat(jj,:) = dcm2quat(dcm);
    end
    [~,ind] = max(abs(quat(:,1)));
    
    quat = quat(ind,:);
    rodV = quat(2:4)/quat(1);
    dcm = quat2dcm(quat);
    [a1,a2,a3] = quat2angle(quat,'zxz');
    eulerd = [a1,a2,a3]/pi*180;
    axang = quat2axang(quat);
    V = axang(1:3);
    thetad = axang(4)/pi*180;
end
    