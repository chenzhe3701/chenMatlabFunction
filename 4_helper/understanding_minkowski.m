[x,y]=meshgrid(0:0.01:3,0:0.01:3);

d = reshape(pdist2([0 0],[x(:),y(:)],'minkowski',0.3), size(x,1),size(x,2));

contour(x,y,d,20); colorbar; view(0,90)