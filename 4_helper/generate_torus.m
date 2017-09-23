% torusPoints = generate_torus(angularStep)
% angularStep is how dense the point is
% torusPoints are xx_by_3 matrix 

function torusPoints = generate_torus(angularStep)
% angularStep=5;    % for testing code
a=0.25;
c=0.75;
[u,v]=meshgrid(0:angularStep:360);
x=(c+a*cosd(v)).*cosd(u);
y=(c+a*cosd(v)).*sind(u);
z=a*sind(v);
torusPoints = [x(:),y(:),z(:)];
% surfl(x,y,z)
% axis equal;