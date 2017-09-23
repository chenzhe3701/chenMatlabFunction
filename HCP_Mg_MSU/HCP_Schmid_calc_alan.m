clear all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code uses Euler angle data which is mapped onto a strain map of
% deformation. The user inputs two data points on the strain map which
% correspond the a slip trace or crack on the deformed surface. The user
% must also input the Euler angles of the underlying grain. The code then
% calculates the orientation of all 24 slip traces for HCP materials, and
% determines the angle difference between each slip trace and the line on
% surface. It also calculates the Schmid factor for each slip system.
%
% It is very important to understand the Euler angles you are exporting,
% and how they are defined with respect to the spatial reference system. By
% default, the TSL software uses the following convention to define Euler
% angle axis and spatial axes (the x-y-z coordinate system seen on the
% orientation map and other images on screen):
%
%                         ---------------> x spatial
%                         ===============> y Euler
%                    |  ||
%                    |  ||
%                    |  ||
%                    |  ||
%                    |  ||
%                    |  ||
%                    |  ||
%                    |  ||
%                    |  \/ x Euler
%                    |  
%                    |
%                    \/ y spatial
%
% This code uses data that already has the Euler axis rotated for
% simplicity purposed. Thus the Euler angles in any grain file used in this
% code should have the following directions, where the spatial and Euler 
% axis match each other:
%
%                         ---------------> x spatial
%                         ===============> x Euler
%                    |  ||
%                    |  ||
%                    |  ||
%                    |  ||
%                    |  ||
%                    |  ||
%                    |  ||
%                    |  ||
%                    |  \/ y Euler
%                    |  
%                    |
%                    \/ y spatial
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% LIST OF 24 HCP SLIP SYSEMS:
a = 0.3209; %a lattice constant for magnesium [nm]
c = 0.5211; %c lattice constant for magnesium [nm]

P_direction = [1;0;0]; % loading direction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Even though HCP is not defined with orthogonal axis, the slip system
% plane normals and directions listed below have all been converted to an
% orthogonal crystal system, defined with x-y-z coordinates instead of
% a1-a2-a3-c Bravais lattice coordinates, as shown below. The TSL software,
% however, assumes that all unit cells default have the a1 axis aligned
% with the x spatial direction and the z or c axis pointing into the screen
% (opposite the x-y-z system shown below). If we wanted to convert the unit
% cell below to match the TSL default position, we would need to rotate the
% cell 120 degrees about the z axis and 180 degrees about the x axis. These
% rotations are applied to all of the slip normals and directions so that
% their coordinates are correct for the spatial sample geometry shown above.
%                         
%                 a3
%                  \  
%                   \
%                    \________________
%                    /                \
%                   /        ^ y       \
%                  /         |          \
%                 /          |           \
%                /            ------> x   \________ a2
%                \                        /
%                 \                      /
%                  \                    /
%                   \                  /
%                    \________________/
%                    /
%                   /
%                  /
%                 a1
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Slip plane unit normals
slipsys.n = [0  0  1
             0  0  1
             0  0  1
             0           1    0
            -sqrt(3)/2   1/2  0
            -sqrt(3)/2  -1/2  0
             0                             -2*c/sqrt(4*c^2+3*a^2)   sqrt(3)*a/sqrt(4*c^2+3*a^2)
             sqrt(3)*c/sqrt(4*c^2+3*a^2)   -c/sqrt(4*c^2+3*a^2)     sqrt(3)*a/sqrt(4*c^2+3*a^2)
             sqrt(3)*c/sqrt(4*c^2+3*a^2)    c/sqrt(4*c^2+3*a^2)     sqrt(3)*a/sqrt(4*c^2+3*a^2)
             0                              2*c/sqrt(4*c^2+3*a^2)   sqrt(3)*a/sqrt(4*c^2+3*a^2)
            -sqrt(3)*c/sqrt(4*c^2+3*a^2)    c/sqrt(4*c^2+3*a^2)     sqrt(3)*a/sqrt(4*c^2+3*a^2)
            -sqrt(3)*c/sqrt(4*c^2+3*a^2)   -c/sqrt(4*c^2+3*a^2)     sqrt(3)*a/sqrt(4*c^2+3*a^2)
             c/(2*sqrt(c^2+a^2))           -sqrt(3)*c/(2*sqrt(c^2+a^2))  a/sqrt(c^2+a^2)
             c/sqrt(c^2+a^2)                0                            a/sqrt(c^2+a^2)
             c/(2*sqrt(c^2+a^2))            sqrt(3)*c/(2*sqrt(c^2+a^2))  a/sqrt(c^2+a^2)
            -c/(2*sqrt(c^2+a^2))            sqrt(3)*c/(2*sqrt(c^2+a^2))  a/sqrt(c^2+a^2)
            -c/sqrt(c^2+a^2)                0                            a/sqrt(c^2+a^2)
            -c/(2*sqrt(c^2+a^2))           -sqrt(3)*c/(2*sqrt(c^2+a^2))  a/sqrt(c^2+a^2)
             0                                 -c/sqrt(c^2+3*a^2)        sqrt(3)*a/sqrt(c^2+3*a^2)
             0                                  c/sqrt(c^2+3*a^2)        sqrt(3)*a/sqrt(c^2+3*a^2)
            -sqrt(3)*c/(2*sqrt(c^2+3*a^2))     -c/(2*sqrt(c^2+3*a^2))    sqrt(3)*a/sqrt(c^2+3*a^2)
             sqrt(3)*c/(2*sqrt(c^2+3*a^2))      c/(2*sqrt(c^2+3*a^2))    sqrt(3)*a/sqrt(c^2+3*a^2)
             sqrt(3)*c/(2*sqrt(c^2+3*a^2))     -c/(2*sqrt(c^2+3*a^2))    sqrt(3)*a/sqrt(c^2+3*a^2)
            -sqrt(3)*c/(2*sqrt(c^2+3*a^2))      c/(2*sqrt(c^2+3*a^2))    sqrt(3)*a/sqrt(c^2+3*a^2)]';

        
% Slip unit directions
slipsys.m = [1/2  -sqrt(3)/2  0
             1/2   sqrt(3)/2  0
            -1     0          0
             1     0          0
             1/2   sqrt(3)/2  0
            -1/2   sqrt(3)/2  0
             1     0          0
             1/2   sqrt(3)/2  0
            -1/2   sqrt(3)/2  0
            -1     0          0
            -1/2  -sqrt(2)/2  0
             1/2  -sqrt(3)/2  0
            -a/(2*sqrt(c^2+a^2))            sqrt(3)*a/(2*sqrt(c^2+a^2))  c/sqrt(c^2+a^2)
            -a/sqrt(c^2+a^2)                0                            c/sqrt(c^2+a^2)
            -a/(2*sqrt(c^2+a^2))           -sqrt(3)*a/(2*sqrt(c^2+a^2))  c/sqrt(c^2+a^2)
             a/(2*sqrt(c^2+a^2))           -sqrt(3)*a/(2*sqrt(c^2+a^2))  c/sqrt(c^2+a^2)
             a/sqrt(c^2+a^2)                0                            c/sqrt(c^2+a^2)
             a/(2*sqrt(c^2+a^2))            sqrt(3)*a/(2*sqrt(c^2+a^2))  c/sqrt(c^2+a^2)
             0                                  sqrt(3)*a/sqrt(c^2+3*a^2)      c/sqrt(c^2+3*a^2)  
             0                                 -sqrt(3)*a/sqrt(c^2+3*a^2)      c/sqrt(c^2+3*a^2)  
             sqrt(3)*a/(2*sqrt(c^2+3*a^2))      sqrt(3)*a/(2*sqrt(c^2+3*a^2))  c/(2*sqrt(c^2+3*a^2))  
            -sqrt(3)*a/(2*sqrt(c^2+3*a^2))     -sqrt(3)*a/(2*sqrt(c^2+3*a^2))  c/(2*sqrt(c^2+3*a^2))  
            -sqrt(3)*a/(2*sqrt(c^2+3*a^2))      sqrt(3)*a/(2*sqrt(c^2+3*a^2))  c/(2*sqrt(c^2+3*a^2))  
             sqrt(3)*a/(2*sqrt(c^2+3*a^2))     -sqrt(3)*a/(2*sqrt(c^2+3*a^2))  c/(2*sqrt(c^2+3*a^2))]';
         

for i = 1:24
    slipsys.n(:,i) = [1,0,0;0,cosd(180),-sind(180);0,sind(180),cosd(180)]*[cosd(120),-sind(120),0;sind(120),cosd(120),0;0,0,1]*slipsys.n(:,i);   
    slipsys.m(:,i) = [1,0,0;0,cosd(180),-sind(180);0,sind(180),cosd(180)]*[cosd(120),-sind(120),0;sind(120),cosd(120),0;0,0,1]*slipsys.m(:,i);
end
         
slipsys.names = {'Basal (0001)[11-20]'
                 'Basal (0001)[-2110]'
                 'Basal (0001)[1-210]'
                 'Prismatic (10-10)[1-210]'
                 'Prismatic (01-10)[2-1-10]'
                 'Prismatic (-1100)[11-20]'
                 'Pyramidal <a> (10-11)[1-210]'
                 'Pyramidal <a> (01-11)[-2110]'
                 'Pyramidal <a> (-1101)[-1-120]'
                 'Pyramidal <a> (-1011)[-12-10]'
                 'Pyramidal <a> (0-111)[2-1-10]'
                 'Pyramidal <a> (1-101)[11-20]'
                 'Pyramidal <c+a> (11-22)[-1-123]'
                 'Pyramidal <c+a> (-12-12)[1-213]'
                 'Pyramidal <c+a> (-2112)[2-1-13]'
                 'Pyramidal <c+a> (-1-122)[11-23]'
                 'Pyramidal <c+a> (1-212)[-12-13]'
                 'Pyramidal <c+a> (2-1-12)[-2113]'
                 'Extension Twin (10-12)[-1011]'
                 'Extension Twin (-1012)[10-11]'
                 'Extension Twin (1-102)[-1101]'
                 'Extension Twin (-1102)[1-101]'
                 'Extension Twin (01-12)[0-111]'
                 'Extension Twin (0-112)[01-11]'}';

%% Load the Euler angle data from the .txt file
[f, p]= uigetfile('*.txt', 'Select Type 1 Grain File');

fid = fopen([p f]);
C = textscan(fid,'%f %f %f %f %f %f %f %f %u %u %s', 'Headerlines', 15);
fclose(fid);

phi1 = C{1};
PHI = C{2};
phi2 = C{3};
X = C{4}; % in um
Y = C{5}; % in um
%IQ = C{6}; % image quality
%CI = C{7}; % confidence index percent
%FIT = C{8}; % degrees error
GrainID = C{9}; 
%EdgeID = C{10}; % true if on edge of scan

clear C

% Reshape grain data
m = length(unique(X));
n = length(unique(Y));
X = reshape(X, m, n)';
Y = reshape(Y, m, n)';



%% Calculate the Schmid factors

gUnique = unique(GrainID);
gNum = size(unique(GrainID),1); % number of unique grains

for i = 1:gNum

    % Pull the Euler angles of grain i.
    gID = GrainID == gUnique(i);
    ph10 = phi1(gID);
    PH0 = PHI(gID);
    ph20 = phi2(gID);
    p1 = mode(ph10); P = mode(PH0); p2 = mode(ph20);
    
    % Rotation Matrix: this is a passive tranformation that converts the
    % loading direction to the crystal coordinate system. In a passive
    % transformation, the coordinate system rotates according to the Euler
    % angles and the global (sample reference system) loading direction does not change. This is
    % contrary to the active tranformation, in which the loading direction
    % would change in refernce to the sample geometry. The passive transformation is
    % the inverse of the passive transformation. The term [0 1 0;1 0 0; 0 0 -1] is an additional rotation
    % matrix that rotates the Euler axes to align exactly with the spatial
    % axes. I.e. the x Euler axis matches the x spatial axis. If the Euler
    % angle axes definitions are changed in the TSL software, this
    % additional term must be changed as well for accurate calculations!!!
    rotation = [cos(p1)*cos(p2)-sin(p1)*cos(P)*sin(p2)  sin(p1)*cos(p2)+cos(p1)*cos(P)*sin(p2)  sin(P)*sin(p2);...
               -cos(p1)*sin(p2)-sin(p1)*cos(P)*cos(p2) -sin(p1)*sin(p2)+cos(p1)*cos(P)*cos(p2)  sin(P)*cos(p2);...
                sin(P)*sin(p1)                         -sin(P)*cos(p1)                          cos(P)];%*[0 1 0;1 0 0; 0 0 -1];
   
    Lcrystal = rotation * P_direction; % Passive transformation of the loading direction to the crystal coordinate system
    
    for j = 1:24 % Cycles through all of the slip systems 
        
        % Calculate the cosine of the angle between slip plane normal and 
        % loading direction
        cos_phi(j) = [slipsys.n(1,j), slipsys.n(2,j), slipsys.n(3,j)]*Lcrystal;
     
        % Calculate the cosine of the angle between slip direction and
        % loading direction
        cos_lambda(j) = [slipsys.m(1,j), slipsys.m(2,j), slipsys.m(3,j)]*Lcrystal;

        M(j) = abs(cos_phi(j)*cos_lambda(j));
    end
    Schmid = max([M(1),M(2),M(3)]); Schmid_GRID_basal(gID) = Schmid;
    Schmid = max([M(4),M(5),M(6)]); Schmid_GRID_prism(gID) = Schmid;
    Schmid = max([M(7),M(8),M(9),M(10),M(11),M(12)]); Schmid_GRID_pyr_a(gID) = Schmid;
    Schmid = max([M(13),M(14),M(15),M(16),M(17),M(18)]); Schmid_GRID_pyr_a_c(gID) = Schmid;
    Schmid = max([M(19),M(20),M(21),M(22),M(23),M(24)]); Schmid_GRID_twin(gID) = Schmid;
end

Schmid_GRID_basal = reshape(Schmid_GRID_basal,m,n)'; %Schmid_GRID_basal = flipud(Schmid_GRID_basal);
Schmid_GRID_prism = reshape(Schmid_GRID_prism,m,n)'; %Schmid_GRID_prism = flipud(Schmid_GRID_prism);
Schmid_GRID_pyr_a = reshape(Schmid_GRID_pyr_a,m,n)'; %Schmid_GRID_pyr_a = flipud(Schmid_GRID_pyr_a);
Schmid_GRID_pyr_a_c = reshape(Schmid_GRID_pyr_a_c,m,n)'; %Schmid_GRID_pyr_a_c = flipud(Schmid_GRID_pyr_a_c);
Schmid_GRID_twin = reshape(Schmid_GRID_twin',m,n)'; %Schmid_GRID_twin = flipud(Schmid_GRID_twin);

            

%% Plot the Schmid Factors

figure('Position',[200,50,700,600]);
surf(X,Y,Schmid_GRID_basal,'EdgeColor','none');
%axis([0 1000 0 1000])
set(gca,'Position',[0.17,0.2,0.66,0.6],'DataAspectRatio',[1 1 1]);
set(gca,'color','none');
view([0 -90]); 
a = colorbar('Position',[0.82,0.197,0.035,0.595],'YColor','k');
set(get(a,'title'),'String', {'Schmid Factor'},'Color','k');
caxis([0 0.5]);
colormap(gray);
%set(a,'YTick',0:.1:.5);
hTitle  = title ('Basal Schmid Factor');
hXLabel = xlabel('x (pixels)');
hYLabel = ylabel('y (pixels)');
set( [gca,a],'FontName', 'Helvetica');
set([hTitle, hXLabel, hYLabel],'FontName', 'Helvetica','Color','k');
set([gca,a],'FontSize', 14);
set([hXLabel, hYLabel,get(a,'title')],'FontSize', 14);
set( hTitle,'FontSize', 14,'FontWeight' , 'bold');
set(gca,'color','w');
set(gcf,'color','w');
set(gca, ...
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.02 .02] , ...
  'XMinorTick'  , 'on'      , ...
  'YMinorTick'  , 'on'      , ...
  'YGrid'       , 'off'      , ...
  'XGrid'       , 'off'      , ...
  'XColor'      , 'k', ...
  'YColor'      , 'k', ...
  'YTick'       , 0:200:1000, ...
  'XTick'       , 0:200:1000, ...
  'LineWidth'   , 1         );
set(gcf, 'PaperPositionMode', 'auto');

%print('-dtiff', '-r250', sprintf('SchmidFactor_%g.tiff', 1));
%saveas(gcf, sprintf('GrainSize_%g.fig', 1), 'fig');