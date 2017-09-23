%  chenzhe 2016-4-5 revised
%
%  This code plots an inverse pole figure, i.e., a direction of the sample projected in the crystal's coordinate system.
%  Note: for different c_a ratio, the same point in IPF represents diffrent crystallographic direction.
%  So, don't considers the position of the poles to be propotional...
%  Zhe Chen, rewritten based on the structure built by Hongmei & Dr. Bieler
%  2011-08-25
%
% chenzhe, 2017-07-25, make it a function
%
% sample_direction_of_interest: if it's [0 0 1], it's the normal direction of the sample

function [] = plot_on_IPF(eulers_d, phi_sys, phi_error, sample_direction_of_interest, ss_of_interest, stressTensor, str_material, str_twin)

clc;
figure;
hold on;
axis square;axis off;
axis([0 1.2 0 1.2]);

stressTensor = stressTensor/norm(stressTensor);
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
plot(border_x, border_y, 'k-');
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
    X = x/(1+z);
    Y = y/(1+z);  % This convert all points to 1st octant, then plot.  If you convert all point into 7th, then use X=x/(1-z), Y=y/(1-z).
    if z == 1  % for the extreme condition...
        X = 10^(-9);
    end
    
    alpha = atand(Y/X);
    alpha = 30-abs(rem(alpha,60)-30);  % change to it's corresponding angle which is between 0-30 degrees.
    r = sqrt(X^2+Y^2);
    X = r*cosd(alpha);  % change the coord. X,Y into the plot region
    Y = r*sind(alpha);
    
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

text(-0.12,0.12,'0 0 0 1','fontsize',18)
text(1.02,0.02,'2 -1 -1 0','fontsize',18)
text(0.87,0.52,'1 0 -1 0','fontsize',18)
hold off;


