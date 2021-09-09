% plot an ellipse in the current axis
% a = semi-major axis
% b = semi-minor axis
% u = translation in x
% v = translation in y
% alpha = rotation in degree
%
% chenzhe, 2021-08-31

function [] = plot3_ellipse(a,b,u,v,alpha)

% for debug.
% a = 2;
% b = 1;
% u = 2;
% v = 1;
% alpha = 30;
% 
% X = @(t) a*cosd(t);
% Y = @(t) b*sind(t);
% XR = @(t) a*cosd(t)*cosd(alpha)-b*sind(t)*sind(alpha);
% YR = @(t) a*cosd(t)*sind(alpha)+b*sind(t)*cosd(alpha);

XRT = @(t) a*cosd(t)*cosd(alpha)-b*sind(t)*sind(alpha) + u;
YRT = @(t) a*cosd(t)*sind(alpha)+b*sind(t)*cosd(alpha) + v;

zlim = get(gca,'Zlim');
Z = 10^ceil(log10(zlim(2)))-1;
ZRT = @(t) t*0 + Z;

fplot3(XRT,YRT,ZRT, [-180,180], 'Color','r','LineWidth',1);