% calculate symmetry operation's expression in quaternion
% they are:
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



phi1_0 = 100*eps;
phi_0 = 100*eps;
phi2_0 = 100*eps;
% phi1_0 = 0;
% phi_0 = 0;
% phi2_0 = 0;

ii=1;

phi1 = phi1_0;
Mphi1 = [cosd(phi1) sind(phi1) 0; -sind(phi1) cosd(phi1) 0; 0 0 1];

for iphi = 0:180:180;
    phi = phi_0 + iphi;
    Mphi = [1 0 0 ; 0 cosd(phi) sind(phi); 0 -sind(phi) cosd(phi);];
    
    for iphi2 = 0:60:300;
        phi2 = (1-2*iphi/180)*phi2_0 + iphi2;
        Mphi2 = [cosd(phi2) sind(phi2) 0; -sind(phi2) cosd(phi2) 0; 0 0 1];
        M = Mphi2 * Mphi * Mphi1;
        R = M';
        
        if (det(R)-1)<0.000001
            v = [R(2,3)-R(3,2); R(3,1)-R(1,3); R(1,2)-R(2,1)];
            v = v/norm(v);
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
        
        QQQ(ii,:) = angle2quat(phi1/180*pi,phi/180*pi,phi2/180*pi,'zxz');
        
        
        q0 = cosd(thetad/2);
        q1 = sind(thetad/2)*v(1);
        q2 = sind(thetad/2)*v(2);
        q3 = sind(thetad/2)*v(3);
        q = [q0,q1,q2,q3];
        
        Q(ii,:) = q;
        QQ(ii,:) = [phi1,phi,phi2,thetad,v(1),v(2),v(3)];
        ii=ii+1;
        
    end
end

disp(Q);
disp('---');
disp(QQQ);
disp('---');
disp(QQ);
disp('---');


