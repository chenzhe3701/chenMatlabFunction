% format: slip_trace_Mg(euler, phi_sys, phi_error)
% euler can be: 3 seperate values, or 3x1 vector
% phi_sys: for TSL OIM, default =90.  rotate EBSD Lab system 90 degree, so its x-axis points right
% phi_error: due to misalignment between SEM and EBSD.  If rotate SEM ccw to align with EBSD, phi_error is positive.
% default SIGMA=[1,0,0;0,0,0;0,0,0];  % stress state in Global System, be careful of its direction.  Here tensile axis is horizontal.
% default c_a=1.58;  % c/a for Mg
%
% Zhe Chen, 2015-11-3 revised.

% Code modified from Hongmei's and Prof. Bieler's version      % Zhe Chen 2011-05-06
% This code plots slip trace projected to the X-Y plane of Global Coordinate Systems. Euler angle is ZXZ convention.
% Note: Here I chose a Global Coordinate as the common one, i.e., X is right, Y is up,
% So I add more transformation, i.e., apart from the traditional definition, I further modify g.
% At MSU and IMDEA, EBSD Lab system is X pointing down.
% All the ratatoins are summarized here:
% 1) The Global system is the one in SEM images, x axis point to right.
%    Samples may have been placed slight differently when taking in-situ SEM images and taking EBSD.
%    So, rotate Global system until its x axis points to the right direction in the EBSD map.
% 2) Rotate EBSD map 90 degrees clockwise, then this is the EBSD Lab system.
% 3) Rotate using three Euler angles, then this is the Crystal coordinate system.

function [abs_schmid_factor, Sorted_SF] = trace_analysis_Ti(varargin)

% % default
% phi_sys = -90;  % rotate EBSD Lab system 90 degree, so its x-axis points right
% phi_error = 0;  % angle error caused by placing the sample when doing experiment. i.e., rotate EBSD map into In-situ SEM image orientation.
% % Note 12-10-2013: If you need to rotate SEM image CCW to match EBSD map, then this angle is Positive.
% euler=[30 40 50];  % Euler angle given by EBSD map.  In MSU EB CamScan, EBSD Lab system X is down, Y is right.
SIGMA=[1,0,0;0,0,0;0,0,0];  % stress state in Global System, be careful of its direction.  Here tensile axis is horizontal.
c_a=1.58;  % c/a for Mg

[euler,phi_sys,phi_error,TF] = parse_input(varargin);
euler = euler + ones(size(euler))*100*eps;
if TF
    disp(['Euler = [',num2str(euler(1)),',',num2str(euler(2)),',',num2str(euler(3)),'],  phi_sys = ',num2str(phi_sys),',  phi_error = ',num2str(phi_error)]);
    disp([]);
    
    %  define slip systems, format: [slip PLANE, slip DIRECTION]
    %  basal <a>-glide
    ssa(:,:,1) = [0 0 0 1; -2 1 1 0];
    ssa(:,:,2) = [0 0 0 1; -1 2 -1 0];
    ssa(:,:,3) = [0 0 0 1; -1 -1 2 0];
    
    %  prism <a>-glide
    ssa(:,:,4) = [0 1 -1 0; 2 -1 -1 0];
    ssa(:,:,5) = [1 0 -1 0; 1 -2 1 0];
    ssa(:,:,6) = [-1 1 0 0; 1 1 -2 0];
    
    %  1st order pyramidal<a>-glide
    ssa(:,:,7) = [0 1 -1 1; 2 -1 -1 0];
    ssa(:,:,8) = [1 0 -1 1; 1 -2 1 0];
    ssa(:,:,9) = [-1 1 0 1; 1 1 -2 0];
    ssa(:,:,10) = [0 -1 1 1; -2 1 1 0];
    ssa(:,:,11) = [-1 0 1 1; -1 2 -1 0];
    ssa(:,:,12) = [1 -1 0 1; 1 1 -2 0];
    
    %  1st order pyramidal <c+a>-glide
    ssa(:,:,13) = [0 1 -1 1; -1 -1 2 3];
    ssa(:,:,14) = [0 1 -1 1; 1 -2 1 3];
    ssa(:,:,15) = [1 0 -1 1; -2 1 1 3];
    ssa(:,:,16) = [1 0 -1 1; -1 -1 2 3];
    ssa(:,:,17) = [-1 1 0 1; 1 -2 1 3];
    ssa(:,:,18) = [-1 1 0 1; 2 -1 -1 3];
    ssa(:,:,19) = [0 -1 1 1; 1 1 -2 3];
    ssa(:,:,20) = [0 -1 1 1; -1 2 -1 3];
    ssa(:,:,21) = [-1 0 1 1; 2 -1 -1 3];
    ssa(:,:,22) = [-1 0 1 1; 1 1 -2 3];
    ssa(:,:,23) = [1 -1 0 1; -1 2 -1 3];
    ssa(:,:,24) = [1 -1 0 1; -2 1 1 3];
        
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
    g = g_phi2*g_PHI*g_phi1*g_sys*g_error;  % g is the 'transformation matrix' defined in continuum mechanics: x=gX, X is Global corrdinate
    
    for i = 1:1:24            % Change n & m to unit vector
        n = [ssa(1,1,i)  (ssa(1,2,i)*2+ssa(1,1,i))/sqrt(3)  ssa(1,4,i)/c_a]; % Plane normal /c_a, into a Cartesian coordinate
        m = [ssa(2,1,i)*3/2  (ssa(2,1,i)+ssa(2,2,i)*2)*sqrt(3)/2  ssa(2,4,i)*c_a]; % Slip direction *c_a, into a Cartesian coordinate
        ss(1,:,i) = n/norm(n);  % slip plane, normalized
        ss(2,:,i) = m/norm(m);  % slip direction, normalized
    end
    
    for j = 1:1:24
        N = (g.'*ss(1,:,j).').';  % slip plane (i.e., plane normal) expressed in Global system
        M = (g.'*ss(2,:,j).').';  % slip direction expressed in Global system
        burgers_Z(j) = M*[0 0 1].';    % Z-component of burger's vector of slip system j (Percentage of this vector in Z direction)
        schmid_factor(j,1) = N*SIGMA*M.';  % Schimid factor for slip system j
        abs_schmid_factor(j,1) = j;
        abs_schmid_factor(j,2) = abs(schmid_factor(j,1));  % used to evaluate rank of SF
        sliptrace(:,:,j) = cross(N, [0 0 1]);
        sliptrace(:,:,j) = sliptrace(:,:,j)/norm(sliptrace(:,:,j));
        trace_X(j,:) = [0, sliptrace(1,1,j)];  % (trace_X(1,2,;), trace_Y(1,2,:)) are coordinate of end of lines starting from origin representing slip traces
        trace_Y(j,:) = [0, sliptrace(1,2,j)];
        abs_schmid_factor(j,3) = atand(trace_Y(j,2)/trace_X(j,2));  % angle
        abs_schmid_factor(j,4) = trace_X(j,2);                      % trace_end_X
        abs_schmid_factor(j,5) = trace_Y(j,2);                      % trace_end_y
    end
        
    Sorted_SF = sortrows (abs_schmid_factor, -2);   % sort Schmid Factor: #, SF, angle
    
    if 0
        figure;
        hold on;
        for k = 1:1:24      % Plot traces
            plot(trace_X(k,:), trace_Y(k,:),'k');
            axis([-1.25, 1.25, -1.25, 1.25]);
            axis square;
            text(trace_X(k,2)*(2+rem(k,13))/13, trace_Y(k,2)*(2+rem(k,13))/13, num2str(k));  % here 11 is just a randomly selected number with good effect to separate the labels
        end
        hold off;
        display('schmid factors:');
        disp(Sorted_SF);
    end
    
else
    
end

end

function [euler,phi_sys,phi_error,TF] = parse_input(varargin)
TF = true;
phi_sys = -90;  % rotate EBSD Lab system 90 degree, so its x-axis points right
phi_error = 0;  % angle error caused by placing the sample when doing experiment. i.e., rotate EBSD map into In-situ SEM image orientation.
% Note 12-10-2013: If you need to rotate SEM image CCW to match EBSD map, then this angle is Positive.
euler=[30 40 50];  % Euler angle given by EBSD map.  In MSU EB CamScan, EBSD Lab system X is down, Y is right.
str = 'format: slip_trace_Mg = (euler(3 seperate value, or 3x1 vector),phi_sys(optional),phi_error(optional))';
if isempty(varargin)
    disp(str);
    TF = false;
else
    varargin = varargin{1};
    switch length(varargin)
        case 1                          % get euler
            if length(varargin{1})==3
                euler = varargin{1};
            else
                disp(str);
                TF = false;
            end
        case 2                          % euler, phi_sys
            if length(varargin{1})==3 && length(varargin{2})==1           % get euler and phi_sys
                euler = varargin{1};
                phi_sys = varargin{2};
            else
                disp(str);
                TF = false;
            end
        case 3                          % euler1,euler2,euler3, or euler,phi_sys,phi_error
            if length(varargin{1})==3 && length(varargin{2})==1 && length(varargin{3})==1
                euler = varargin{1};
                phi_sys = varargin{2};
                phi_error = varargin{3};
            elseif length(varargin{1})==1 && length(varargin{2})==1 && length(varargin{3})==1
                euler(1) = varargin{1};
                euler(2) = varargin{2};
                euler(3) = varargin{3};
            else
                disp(str);
                TF = false;
            end
        case 4                          % euler1,euler2,euler3,phy_sys
            if length(varargin{1})==1 && length(varargin{2})==1 && length(varargin{3})==1 && length(varargin{4})==1
                euler(1) = varargin{1};
                euler(2) = varargin{2};
                euler(3) = varargin{3};
                phi_sys = varargin{4};
            else
                disp(str);
                TF = false;
            end
        case 5
            if length(varargin{1})==1 && length(varargin{2})==1 && length(varargin{3})==1 && length(varargin{4})==1 && length(varargin{5})==1
                euler(1) = varargin{1};
                euler(2) = varargin{2};
                euler(3) = varargin{3};
                phi_sys = varargin{4};
                phi_error = varargin{5};
            else
                disp(str);
                TF = false;
            end
    end
end

end
