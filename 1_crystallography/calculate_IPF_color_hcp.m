% color = calculate_IPF_color_hcp(euler,direction)
% euler = [phi1 phi phi2] is the crystal orientation
% direction = [X Y Z] is the sheet direction you are looking at
% color = [R G B]
%
% Zhe Chen 2015-08-04 revised.
% Zhe Chen 2016-06-14 revise to use parse_angle_inputs.
%
% chenzhe, 2019-10-29, modify to take phi_sys = [1x3] vector (in degree)

function color = calculate_IPF_color_hcp(euler_in,phi_sys, direction)

[euler,phi_sys,phi_error,TF] = parse_angle_inputs(euler_in,phi_sys);

mMatrix = euler_to_transformation(euler,phi_sys,phi_error);  % the 'transformation matrix' defined in continuum mechanics: x=g*X, X is Global corrdinate

direction = direction./norm(direction);
directionInHcp = mMatrix * direction';       % calculate how sheet direction looks like in crystal coordinate
X = abs(directionInHcp(1));     % make this projection to 1st octant
Y = abs(directionInHcp(2));
rXY = sqrt(X^2+Y^2);
Z = abs(directionInHcp(3));
if X==0
    alpha=90;
else
    alpha = atand(Y/X);
end
alpha = 30-abs(rem(alpha,60)-30);  % change to it's corresponding angle which is between 0-30 degrees.

newZ = Z;
% newY = rXY*sind(alpha)/(1/2);
% newX = rXY*cosd(alpha)-newY*sqrt(3)/2;

% chenzhe, note, 2019-10-29. The only explanation I can think of now for above, is to stretch a 30 degree sector to a 90 degree section.
% The point positions are stretched 2 times in the y direction.
% Sheared to the x-direction, shear distance for newY=1 point is sqrt(3)/2.
%
% So, try stretch by angle:

newAlpha = 3 * alpha;
newX = rXY * cosd(newAlpha);
newY = rXY * sind(newAlpha);


% Z for Red, X for Green, Y for Blue
R = newZ/sqrt(newZ^2+newX^2+newY^2);
G = newX/sqrt(newZ^2+newX^2+newY^2);
B = newY/sqrt(newZ^2+newX^2+newY^2);
R = R/max([R,G,B]);
G = G/max([R,G,B]);
B = B/max([R,G,B]);


color = [R,G,B];  


