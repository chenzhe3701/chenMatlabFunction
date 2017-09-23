%% twin
% note that, only part of the atoms move to the shear relationship.

clear;
a1 = [1, 0, 0];
a2 = [-1/2 sqrt(3)/2, 0];
c_a = 1.588;
c = [0, 0, c_a];

nx = 9; ny = 9; nz = 9;     % odd number

p0 = -(nx-1)/2*a1 -(ny-1)/2*a2 -(nz-1)/2*c;
x0 = p0(1); y0 = p0(2); z0 = p0(3);

% description of the original and transformed/rotated/reflected/sheared points 
ax = [0, sqrt(3), -c_a]; ax = ax/norm(ax);
ang = pi;
quat = axang2quat([ax,ang]);
dcm = quat2dcm(quat);
r = dcm';

for ix = 1:nx
   for iy = 1:ny
      for iz = 1:nz
          p = p0 + a1 *(ix-1) + a2 * (iy-1) + c * (iz-1);
          x(ix,iy,iz) = p(1);
          y(ix,iy,iz) = p(2);
          z(ix,iy,iz) = p(3);
          q = p * dcm;
          X(ix,iy,iz) = q(1);
          Y(ix,iy,iz) = q(2);
          Z(ix,iy,iz) = q(3);          
      end
   end
end
figure; hold on;axis equal;view([1 0 0]);
% only plot part of the points.  But can modify and choose what to plot.
for ix = 1:nx
   for iy = 1:ny
      for iz = 1:nz
          if abs(x(ix,iy,iz))<1.1
              plot3(x(ix,iy,iz),y(ix,iy,iz),z(ix,iy,iz),'.r','markersize',24);
          end
          if abs(X(ix,iy,iz))<1.1
              plot3(X(ix,iy,iz),Y(ix,iy,iz),Z(ix,iy,iz),'bo','markersize',6);
          end
      end
   end
end
xlabel('x');ylabel('y');zlabel('z');
