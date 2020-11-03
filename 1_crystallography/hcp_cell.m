function [] = hcp_cell(varargin)
% use this script to plot hcp cell with selected features.
% 2016-07-27, add error to 1x3 vector.
%
% 2016-12-07, making sure it is indeed [-90 180 0].  I had a wrong
% recognition for a long time.  EBSD detector is A1-up A2-left instead of
% A1-down A2-right which is my wrong impression for a long time.
%
% I also added IMAGING_CONVENTION.  When set to 0, plot using x-right,
% y-up, z-outward. The relationship between SEM and EBSD will be ignored,
% i.e., always assume EBSD is aligned to x-right, y-up, z-outward.
%
% When selected, plot using x-right, y-down, z-inward.
%
% chenzhe 2017-06-05, change SETTING as input.
%
% chenzhe 2017-06-11, add twin system.  But not complete.  Need to double
% check later.
%
% chenzhe, 2017-08-23
% edit: if SETTING = 0, can input a 1x3 vector as varargin to define phi_sys
%
% chenzhe, 2018-03-28.  Currently, 13-24 = 1st order <c+a>, 25-30 = TT.
% 'material' just control the c_a ratio, not the slip systems.
%
% add more options using input parser, inputs are:
% euler ('euler', randi[1x3]), 
% IMAGING_CONVENTION ('imaging_convention', default=1), 
% SETTING ('setting', default=0), 
% system to plot ('ss', default=1)
% material ('material', default='Mg')
% stress state ('stress', default = [1 0 0; 0 0 0; 0 0 0])
% phi_sys ('phi_sys', default = [0 0 0])
% plot plane? ('plotPlane', default = 1)
% plot burgers vector? ('plotBurgers', default = 1)
% plot trace? ('plotTrace', default = 1)

p = inputParser;

addParameter(p,'euler', randi(360,1,3));
addParameter(p,'IMAGING_CONVENTION', 1);
addParameter(p,'SETTING',0);
addParameter(p,'ss',1);
addParameter(p,'material','Mg');
addParameter(p,'stress',[1 0 0; 0 0 0; 0 0 0]);
addParameter(p,'phi_sys',[0 0 0]);

addParameter(p,'plotPlane',1);
addParameter(p,'plotBurgers',1);
addParameter(p,'plotTrace',1);

parse(p,varargin{:});

euler = p.Results.euler;
IMAGING_CONVENTION = p.Results.IMAGING_CONVENTION;
SETTING = p.Results.SETTING;
plotPool = p.Results.ss;
material = p.Results.material;
Stress_State = p.Results.stress;
phi_sys = p.Results.phi_sys;

PLOT_PLANE = p.Results.plotPlane;
PLOT_BURGERS = p.Results.plotBurgers;
PLOT_TRACE = p.Results.plotTrace;

Colors = [1 0 0; 0 0 1; 0 0 0; 0 1 0; 1 0 1];   % 'r', 'b', 'k', 'g', 'm'

ExtensionTwin = 1; 
PyII = double(~logical(ExtensionTwin));
% PLOT_PLANE = 1;
PLOT_CELL = 1;
% PLOT_BURGERS = 1;
% PLOT_TRACE = 1;

% if setting ~=0, ignore input 'phi_sys'
if SETTING == 2
    phi_sys = [-90 180 0];  % UM nominal, UCSB real.
    disp('SETTING=2, ignore input phi_sys');
elseif SETTING == 1
    phi_sys = [90 180 0];   % MSU, UM actual
    disp('SETTING=1, ignore input phi_sys');
elseif SETTING == 0
    phi_sys = phi_sys;
end

phi_error = [0 0 0];
display(['Euler angle in degree: ',num2str(euler)]);
display(['System rotation angle in degree: ',num2str(phi_sys)]);

Stress_State = Stress_State/norm(Stress_State);
sample_normal = [0 0 1];  % sample normal direction. Actually, direction you are interested in, can change this to other.
if strcmpi(material,'Ti')
    c_a = 1.58; % Ti
elseif strcmpi(material,'Mg')
    c_a = 1.62; % Mg
elseif strcmpi(material,'Zr')
    c_a = 1.5925; % Zr
end
nss = 30;

phi1 = euler(1);
PHI = euler(2);
phi2 = euler(3);

g = euler_to_transformation(euler,phi_sys,phi_error);  % g is the 'transformation matrix' of Euler angle set i: x=gX, X is global.

Vertex(1,:) = [2/3 -1/3 -1/3 0];  % coordinates of the 12 points that make up the hexagonal prism
Vertex(2,:) = [1/3 1/3 -2/3 0];   % 6 on the base, then 6 on the top
Vertex(3,:) = [-1/3 2/3 -1/3 0];
Vertex(4,:) = [-2/3 1/3 1/3 0];
Vertex(5,:) = [-1/3 -1/3 2/3 0];
Vertex(6,:) = [1/3 -2/3 1/3 0];
Vertex(7,:) = [2/3 -1/3 -1/3 1];
Vertex(8,:) = [1/3 1/3 -2/3 1];
Vertex(9,:) = [-1/3 2/3 -1/3 1];
Vertex(10,:) = [-2/3 1/3 1/3 1];
Vertex(11,:) = [-1/3 -1/3 2/3 1];
Vertex(12,:) = [1/3 -2/3 1/3 1];
% these are used for extension twins
Vertex(13,:) = [2/3 -1/3 -1/3 1/2];
Vertex(14,:) = [1/3 1/3 -2/3 1/2];
Vertex(15,:) = [-1/3 2/3 -1/3 1/2];
Vertex(16,:) = [-2/3 1/3 1/3 1/2];
Vertex(17,:) = [-1/3 -1/3 2/3 1/2];
Vertex(18,:) = [1/3 -2/3 1/3 1/2];

%  The following construct structure with format:
%
%   Slpsys(1) = struct( ...
%     'number',1, ...  % slip system number
%     'slp_plane',[0 0 0 1], ...  % slip plane normal in 4-index crystal coord
%     'slp_dir',[-2 1 1 0], ...  % slip direction in 4-index crystal coord
%     'n_vertex',6, ...  % number of vertrices used to construct a representative slip plane
%     'plane_index',[1 2 3 4 5 6], ...  % index of vertrices for slip plane
%     'burgers_index',[2 3], ...  % index of the vertrices for burgers vector
%     'cart_plane',[], ...  % slip plane  in 3-index cartesian form
%     'cart_dir',[], ...  % slip direction in 3-index cartesian form
%     'cart_plane_unit',[], ... % converted to unit vector
%     'cart_dir_unit',[], ...
%     'schmid_factor',[], ... % schmid factor
%     'Rot_Plane',[], ... % slip plane rotated to Global coord
%     'Rot_Dir',[], ...  % slip direction rotated to Global coord
%     'Trace',[]);  % slip trace on Global X-Y plane
%
%  Some filed are not defined initially, but will be added as program proceeds

% basal <a>
Slpsys(1) = struct('number',1,'slp_plane',[0 0 0 1],'slp_dir',[2 -1 -1 0],'n_vertex',6,'plane_index',[1 2 3 4 5 6],'burgers_index',[3 2]);
Slpsys(2) = struct('number',2,'slp_plane',[0 0 0 1],'slp_dir',[-1 2 -1 0],'n_vertex',6,'plane_index',[1 2 3 4 5 6],'burgers_index',[1 2]);
Slpsys(3) = struct('number',3,'slp_plane',[0 0 0 1],'slp_dir',[-1 -1 2 0],'n_vertex',6,'plane_index',[1 2 3 4 5 6],'burgers_index',[3 4]);
% prism <a>
Slpsys(4) = struct('number',4,'slp_plane',[0 1 -1 0],'slp_dir',[2 -1 -1 0],'n_vertex',4,'plane_index',[2 3 9 8],'burgers_index',[3 2]);
Slpsys(5) = struct('number',5,'slp_plane',[1 0 -1 0],'slp_dir',[-1 2 -1 0],'n_vertex',4,'plane_index',[1 2 8 7],'burgers_index',[1 2]);
Slpsys(6) = struct('number',6,'slp_plane',[-1 1 0 0],'slp_dir',[-1 -1 2 0],'n_vertex',4,'plane_index',[3 4 10 9],'burgers_index',[3 4]);
% pyramidal <a>
Slpsys(7) = struct('number',7,'slp_plane',[0 1 -1 1],'slp_dir',[2 -1 -1 0],'n_vertex',4,'plane_index',[2 3 10 7],'burgers_index',[3 2]);
Slpsys(8) = struct('number',8,'slp_plane',[1 0 -1 1],'slp_dir',[-1 2 -1 0],'n_vertex',4,'plane_index',[1 2 9 12],'burgers_index',[1 2]);
Slpsys(9) = struct('number',9,'slp_plane',[-1 1 0 1],'slp_dir',[-1 -1 2 0],'n_vertex',4,'plane_index',[3 4 11 8],'burgers_index',[3 4]);
Slpsys(10) = struct('number',10,'slp_plane',[0 -1 1 1],'slp_dir',[2 -1 -1 0],'n_vertex',4,'plane_index',[5 6 7 10],'burgers_index',[5 6]);
Slpsys(11) = struct('number',11,'slp_plane',[-1 0 1 1],'slp_dir',[-1 2 -1 0],'n_vertex',4,'plane_index',[4 5 12 9],'burgers_index',[5 4]);
Slpsys(12) = struct('number',12,'slp_plane',[1 -1 0 1],'slp_dir',[-1 -1 2 0],'n_vertex',4,'plane_index',[6 1 8 11],'burgers_index',[1 6]);
% pyramidal <c+a>
Slpsys(13) = struct('number',13,'slp_plane',[0 1 -1 1],'slp_dir',[-1 -1 2 3],'n_vertex',4,'plane_index',[2 3 10 7],'burgers_index',[3 10]);
Slpsys(14) = struct('number',14,'slp_plane',[0 1 -1 1],'slp_dir',[1 -2 1 3],'n_vertex',4,'plane_index',[2 3 10 7],'burgers_index',[2 7]);
Slpsys(15) = struct('number',15,'slp_plane',[1 0 -1 1],'slp_dir',[-2 1 1 3],'n_vertex',4,'plane_index',[1 2 9 12],'burgers_index',[2 9]);
Slpsys(16) = struct('number',16,'slp_plane',[1 0 -1 1],'slp_dir',[-1 -1 2 3],'n_vertex',4,'plane_index',[1 2 9 12],'burgers_index',[1 12]);
Slpsys(17) = struct('number',17,'slp_plane',[-1 1 0 1],'slp_dir',[1 -2 1 3],'n_vertex',4,'plane_index',[3 4 11 8],'burgers_index',[4 11]);
Slpsys(18) = struct('number',18,'slp_plane',[-1 1 0 1],'slp_dir',[2 -1 -1 3],'n_vertex',4,'plane_index',[3 4 11 8],'burgers_index',[3 8]);
Slpsys(19) = struct('number',19,'slp_plane',[0 -1 1 1],'slp_dir',[1 1 -2 3],'n_vertex',4,'plane_index',[5 6 7 10],'burgers_index',[6 7]);
Slpsys(20) = struct('number',20,'slp_plane',[0 -1 1 1],'slp_dir',[-1 2 -1 3],'n_vertex',4,'plane_index',[5 6 7 10],'burgers_index',[5 10]);
Slpsys(21) = struct('number',21,'slp_plane',[-1 0 1 1],'slp_dir',[2 -1 -1 3],'n_vertex',4,'plane_index',[4 5 12 9],'burgers_index',[5 12]);
Slpsys(22) = struct('number',22,'slp_plane',[-1 0 1 1],'slp_dir',[1 1 -2 3],'n_vertex',4,'plane_index',[4 5 12 9],'burgers_index',[4 9]);
Slpsys(23) = struct('number',23,'slp_plane',[1 -1 0 1],'slp_dir',[-1 2 -1 3],'n_vertex',4,'plane_index',[6 1 8 11],'burgers_index',[1 8]);
Slpsys(24) = struct('number',24,'slp_plane',[1 -1 0 1],'slp_dir',[-2 1 1 3],'n_vertex',4,'plane_index',[6 1 8 11],'burgers_index',[6 11]);
if 1==ExtensionTwin
    Slpsys(25) = struct('number',25,'slp_plane',[1 0 -1 2],'slp_dir',[-1 0 1 1],'n_vertex',6,'plane_index',[1 2 15 10 11 18],'burgers_index',[1 11]);
    Slpsys(26) = struct('number',26,'slp_plane',[0 1 -1 2],'slp_dir',[0 -1 1 1],'n_vertex',6,'plane_index',[2 3 16 11 12 13],'burgers_index',[2 12]);
    Slpsys(27) = struct('number',27,'slp_plane',[-1 1 0 2],'slp_dir',[1 -1 0 1],'n_vertex',6,'plane_index',[3 4 17 12 7 14],'burgers_index',[3 7]);
    Slpsys(28) = struct('number',28,'slp_plane',[-1 0 1 2],'slp_dir',[1 0 -1 1],'n_vertex',6,'plane_index',[4 5 18 7 8 15],'burgers_index',[4 8]);
    Slpsys(29) = struct('number',29,'slp_plane',[0 -1 1 2],'slp_dir',[0 1 -1 1],'n_vertex',6,'plane_index',[5 6 13 8 9 16],'burgers_index',[5 9]);
    Slpsys(30) = struct('number',30,'slp_plane',[1 -1 0 2],'slp_dir',[-1 1 0 1],'n_vertex',6,'plane_index',[6 1 14 9 10 17],'burgers_index',[6 10]);
end
        
slpsys = Slpsys;
local_stress_state = g*Stress_State*g';
for ii = 1:1:size(Vertex,1)
    vertex(ii,:) = [ Vertex(ii,1)*3/2, (Vertex(ii,1)+2*Vertex(ii,2))*sqrt(3)/2, Vertex(ii,4)*c_a];
end
Rot_Vertex = vertex * g;  % get rotated vertex in Global Coord

for ii = 1:1:nss %%%%%%%%%%%%%%%%%%%%%%%%%%%-1
    slpsys(ii).cart_plane = [ slpsys(ii).slp_plane(1), (slpsys(ii).slp_plane(1)+2*slpsys(ii).slp_plane(2))/sqrt(3), slpsys(ii).slp_plane(4)/c_a];
    slpsys(ii).cart_dir = [3*slpsys(ii).slp_dir(1)/2, (slpsys(ii).slp_dir(1)+2*slpsys(ii).slp_dir(2))*sqrt(3)/2, slpsys(ii).slp_dir(4)*c_a];
    slpsys(ii).cart_plane_unit = slpsys(ii).cart_plane/norm(slpsys(ii).cart_plane);
    slpsys(ii).cart_dir_unit = slpsys(ii).cart_dir/norm(slpsys(ii).cart_dir);
    slpsys(ii).schmid_factor = slpsys(ii).cart_plane_unit * local_stress_state * slpsys(ii).cart_dir_unit.';
    slpsys(ii).Rot_Plane = slpsys(ii).cart_plane_unit * g;
    slpsys(ii).Rot_Dir = slpsys(ii).cart_dir_unit * g;
    slpsys(ii).Trace = cross(slpsys(ii).Rot_Plane, [0 0 1]);
    slpsys(ii).Trace = slpsys(ii).Trace/norm(slpsys(ii).Trace);  % If don't want to normalize, delete/comment this line
    abs_SF(ii,1) = ii;
    abs_SF(ii,2) = abs(slpsys(ii).schmid_factor);
    if (1==ExtensionTwin)&&(ii>24)
        abs_SF(ii,2) = slpsys(ii).schmid_factor;
    end
end %%%%%%%%%%%%%%%%%%%%%%%%%%%-1
plot_order = sortrows (abs_SF,-2);  % 1st column is ssnumber, 2nd column is SF descending.

% Determine which two points are invisible.
% This actually only depend on the lowest positioned two points on
% either of the basal planes. (but imaging-Z is into paper, so this is
% actually largest Z coordinate). !!!
% Fact: (1) If point ii has smallest z-coord on basal plane-1, then point ii+6 has smallest z-coord on basal plane-2 (because two planes are parallel)
% (1.2) If the smallest z-coord on a plane is >0, then on the other plane there will be a z-coord < 0.
% (1.3) For the way of definition in this code, a point is invisible only if it has z-coord < 0.
% (2) The point with the smallest z-coord is invisible.
% (3) If a point is invisible, all points on the other basal plane are visible.
% (4) If a point is invisible, on the same basal plane, there is another invisible point (whose z-coord is the 2nd smallest on this basal plane)
% (5) If a point is invisible, all three edges connected to it are invisible.
% Conclusion: two points are invisible.  Don't draw edges from them.
for ii = 1:1:6
    vertex_z_1(ii,:) = [ii,Rot_Vertex(ii,3)];
end
for ii = 7:1:12
    vertex_z_2(ii-6,:) = [ii,Rot_Vertex(ii,3)];     % change 'ii' to 'ii-6', 2015-8-27
end
if IMAGING_CONVENTION==1
    criteria_vertex_1 = sortrows(vertex_z_1,-2);
    criteria_vertex_2 = sortrows(vertex_z_2,-2);
    if criteria_vertex_1(1,2) > criteria_vertex_2(1,2)
        invisible_1 = criteria_vertex_1(1,1);
        invisible_2 = criteria_vertex_1(2,1);
    else
        invisible_1 = criteria_vertex_2(1,1);
        invisible_2 = criteria_vertex_2(2,1);
    end
else
    criteria_vertex_1 = sortrows(vertex_z_1,2);
    criteria_vertex_2 = sortrows(vertex_z_2,2);
    if criteria_vertex_1(1,2) < criteria_vertex_2(1,2)
        invisible_1 = criteria_vertex_1(1,1);
        invisible_2 = criteria_vertex_1(2,1);
    else
        invisible_1 = criteria_vertex_2(1,1);
        invisible_2 = criteria_vertex_2(2,1);
    end
end
% found index (two numbers within 1-12) of invisible vertex

for ii = 1:nss  % select %%%%%%%%%%%%%%%%%%%%%%%%%%%-2
    
    ssn = plot_order(ii,1);  % the number of slip system plotted.
    if ismember(ssn,plotPool)
        figure;
        if IMAGING_CONVENTION == 1
            set(gca,'ydir','reverse','zdir','reverse'); % use this to plot using imaging coord convention
        end
        hold on;
        axis equal;
        axis ([-2 2 -2 2]);
        
        for jj = 1:1:slpsys(ssn).n_vertex
            spx(jj) = Rot_Vertex(slpsys(ssn).plane_index(jj),1);  % slip plane Coord for plot
            spy(jj) = Rot_Vertex(slpsys(ssn).plane_index(jj),2);
            spz(jj) = Rot_Vertex(slpsys(ssn).plane_index(jj),3);
        end
        
        % (1) The following plot slip plane
        if ismember(ssn,plotPool)&&(1==PLOT_PLANE)
            
            % Fill plane
            fill3(spx(1:slpsys(ssn).n_vertex),spy(1:slpsys(ssn).n_vertex),spz(1:slpsys(ssn).n_vertex),[0 0 1],'facealpha',0.4);
            
            % (1.1) Draw slip plane normal vector
            %             plot([Rot_Vertex(slpsys(ssn).plane_index(1),1), Rot_Vertex(slpsys(ssn).plane_index(1),1)+slpsys(ssn).Rot_Plane(1)],[Rot_Vertex(slpsys(ssn).plane_index(1),2), Rot_Vertex(slpsys(ssn).plane_index(1),2)+slpsys(ssn).Rot_Plane(2)],'Linewidth',4,'Color',[0 0 0]);
            
        end
        
        % (2) The following, plot burgers vector. Start point of Burgers vector has circle
        if PLOT_BURGERS
            plot3([Rot_Vertex(slpsys(ssn).burgers_index(1),1),Rot_Vertex(slpsys(ssn).burgers_index(2),1)],[Rot_Vertex(slpsys(ssn).burgers_index(1),2),Rot_Vertex(slpsys(ssn).burgers_index(2),2)],[Rot_Vertex(slpsys(ssn).burgers_index(1),3),Rot_Vertex(slpsys(ssn).burgers_index(2),3)],'Linewidth',4,'Color','m');
            plot3(Rot_Vertex(slpsys(ssn).burgers_index(1),1),Rot_Vertex(slpsys(ssn).burgers_index(1),2),Rot_Vertex(slpsys(ssn).burgers_index(1),3),'.','MarkerSize',36,'Color','m');  % start point of Burgers vector has circle.
        end
        %         plot([Rot_Vertex(slpsys(ssn).burgers_index(1),1),Rot_Vertex(slpsys(ssn).burgers_index(2),1)],[Rot_Vertex(slpsys(ssn).burgers_index(1),2),Rot_Vertex(slpsys(ssn).burgers_index(2),2)],'Linewidth',4,'Color',[0 1 1]);
        %         plot(Rot_Vertex(slpsys(ssn).burgers_index(1),1),Rot_Vertex(slpsys(ssn).burgers_index(1),2),'.','MarkerSize',24,'Color',[0 1 1]);  % start point of Burgers vector has circle.
        
        % (3) The following, plot a line representing slip plane trace direction.
        if PLOT_TRACE
            if ssn>24
                plot([slpsys(ssn).Trace(1),-slpsys(ssn).Trace(1)],[slpsys(ssn).Trace(2),-slpsys(ssn).Trace(2)],'--','Linewidth',2,'Color','m')  % magenta for twin. 
            elseif ssn>12
                plot([slpsys(ssn).Trace(1),-slpsys(ssn).Trace(1)],[slpsys(ssn).Trace(2),-slpsys(ssn).Trace(2)],'--','Linewidth',2,'Color',[0 1 0])  % green for pyramidal <c+a>
            elseif ssn>6
                plot([slpsys(ssn).Trace(1),-slpsys(ssn).Trace(1)],[slpsys(ssn).Trace(2),-slpsys(ssn).Trace(2)],'--','Linewidth',2,'Color',[0 0 0])  % black for pyramidal <a>
            elseif ssn<4
                plot([slpsys(ssn).Trace(1),-slpsys(ssn).Trace(1)],[slpsys(ssn).Trace(2),-slpsys(ssn).Trace(2)],'--','Linewidth',2,'Color',[1 0 0])  % red for basal
            else
                plot([slpsys(ssn).Trace(1),-slpsys(ssn).Trace(1)],[slpsys(ssn).Trace(2),-slpsys(ssn).Trace(2)],'--','Linewidth',2,'Color',[0 0 1])  % blue for prism
            end
        end
        
        % (4) The following, plot the cell.  Invisible ones use dash-line
        for jj = 1:1:6
            if jj ~= invisible_1 && jj ~= invisible_2
                p1 = jj+1-6*(rem(jj,6)==0);     % draw edge-1 on basal plane, if visible
                if p1 ~= invisible_1 && p1 ~= invisible_2
                    plot3([Rot_Vertex(jj,1), Rot_Vertex(p1,1)],[Rot_Vertex(jj,2), Rot_Vertex(p1,2)],[Rot_Vertex(jj,3), Rot_Vertex(p1,3)],'-','Linewidth',2,'Color',[0 0 0]);
                else
                    plot3([Rot_Vertex(jj,1), Rot_Vertex(p1,1)],[Rot_Vertex(jj,2), Rot_Vertex(p1,2)],[Rot_Vertex(jj,3), Rot_Vertex(p1,3)],'--','Linewidth',2,'Color',[0 0 0]);
                end
                %             p2 = jj-1+6*(rem(jj-1,6)==0);   % draw edge-2 on basal plane, if visible
                %             if p2 ~= invisible_1 && p2 ~= invisible_2
                %                 plot([Rot_Vertex(jj,1), Rot_Vertex(p2,1)],[Rot_Vertex(jj,2), Rot_Vertex(p2,2)],'-','Linewidth',2,'Color',[0 0 0]);
                %             end
                p3 = jj+6-12*(jj>6);            % draw edge on prism plane, if visible
                if p3 ~= invisible_1 && p3 ~= invisible_2
                    plot3([Rot_Vertex(jj,1), Rot_Vertex(p3,1)],[Rot_Vertex(jj,2), Rot_Vertex(p3,2)],[Rot_Vertex(jj,3), Rot_Vertex(p3,3)],'-','Linewidth',2,'Color',[0 0 0]);
                else
                    plot3([Rot_Vertex(jj,1), Rot_Vertex(p3,1)],[Rot_Vertex(jj,2), Rot_Vertex(p3,2)],[Rot_Vertex(jj,3), Rot_Vertex(p3,3)],'--','Linewidth',2,'Color',[0 0 0]);
                end
            else
                p1 = jj+1-6*(rem(jj,6)==0);     % draw edge-1 on basal plane, if invisible
                plot3([Rot_Vertex(jj,1), Rot_Vertex(p1,1)],[Rot_Vertex(jj,2), Rot_Vertex(p1,2)],[Rot_Vertex(jj,3), Rot_Vertex(p1,3)],'--','Linewidth',1.5,'Color',[0 0 0]);
                p3 = jj+6-12*(jj>6);            % draw edge on prism plane, if invisible
                plot3([Rot_Vertex(jj,1), Rot_Vertex(p3,1)],[Rot_Vertex(jj,2), Rot_Vertex(p3,2)],[Rot_Vertex(jj,3), Rot_Vertex(p3,3)],'--','Linewidth',1.5,'Color',[0 0 0]);
            end
            %             plot(Rot_Vertex(1,1),Rot_Vertex(1,2),'.','MarkerSize',24,'Color',[0 0 0]);  % Can use this to check which is [100] direction, if needed
        end
        for jj = 7:1:12
            if jj ~= invisible_1 && jj ~= invisible_2
                p1 = jj+1-6*(rem(jj,6)==0);     % draw edge-1 on basal plane, if visible
                if p1 ~= invisible_1 && p1 ~= invisible_2
                    plot3([Rot_Vertex(jj,1), Rot_Vertex(p1,1)],[Rot_Vertex(jj,2), Rot_Vertex(p1,2)],[Rot_Vertex(jj,3), Rot_Vertex(p1,3)],'-','Linewidth',2,'Color',[0 0 0]);
                else
                    plot3([Rot_Vertex(jj,1), Rot_Vertex(p1,1)],[Rot_Vertex(jj,2), Rot_Vertex(p1,2)],[Rot_Vertex(jj,3), Rot_Vertex(p1,3)],'--','Linewidth',2,'Color',[0 0 0]);
                end
            else
                p1 = jj+1-6*(rem(jj,6)==0);     % draw edge-1 on basal plane, if invisible
                plot3([Rot_Vertex(jj,1), Rot_Vertex(p1,1)],[Rot_Vertex(jj,2), Rot_Vertex(p1,2)],[Rot_Vertex(jj,3), Rot_Vertex(p1,3)],'--','Linewidth',1.5,'Color',[0 0 0]);
            end
        end
        plot(0,0,'ko');
        title(['order#' num2str(ii) ' SF=' num2str(slpsys(ssn).schmid_factor)]);
        xlabel(['ss' num2str(ssn) ' n=' mat2str(slpsys(ssn).slp_plane) ' m=' mat2str(slpsys(ssn).slp_dir)])
    end
end %%%%%%%%%%%%%%%%%%%%%%%%%%%-2
hold off;

