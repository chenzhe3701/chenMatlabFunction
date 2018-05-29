function [x_out,y_out] = calculate_pos_on_IPF(eulers_d, str_material, varargin)
% eulers_d: nx3 vector of euler angles
% str_material = 'Ti' or 'Mg', maybe others later
% 'sample_direction_of_interestI', default [1 0 0]
% 'phi_sys', default [0 0 0]
% 'phi_error', default [0 0 0]
% 'stressTensor', default [1 0 0; 0 0 0; 0 0 0]
% 'str_twin', default 'twin', could be 'pyii' maybe others
% 'plotTF', default 'false'
%
% chenzhe, 2018-05-28, based on plot_on_IPF.

p = inputParser;

addParameter(p,'sample_direction_of_interest',[1 0 0]);
addParameter(p,'phi_sys',[0 0 0]);
addParameter(p,'phi_error',[0 0 0]);
addParameter(p,'ss_of_interest',1);
addParameter(p,'stressTensor',[1 0 0; 0 0 0; 0 0 0]);
addParameter(p,'str_twin','twin');
addParameter(p,'plotTF',false);

parse(p,varargin{:});


phi_sys = p.Results.phi_sys; 
phi_error = p.Results.phi_error;
sample_direction_of_interest = p.Results.sample_direction_of_interest;
ss_of_interest = p.Results.ss_of_interest;
stressTensor = p.Results.stressTensor;

stressTensor = stressTensor/norm(stressTensor);

str_twin = p.Results.str_twin;
plotTF = p.Results.plotTF;

% here if I write [1 0 0], it means tensile axis is the interested direction

[ssa, c_a, nss, ntwin, ssGroup] = define_SS(str_material,str_twin);
nSS = size(ssa,3);  %24

% function ss = hex_to_cart_ss(ssa)
% size(ssa) = 2, 4, 24 or other, defining ss using four indices
% row_1 = plane_normal, row_2 = slip direction, page = slip system
ss = hex_to_cart_ss(ssa,c_a);

% generate inverse pole figure

theta_d = [0:1:30];  % just the paremeter 'theta'
border_x = [0 cosd(theta_d) 0];
border_y = [0 sind(theta_d) 0];
if plotTF
    figure; hold on;
    axis square; % axis off;
    axis([0 1.2 0 1.2]);
    plot(border_x, border_y, 'k-');
end
% border_x2 = [0 cosd(theta)*sqrt(3)/3 0];  % this is for plotting 60_degree line
% border_y2 = [0 sind(theta)*sqrt(3)/3 0];
% plot(border_x2, border_y2, 'k-');


for i = 1:size(eulers_d,1)
    Euler(1:3) = eulers_d(i,:);   
    phi1 = Euler(1);
    PHI = Euler(2);
    phi2 = Euler(3);
    
    g = euler_to_transformation([phi1,PHI,phi2], phi_sys, phi_error);
    
    for iss = 1:nss
        N(iss,:) = ss(1,:,iss) * g;         % for grain 1, [slip plane normal] expressed in Global system
        M(iss,:) = ss(2,:,iss) * g;     % for grain 1, [slip direction] expressed in Global system
        SF(iss,1) = abs(N(iss,:) * stressTensor * M(iss,:)');  % Schimid factor for slip system j
    end
    for iss = nss+1 : nss+ntwin
        N(iss,:) = ss(1,:,iss) * g;         % for grain 1, [slip plane normal] expressed in Global system
        M(iss,:) = ss(2,:,iss) * g;     % for grain 1, [slip direction] expressed in Global system
        SF(iss,1) = N(iss,:) * stressTensor * M(iss,:)';  % Schimid factor for twin system j
    end
    
    pole = g*sample_direction_of_interest.';  % sample normal in crystallographic Cartesian coordinate
    x = abs(pole(1));
    y = abs(pole(2));
    z = abs(pole(3));
    X = x/(1+z);    % the coord projected to equitorial plane: X/x = 1/(1+z). 
    Y = y/(1+z);  % This convert all points to 1st octant, then plot.  If you convert all point into 7th, then use X=x/(1-z), Y=y/(1-z).
    if z == 1  % for the extreme condition...
        X = 10^(-9);
    end
    
    alpha = atand(Y/X);
    alpha = 30-abs(rem(alpha,60)-30);  % change to it's corresponding angle which is between 0-30 degrees.
    r = sqrt(X^2+Y^2);
    X = r*cosd(alpha);  % change the coord. X,Y into the plot region
    Y = r*sind(alpha);
    x_out(i) = X;
    y_out(i) = Y;
    if plotTF
        if max(SF(ss_of_interest)) > 0.4
            plot(X,Y,'o','LineWidth',1,'MarkerEdgeColor',[1 1 1], 'MarkerFaceColor',[1 0 0],'MarkerSize',6);
        elseif max(SF(ss_of_interest)) > 0.3
            plot(X,Y,'o','LineWidth',1,'MarkerEdgeColor',[1 1 1], 'MarkerFaceColor',[1 1 0],'MarkerSize',6);
        elseif max(SF(ss_of_interest)) > 0.2
            plot(X,Y,'o','LineWidth',1,'MarkerEdgeColor',[1 1 1], 'MarkerFaceColor',[0 1 0],'MarkerSize',6);
        elseif max(SF(ss_of_interest)) > 0.1
            plot(X,Y,'o','LineWidth',1,'MarkerEdgeColor',[1 1 1], 'MarkerFaceColor', [0 0 1],'MarkerSize',6);
        else
            plot(X,Y,'o','LineWidth',1,'MarkerEdgeColor',[1 1 1], 'MarkerFaceColor', [0 0 0],'MarkerSize',6);
        end
    end
    
    %     % plot basal red, prism blue, pryII black, tension twin green.
    %     if i<Nbasal+1
    %     plot(X,Y,'o','LineWidth',1,'MarkerEdgeColor',[1 1 1],...
    %                 'MarkerFaceColor',[1 0 0],'MarkerSize',8)
    %     elseif i<Nbasal+Nprism+1
    %     plot(X,Y,'s','LineWidth',1,'MarkerEdgeColor',[1 1 1],...
    %                 'MarkerFaceColor',[0 0 1],'MarkerSize',8)
    %     elseif i<Nbasal+Nprism+Npyram+1
    %     plot(X,Y,'d','LineWidth',1,'MarkerEdgeColor',[1 1 1],...
    %                 'MarkerFaceColor',[0 0 0],'MarkerSize',7)
    %     else
    %     plot(X,Y,'^','LineWidth',1,'MarkerEdgeColor',[1 1 1],...
    %                 'MarkerFaceColor',[0.2 0.9 0.1],'MarkerSize',8)
    %     end
    %     %text(X,Y+0.03,num2str(i))
end

if plotTF
    text(-0.12,0.12,'0 0 0 1','fontsize',18)
    text(1.02,0.02,'2 -1 -1 0','fontsize',18)
    text(0.87,0.52,'1 0 -1 0','fontsize',18)
    hold off;
end


