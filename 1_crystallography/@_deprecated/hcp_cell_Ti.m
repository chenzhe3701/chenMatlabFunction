% chenzhe, 2016-4-4
% for some reason, slip system 19-24 the slip direction was wrong, so that
% the first 3 index were inversed and they are not on the slip plane.  So
% the calculated SF can > 0.5 for uniaxial tension.  It is now corrected.
%
% chenzhe, 2016-3-17 revise
% Input euler angles, as 3 angles, or as vector, or nothing to use a
% default one as demo.
%
% Zhe Chen, 2016-2-15, change this code to matching OIM setting-2.  The
% system is still for Mg, this has to be changed.  Currently I don't have
% time.
% Zhe Chen, 2015-10-30 added parse input function, so you can change phy_error.
% Zhe Chen, 2015-8-27 revised.

%  From Old codes in MSU:
%  The first part of this code, is to plot a inverse pole figure, i.e., the sample normal direction projected in the crystal's coordinate system.
%  The second part is to draw unit cells.
%  Note: for different c_a ratio, the same point in IPF represents diffrent crystallographic direction.
%  Don't considers the position of the poles to be propotional...
%  Zhe Chen, rewritten based on the structure built by Hongmei & Dr. Bieler
%  Modified to have 18 slip systems shown.  Only 12 is used in current analysis.
%  2011-08-25


function [] = hcp_cell_Ti(varargin)

[Euler(1,1:3),phi_sys_d,phi_error] = parse_angle_inputs(varargin);
sys1 = phi_sys_d(1,1);
SYS = phi_sys_d(1,2);
sys2 = phi_sys_d(1,3);

display(['Euler angle in degree: ',num2str(Euler(1)),' ', num2str(Euler(2)), ' ', num2str(Euler(3))]);
display(['System rotation angle in degree: ',num2str(sys1),' ', num2str(SYS), ' ', num2str(sys2)]);

Stress_State = [ 1 0 0; 0 0 0; 0 0 0];
Stress_State = Stress_State/norm(Stress_State);
sample_normal = [0 0 1];  % sample normal direction. Actually, direction you are interested in, can change this to other.
c_a = 1.58;
nss = 24;

g_error = [
    cosd(phi_error) cosd(phi_error-90) 0;
    cosd(phi_error+90) cosd(phi_error) 0;
    0 0 1];

g_sys1 = [
    cosd(sys1) cosd(sys1-90) 0;
    cosd(sys1+90) cosd(sys1) 0;
    0 0 1];
g_SYS = [
    1 0 0;
    0 cosd(SYS) cosd(SYS-90);
    0 cosd(SYS+90) cosd(SYS)];
g_sys2 = [
    cosd(sys2) cosd(sys2-90) 0;
    cosd(sys2+90) cosd(sys2) 0;
    0 0 1];



phi1 = Euler(1);
PHI = Euler(2);
phi2 = Euler(3);

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
g = g_phi2*g_PHI*g_phi1 * g_sys2*g_SYS*g_sys1 * g_error;  % g is the 'transformation matrix' of Euler angle set i: x=gX, X is global.



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

slpsys = Slpsys;
local_stress_state = g*Stress_State*g';
for ii = 1:1:12
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
criteria_vertex_1 = sortrows(vertex_z_1,-2);
criteria_vertex_2 = sortrows(vertex_z_2,-2);
if criteria_vertex_1(1,2) > criteria_vertex_2(1,2)
    invisible_1 = criteria_vertex_1(1,1);
    invisible_2 = criteria_vertex_1(2,1);
else
    invisible_1 = criteria_vertex_2(1,1);
    invisible_2 = criteria_vertex_2(2,1);
end
% found index (two numbers within 1-12) of invisible vertex

for ii = 1:1:nss  % plot the cell for 18 slip system  %%%%%%%%%%%%%%%%%%%%%%%%%%%-2
    ssn = plot_order(ii,1);  % the number of slip system plotted.
    if rem(ii,6) == 1
        figure('position',[50,50,950,650]);
    end
    subplot(2,3,rem(ii-1,6)+1)
    set(gca,'ydir','reverse','zdir','reverse');
    hold on;
    axis square;
    axis ([-2 2 -2 2]);
    
    for jj = 1:1:slpsys(ssn).n_vertex
        spx(jj) = Rot_Vertex(slpsys(ssn).plane_index(jj),1);  % slip plane Coord for plot
        spy(jj) = Rot_Vertex(slpsys(ssn).plane_index(jj),2);
    end
    
    % The following plot slip plane
    if slpsys(ssn).Rot_Plane(3)>0  % If see front: warm grary.  If see back, cool gray.
        % Fill plane
        fill(spx(1:slpsys(ssn).n_vertex),spy(1:slpsys(ssn).n_vertex),[.8 .8 .65]);
        % Draw slip plane normal vector
        plot([Rot_Vertex(slpsys(ssn).plane_index(1),1), Rot_Vertex(slpsys(ssn).plane_index(1),1)+slpsys(ssn).Rot_Plane(1)],[Rot_Vertex(slpsys(ssn).plane_index(1),2), Rot_Vertex(slpsys(ssn).plane_index(1),2)+slpsys(ssn).Rot_Plane(2)],'Linewidth',4,'Color',[0 0 0]);
    else
        fill(spx(1:slpsys(ssn).n_vertex),spy(1:slpsys(ssn).n_vertex),[.65 .65 .7]);
        plot([Rot_Vertex(slpsys(ssn).plane_index(1),1), Rot_Vertex(slpsys(ssn).plane_index(1),1)+slpsys(ssn).Rot_Plane(1)],[Rot_Vertex(slpsys(ssn).plane_index(1),2), Rot_Vertex(slpsys(ssn).plane_index(1),2)+slpsys(ssn).Rot_Plane(2)],'--','Linewidth',4,'Color',[0 0 0]);
    end
    % The following, plot burgers vector. Start point of Burgers vector has circle
    plot([Rot_Vertex(slpsys(ssn).burgers_index(1),1),Rot_Vertex(slpsys(ssn).burgers_index(2),1)],[Rot_Vertex(slpsys(ssn).burgers_index(1),2),Rot_Vertex(slpsys(ssn).burgers_index(2),2)],'Linewidth',4,'Color',[0 1 1]);
    plot(Rot_Vertex(slpsys(ssn).burgers_index(1),1),Rot_Vertex(slpsys(ssn).burgers_index(1),2),'.','MarkerSize',24,'Color',[0 1 1]);  % start point of Burgers vector has circle.
    % The following, plot a line representing slip plane trace direction.
    if ssn>12
        plot([slpsys(ssn).Trace(1),-slpsys(ssn).Trace(1)],[slpsys(ssn).Trace(2),-slpsys(ssn).Trace(2)],'--','Linewidth',2,'Color',[0 1 0])  % green for pyramidal <c+a>
    elseif ssn>6
        plot([slpsys(ssn).Trace(1),-slpsys(ssn).Trace(1)],[slpsys(ssn).Trace(2),-slpsys(ssn).Trace(2)],'--','Linewidth',2,'Color',[0 0 0])  % black for pyramidal <a>
    elseif ssn<4
        plot([slpsys(ssn).Trace(1),-slpsys(ssn).Trace(1)],[slpsys(ssn).Trace(2),-slpsys(ssn).Trace(2)],'--','Linewidth',2,'Color',[1 0 0])  % red for basal
    else
        plot([slpsys(ssn).Trace(1),-slpsys(ssn).Trace(1)],[slpsys(ssn).Trace(2),-slpsys(ssn).Trace(2)],'--','Linewidth',2,'Color',[0 0 1])  % blue for prism
    end
    
    % The following, plot the cell.  Invisible ones use dash-line
    for jj = 1:1:6
        if jj ~= invisible_1 && jj ~= invisible_2
            p1 = jj+1-6*(rem(jj,6)==0);     % draw edge-1 on basal plane, if visible
            if p1 ~= invisible_1 && p1 ~= invisible_2
                plot([Rot_Vertex(jj,1), Rot_Vertex(p1,1)],[Rot_Vertex(jj,2), Rot_Vertex(p1,2)],'-','Linewidth',2,'Color',[0 0 0]);
            end
            %             p2 = jj-1+6*(rem(jj-1,6)==0);   % draw edge-2 on basal plane, if visible
            %             if p2 ~= invisible_1 && p2 ~= invisible_2
            %                 plot([Rot_Vertex(jj,1), Rot_Vertex(p2,1)],[Rot_Vertex(jj,2), Rot_Vertex(p2,2)],'-','Linewidth',2,'Color',[0 0 0]);
            %             end
            p3 = jj+6-12*(jj>6);            % draw edge on prism plane, if visible
            if p3 ~= invisible_1 && p3 ~= invisible_2
                plot([Rot_Vertex(jj,1), Rot_Vertex(p3,1)],[Rot_Vertex(jj,2), Rot_Vertex(p3,2)],'-','Linewidth',2,'Color',[0 0 0]);
            end
        else
            p1 = jj+1-6*(rem(jj,6)==0);     % draw edge-1 on basal plane, if visible
            %             if p1 ~= invisible_1 && p1 ~= invisible_2
            plot([Rot_Vertex(jj,1), Rot_Vertex(p1,1)],[Rot_Vertex(jj,2), Rot_Vertex(p1,2)],'--','Linewidth',1.5,'Color',[0 0 0]);
            %             end
            %             p2 = jj-1+6*(rem(jj-1,6)==0);   % draw edge-2 on basal plane, if visible
            %             %             if p2 ~= invisible_1 && p2 ~= invisible_2
            %             plot([Rot_Vertex(jj,1), Rot_Vertex(p2,1)],[Rot_Vertex(jj,2), Rot_Vertex(p2,2)],'--','Linewidth',1.5,'Color',[0 0 0]);
            %             end
            p3 = jj+6-12*(jj>6);            % draw edge on prism plane, if visible
            %             if p3 ~= invisible_1 && p3 ~= invisible_2
            plot([Rot_Vertex(jj,1), Rot_Vertex(p3,1)],[Rot_Vertex(jj,2), Rot_Vertex(p3,2)],'--','Linewidth',1.5,'Color',[0 0 0]);
            %             end
        end
        %             plot(Rot_Vertex(1,1),Rot_Vertex(1,2),'.','MarkerSize',24,'Color',[0 0 0]);  % Can use this to check which is [100] direction, if needed
    end
    for jj = 6:1:12
        if jj ~= invisible_1 && jj ~= invisible_2
            p1 = jj+1-6*(rem(jj,6)==0);     % draw edge-1 on basal plane, if visible
            if p1 ~= invisible_1 && p1 ~= invisible_2
                plot([Rot_Vertex(jj,1), Rot_Vertex(p1,1)],[Rot_Vertex(jj,2), Rot_Vertex(p1,2)],'-','Linewidth',2,'Color',[0 0 0]);
            end
        else
            p1 = jj+1-6*(rem(jj,6)==0);     % draw edge-1 on basal plane, if visible
            plot([Rot_Vertex(jj,1), Rot_Vertex(p1,1)],[Rot_Vertex(jj,2), Rot_Vertex(p1,2)],'--','Linewidth',1.5,'Color',[0 0 0]);
         end
    end
    plot(0,0,'ko');
    title(['order#' num2str(ii) ' SF=' num2str(slpsys(ssn).schmid_factor)]);
    xlabel(['ss' num2str(ssn) ' n=' mat2str(slpsys(ssn).slp_plane) ' m=' mat2str(slpsys(ssn).slp_dir)])
    
end %%%%%%%%%%%%%%%%%%%%%%%%%%%-2
hold off;
end

