close all;

[x,y] = meshgrid(1:10,1:10);
u = x/5+rand(10)/50;
v = y/10+rand(10)/50;
u2 = u+x/10;
[s] = calculate_strain_area(x,y,u,v,ones(10),3);
exx = s(:,:,1);
exy = s(:,:,2);
eyy = s(:,:,3);

[s] = calculate_strain_area(x,y,u2,v,ones(10),3);
exx2 = s(:,:,1);
exy2 = s(:,:,2);
eyy2 = s(:,:,3);

myplot(exx);
myplot(exx2);
myplot(exy);
myplot(exy2);
myplot(eyy);
myplot(eyy2);