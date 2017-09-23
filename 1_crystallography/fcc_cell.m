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
% chenzhe 2017-06-08, make this work for fcc.

function [] = fcc_cell(euler, IMAGING_CONVENTION, SETTING, sysToPlot)

% IMAGING_CONVENTION = 0;
% SETTING = 2;

% euler = [219.838	35.447	154.54];    % grain 3, dongdi
% euler = [148, 105, 334];    % grain 3, dongdi
% % euler = [199.957	87.838	185.19];    % grain 24, dongdi

PLOT_PLANE = 1;
PLOT_CELL = 1;
PLOT_BURGERS = 1;
PLOT_TRACE = 1;
PLOT_100 = 0;
plotPool = sysToPlot;

if IMAGING_CONVENTION == 0
    % x-right, y-up
end
if SETTING == 2
    phi_sys = [-90 180 0];  % UM nominal
elseif SETTING == 1
    phi_sys = [90 180 0];   % MSU, UM actual
elseif SETTING == 0
    phi_sys = [0 0 0];   % no modification.  no setting match this
end

phi_error = [0 0 0];
display(['Euler angle in degree: ',num2str(euler)]);
display(['System rotation angle in degree: ',num2str(phi_sys)]);

Stress_State = [ 1 0 0; 0 0 0; 0 0 0];
Stress_State = Stress_State/norm(Stress_State);
sample_normal = [0 0 1];  % sample normal direction. Actually, direction you are interested in, can change this to other.
c_a = 1;
nss = 12;

% phi1 = euler(1);
% PHI = euler(2);
% phi2 = euler(3);

g = euler_to_transformation(euler,phi_sys,phi_error);  % g is the 'transformation matrix' of Euler angle set i: x=gX, X is global.

% coordinates of the 8 points that make up the cubic prism
% 1-4 on the bottom, 5-8 on top
Vertex(1,:) = [ 1/2   1/2   0]; 
Vertex(2,:) = [-1/2   1/2   0];
Vertex(3,:) = [-1/2  -1/2   0];
Vertex(4,:) = [ 1/2  -1/2   0];
Vertex(5,:) = [ 1/2   1/2   1];  
Vertex(6,:) = [-1/2   1/2   1];   
Vertex(7,:) = [-1/2  -1/2   1];
Vertex(8,:) = [ 1/2  -1/2   1];

%  The following construct structure with format:
%
%   Slpsys(1) = struct( ...
%     'number',1, ...  % slip system number
%     'slip_plane',[0 0 0 1], ...  % slip plane normal in 4-index crystal coord
%     'slip_dir',[-2 1 1 0], ...  % slip direction in 4-index crystal coord
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

% set-1
Slpsys(1) = struct('number',1,'slip_plane',[1 1 1],'slip_dir',[1 0 -1],'n_vertex',3,'plane_index',[1 6 8],'burgers_index',[6 1]);
Slpsys(2) = struct('number',2,'slip_plane',[1 1 1],'slip_dir',[-1 1 0],'n_vertex',3,'plane_index',[1 6 8],'burgers_index',[8 6]);
Slpsys(3) = struct('number',3,'slip_plane',[1 1 1],'slip_dir',[0 -1 1],'n_vertex',3,'plane_index',[1 6 8],'burgers_index',[1 8]);
% set-2
Slpsys(4) = struct('number',4,'slip_plane',[-1 1 1],'slip_dir',[0 1 -1], 'n_vertex',3,'plane_index',[2 7 5],'burgers_index',[7 2]);
Slpsys(5) = struct('number',5,'slip_plane',[-1 1 1],'slip_dir',[-1 -1 0],'n_vertex',3,'plane_index',[2 7 5],'burgers_index',[5 7]);
Slpsys(6) = struct('number',6,'slip_plane',[-1 1 1],'slip_dir',[1 0 1],  'n_vertex',3,'plane_index',[2 7 5],'burgers_index',[2 5]);
% set-3
Slpsys(7) = struct('number',7,'slip_plane',[-1 -1 1],'slip_dir',[-1 0 -1],'n_vertex',3,'plane_index',[3 8 6],'burgers_index',[8 3]);
Slpsys(8) = struct('number',8,'slip_plane',[-1 -1 1],'slip_dir',[1 -1 0], 'n_vertex',3,'plane_index',[3 8 6],'burgers_index',[6 8]);
Slpsys(9) = struct('number',9,'slip_plane',[-1 -1 1],'slip_dir',[0 1 1],  'n_vertex',3,'plane_index',[3 8 6],'burgers_index',[3 6]);
% set-4
Slpsys(10) = struct('number',10,'slip_plane',[1 -1 1],'slip_dir',[0 -1 -1],'n_vertex',3,'plane_index',[4 5 7],'burgers_index',[5 4]);
Slpsys(11) = struct('number',11,'slip_plane',[1 -1 1],'slip_dir',[1 1 0],  'n_vertex',3,'plane_index',[4 5 7],'burgers_index',[7 5]);
Slpsys(12) = struct('number',12,'slip_plane',[1 -1 1],'slip_dir',[-1 0 1], 'n_vertex',3,'plane_index',[4 5 7],'burgers_index',[4 7]);

slpsys = Slpsys;
local_stress_state = g*Stress_State*g';
vertex = Vertex;
Rot_Vertex = vertex * g;  % get rotated vertex in Global Coord

for ii = 1:1:nss %%%%%%%%%%%%%%%%%%%%%%%%%%%-1
    slpsys(ii).cart_plane = slpsys(ii).slip_plane;
    slpsys(ii).cart_dir = slpsys(ii).slip_dir;
    slpsys(ii).cart_plane_unit = slpsys(ii).cart_plane/norm(slpsys(ii).cart_plane);
    slpsys(ii).cart_dir_unit = slpsys(ii).cart_dir/norm(slpsys(ii).cart_dir);
    slpsys(ii).schmid_factor = slpsys(ii).cart_plane_unit * local_stress_state * slpsys(ii).cart_dir_unit.';
    slpsys(ii).Rot_Plane = slpsys(ii).cart_plane_unit * g;
    slpsys(ii).Rot_Dir = slpsys(ii).cart_dir_unit * g;
    slpsys(ii).Trace = cross(slpsys(ii).Rot_Plane, [0 0 1]);
    slpsys(ii).Trace = slpsys(ii).Trace/norm(slpsys(ii).Trace);  % If don't want to normalize, delete/comment this line
    abs_SF(ii,1) = ii;
    abs_SF(ii,2) = abs(slpsys(ii).schmid_factor);
end %%%%%%%%%%%%%%%%%%%%%%%%%%%-1
plot_order = sortrows (abs_SF,-2);  % 1st column is ssnumber, 2nd column is SF descending.

% Determine which one points are invisible.
% This actually only depend on the lowest positioned one point on
% either of the basal planes. (but if imaging-Z is into paper, this is
% actually largest Z coordinate). !!!
% Fact: (1) If point ii has smallest z-coord on basal plane-1, then point ii+6 has smallest z-coord on basal plane-2 (because two planes are parallel)
% (1.2) If the smallest z-coord on a plane is >0, then on the other plane there will be a z-coord < 0.
% (1.3) For the way of definition in this code, a point is invisible only if it has z-coord < 0.
% (2) The point with the smallest z-coord is invisible.
% (3) If a point is invisible, all points on the other basal plane are visible.
% (4) If a point is invisible, on the same basal plane, there is another invisible point (whose z-coord is the 2nd smallest on this basal plane)
% (5) If a point is invisible, all three edges connected to it are invisible.
% Conclusion: one points are invisible.  Don't draw edges from them.
for ii = 1:1:size(Rot_Vertex,1)
    vertex_z(ii,:) = [ii,Rot_Vertex(ii,3)];
end

if IMAGING_CONVENTION==1
    criteria_vertex = sortrows(vertex_z,-2);
else
    criteria_vertex = sortrows(vertex_z,2);
end
invisible = criteria_vertex(1,1);
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
        axis ([-1.2 1.2 -1.2 1.2]);
        
        for jj = 1:1:slpsys(ssn).n_vertex
            spx(jj) = Rot_Vertex(slpsys(ssn).plane_index(jj),1);  % slip plane Coord for plot
            spy(jj) = Rot_Vertex(slpsys(ssn).plane_index(jj),2);
            spz(jj) = Rot_Vertex(slpsys(ssn).plane_index(jj),3);
        end
        
        % (1) The following plot slip plane
        if ismember(ssn,plotPool)&&(1==PLOT_PLANE)
            
            % Fill plane
            fill3(spx(1:slpsys(ssn).n_vertex),spy(1:slpsys(ssn).n_vertex),spz(1:slpsys(ssn).n_vertex),[0 0 1],'facealpha',0.5);
            
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
            if ssn>9
                plot([slpsys(ssn).Trace(1),-slpsys(ssn).Trace(1)],[slpsys(ssn).Trace(2),-slpsys(ssn).Trace(2)],'--','Linewidth',2,'Color',[0 1 0])  % green for set-4
            elseif ssn>6
                plot([slpsys(ssn).Trace(1),-slpsys(ssn).Trace(1)],[slpsys(ssn).Trace(2),-slpsys(ssn).Trace(2)],'--','Linewidth',2,'Color',[0 0 0])  % black for pyramidal <a>
            elseif ssn>3
                plot([slpsys(ssn).Trace(1),-slpsys(ssn).Trace(1)],[slpsys(ssn).Trace(2),-slpsys(ssn).Trace(2)],'--','Linewidth',2,'Color',[0 0 1])  % blue for basal
            else
                plot([slpsys(ssn).Trace(1),-slpsys(ssn).Trace(1)],[slpsys(ssn).Trace(2),-slpsys(ssn).Trace(2)],'--','Linewidth',2,'Color',[1 0 0])  % red for prism
            end
        end
        
        % (4) The following, plot the cell.  Invisible ones use dash-line
        for jj = 1:1:4
            if jj ~= invisible
                p1 = jj + 1 - 4*floor(jj/4);     % draw edge-1 on 1st plane, if visible
                if p1 ~= invisible
                    plot3([Rot_Vertex(jj,1), Rot_Vertex(p1,1)],[Rot_Vertex(jj,2), Rot_Vertex(p1,2)],[Rot_Vertex(jj,3), Rot_Vertex(p1,3)],'-','Linewidth',2,'Color',[0 0 0]);
                else
                    plot3([Rot_Vertex(jj,1), Rot_Vertex(p1,1)],[Rot_Vertex(jj,2), Rot_Vertex(p1,2)],[Rot_Vertex(jj,3), Rot_Vertex(p1,3)],'--','Linewidth',2,'Color',[0 0 0]);
                end

                p3 = jj + 4;            % draw edge on prism plane, if visible
                if p3 ~= invisible
                    plot3([Rot_Vertex(jj,1), Rot_Vertex(p3,1)],[Rot_Vertex(jj,2), Rot_Vertex(p3,2)],[Rot_Vertex(jj,3), Rot_Vertex(p3,3)],'-','Linewidth',2,'Color',[0 0 0]);
                else
                    plot3([Rot_Vertex(jj,1), Rot_Vertex(p3,1)],[Rot_Vertex(jj,2), Rot_Vertex(p3,2)],[Rot_Vertex(jj,3), Rot_Vertex(p3,3)],'--','Linewidth',2,'Color',[0 0 0]);
                end
            else
                p1 = jj + 1 - 4*floor(jj/4);     % draw edge-1 on 1st plane, if invisible
                plot3([Rot_Vertex(jj,1), Rot_Vertex(p1,1)],[Rot_Vertex(jj,2), Rot_Vertex(p1,2)],[Rot_Vertex(jj,3), Rot_Vertex(p1,3)],'--','Linewidth',1.5,'Color',[0 0 0]);
                p3 = jj + 4;            % draw edge on prism plane, if invisible
                plot3([Rot_Vertex(jj,1), Rot_Vertex(p3,1)],[Rot_Vertex(jj,2), Rot_Vertex(p3,2)],[Rot_Vertex(jj,3), Rot_Vertex(p3,3)],'--','Linewidth',1.5,'Color',[0 0 0]);
            end
            % can check 100 direction
            if 1 == PLOT_100
                plot(Rot_Vertex(1,1)-Rot_Vertex(2,1),Rot_Vertex(1,2)-Rot_Vertex(2,2),'.','MarkerSize',24,'Color',[0 0 0]);  % Can use this to check which is [100] direction, if needed
            end
        end
        for jj = 5:1:8
            if jj ~= invisible
                p1 = jj + 1 - 4*floor(jj/8);     % draw edge-1 on 2nd plane, if visible
                if p1 ~= invisible
                    plot3([Rot_Vertex(jj,1), Rot_Vertex(p1,1)],[Rot_Vertex(jj,2), Rot_Vertex(p1,2)],[Rot_Vertex(jj,3), Rot_Vertex(p1,3)],'-','Linewidth',2,'Color',[0 0 0]);
                else
                    plot3([Rot_Vertex(jj,1), Rot_Vertex(p1,1)],[Rot_Vertex(jj,2), Rot_Vertex(p1,2)],[Rot_Vertex(jj,3), Rot_Vertex(p1,3)],'--','Linewidth',2,'Color',[0 0 0]);
                end
            else
                p1 = jj + 1 - 4*floor(jj/8);      % draw edge-1 on 2nd plane, if invisible
                plot3([Rot_Vertex(jj,1), Rot_Vertex(p1,1)],[Rot_Vertex(jj,2), Rot_Vertex(p1,2)],[Rot_Vertex(jj,3), Rot_Vertex(p1,3)],'--','Linewidth',1.5,'Color',[0 0 0]);
            end
        end
        plot(0,0,'ko');
        title(['order#' num2str(ii) ' SF=' num2str(slpsys(ssn).schmid_factor)]);
        xlabel(['ss' num2str(ssn) ' n=' mat2str(slpsys(ssn).slip_plane) ' m=' mat2str(slpsys(ssn).slip_dir)])
        
    end
end %%%%%%%%%%%%%%%%%%%%%%%%%%%-2
hold off;

