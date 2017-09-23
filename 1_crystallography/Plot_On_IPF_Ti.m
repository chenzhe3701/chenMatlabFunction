%  chenzhe 2016-4-5 revised
%
%  This code plots an inverse pole figure, i.e., a direction of the sample projected in the crystal's coordinate system.
%  Note: for different c_a ratio, the same point in IPF represents diffrent crystallographic direction.
%  So, don't considers the position of the poles to be propotional...
%  Zhe Chen, rewritten based on the structure built by Hongmei & Dr. Bieler
%  2011-08-25


clc;
clear;

figure;
hold on;
axis square;
axis([0 1.2 0 1.2]);

% Euler(:,3:5) = [16.2 83.2 331.8];  % Euler angle, can be more than one set, each set occupies one row

stressTensor = [ 1 0 0; 0 0 0; 0 0 0];
stressTensor = stressTensor/norm(stressTensor);
sample_direction_of_interest = [1 0 0];    % Direction you are interested in.  If it's [0 0 1], it's the normal direction of the sample
% here if I write [1 0 0], it means tensile axis is the interested direction
[ssa, c_a] = define_SS('Mg','twin');
nSS = size(ssa,3);  %24

% function ss = hex_to_cart_ss(ssa)
% size(ssa) = 2, 4, 24 or other, defining ss using four indices
% row_1 = plane_normal, row_2 = slip direction, page = slip system
ss = hex_to_cart_ss(ssa,c_a);

% generate inverse pole figure

theta = [0:1:30];  % just the paremeter 'theta'
border_x = [0 cosd(theta) 0];
border_y = [0 sind(theta) 0];
plot(border_x, border_y, 'k-');
% border_x2 = [0 cosd(theta)*sqrt(3)/3 0];  % this is for plotting 60_degree line
% border_y2 = [0 sind(theta)*sqrt(3)/3 0];
% plot(border_x2, border_y2, 'k-');

eulers = [68.6590,   28.0170,  271.5900; 
    70.1300,   30.5980,  274.1300]; % 7Al_#B6_g97,before and after
for i = 1:2%1:10000
    Euler(1:3) = rand(1,3).*[360,180,360];  % Euler angle, can be more than one set, each set occupies one row
    Euler(1:3) = eulers(i,:);   
    phi1 = Euler(1);
    PHI = Euler(2);
    phi2 = Euler(3);
    
    g = euler_to_transformation([phi1,PHI,phi2],[90,180,0],[0 0 0]);
    
    for iSS = 1:min(nSS,24)
        N(iSS,:) = ss(1,:,iSS) * g;         % for grain 1, [slip plane normal] expressed in Global system
        M(iSS,:) = ss(2,:,iSS) * g;     % for grain 1, [slip direction] expressed in Global system
        SF(iSS,1) = abs(N(iSS,:) * stressTensor * M(iSS,:)');  % Schimid factor for slip system j
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
    
    if max(SF(1:3)) > 0.4
        plot(X,Y,'o','LineWidth',1,'MarkerEdgeColor',[1 1 1], 'MarkerFaceColor',[1 0 0],'MarkerSize',6);
    elseif max(SF(1:3)) > 0.3
        plot(X,Y,'o','LineWidth',1,'MarkerEdgeColor',[1 1 1], 'MarkerFaceColor',[1 1 0],'MarkerSize',6);
    elseif max(SF(1:3)) > 0.2
        plot(X,Y,'o','LineWidth',1,'MarkerEdgeColor',[1 1 1], 'MarkerFaceColor',[0 1 0],'MarkerSize',6);
    elseif max(SF(1:3)) > 0.1
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

text(0.01,0.12,'0 0 0 1')
text(1.02,0.02,'2 -1 -1 0')
text(0.87,0.52,'1 0 -1 0')
hold off;


