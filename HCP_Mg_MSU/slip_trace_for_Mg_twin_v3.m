% Code modified from and Hongmei's and Prof. Bieler's version      % Zhe Chen 2011-05-06
% This code plots slip trace projected to the X-Y plane of Global Coordinate Systems. Euler angle is ZXZ convention.
% Note: Here I would like to change the Global Coordinate into Exactly the common one, i.e., X is right, Y is up,
% So I add more transformation, i.e., apart from the traditional definition, I further modify g.
% At MSU global is X pointing down.  It seems that at Imadrid it is also X pointing down.


clc;   
clear;

phi_sys = -90;  % angle between EBSD data X axis and common-X-pointing-right X axis
phi_error = 0;  % angle error caused by placing the sample when doing experiment. i.e., rotate EBSD into In-situ SEM image orientation.

euler=[202.968   22.469  175.66];  % Euler angle given by computer programme.  In MSU EB CamScan, Global X is down, Y is right.
SIGMA=[-1,0,0;0,0,0;0,0,0];  % stress state in Global System, be careful of its direction
c_a=1.62;  % c/a for Mg

%  define slip systems, format: [slip PLANE, slip DIRECTION]
% extension twin
ts(:,:,1) = [1 0 -1 2; -1 0 1 1];
ts(:,:,2) = [0 1 -1 2; 0 -1 1 1];
ts(:,:,3) = [-1 1 0 2; 1 -1 0 1];
ts(:,:,4) = [-1 0 1 2; 1 0 -1 1];
ts(:,:,5) = [0 -1 1 2; 0 1 -1 1];
ts(:,:,6) = [1 -1 0 2; -1 1 0 1];
% contraction twin
ts(:,:,7) = [1 0 -1 1; 1 0 -1 -2];
ts(:,:,8) = [0 1 -1 1; 0 1 -1 -2];
ts(:,:,9) = [-1 1 0 1; -1 1 0 -2];
ts(:,:,10) = [-1 0 1 1; -1 0 1 -2];
ts(:,:,11) = [0 -1 1 1; 0 -1 1 -2];
ts(:,:,12) = [1 -1 0 1; 1 -1 0 -2];


phi1=euler(1,1);
PHI=euler(1,2);
phi2=euler(1,3);
g_sys = [
    cosd(phi_sys) cosd(phi_sys-90) 0;
    cosd(phi_sys+90) cosd(phi_sys) 0;
    0 0 1];
g_error = [
    cosd(phi_error) cosd(phi_error-90) 0;
    cosd(phi_error+90) cosd(phi_error) 0;
    0 0 1];
g_phi1 = [
    cosd(phi1) cosd(phi1-90) 0;
    cosd(phi1+90) cosd(phi1) 0;
    0 0 1];
g_PHI = [
    1 0 0;
    0 cosd(PHI) cosd(PHI-90);
    0 cosd(PHI+90) cosd(PHI)];
g_phi2 = [
    cosd(phi2) cosd(phi2-90) 0;
    cosd(phi2+90) cosd(phi2) 0;
    0 0 1];
g = g_phi2*g_PHI*g_phi1*g_sys*g_error;  % g is the 'transformation matrix' defined in continuum mechanics: x=gX, X is global.

for i = 1:1:12            % Change n & m to unit vector
    n = [ts(1,1,i)  (ts(1,2,i)*2+ts(1,1,i))/sqrt(3)  ts(1,4,i)/c_a]; % Plane normal /c_a, into a Cartesian coordinate
    m = [ts(2,1,i)*3/2  (ts(2,1,i)+ts(2,2,i)*2)*sqrt(3)/2  ts(2,4,i)*c_a]; % Slip direction *c_a, into a Cartesian coordinate
    ss(1,:,i) = n/norm(n);  % twin plane, normalized
    ss(2,:,i) = m/norm(m);  % twin direction, normalized
end

for j = 1:1:12
    N = (g.'*ss(1,:,j).').';  % slip plane (i.e., plane normal) expressed in Global system
    M = (g.'*ss(2,:,j).').';  % slip direction expressed in Global system
    burgers_Z(j) = M*[0 0 1].';    % Z-component of burger's vector of slip system j (Percentage of this vector in Z direction)
    schmid_factor(j,1) = N*SIGMA*M.';  % Schimid factor for slip system j
    abs_schmid_factor(j,1) = schmid_factor(j,1);  % used for evaluate rank of SF, used to abs() in slip, for twin, I delete the abs()
    abs_schmid_factor(j,2) = j;
    sliptrace(:,:,j) = cross(N, [0 0 1]);
    sliptrace(:,:,j) = sliptrace(:,:,j)/norm(sliptrace(:,:,j));
    trace_X(:,:,j) = [0, sliptrace(1,1,j)];  % (trace_X(1,2,;), trace_Y(1,2,:)) are coordinate of end of lines starting from origin representing slip traces
    trace_Y(:,:,j) = [0, sliptrace(1,2,j)];
end


Sorted_SF = sortrows (abs_schmid_factor, -1);

for k = 1:1:12
    plot(trace_X(:,:,k), trace_Y(:,:,k));
    axis([-1.25, 1.25, -1.25, 1.25]);
    axis square;
    text(trace_X(1,2,k)*(2+rem(k,7))/7, trace_Y(1,2,k)*(2+rem(k,7))/7, num2str(k));  % here 7 is just a randomly selected number with good effect to separate the labels
    hold on;
end
hold off;




