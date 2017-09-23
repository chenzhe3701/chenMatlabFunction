% chenzhe, 2017-07-17
%
% this calculates the bilinear interpolation of imaging positions based on
% the four corner points.
% See https://en.wikipedia.org/wiki/Bilinear_interpolation for derivation.

nR = 5;
nC = 5;

[iR, iC] = meshgrid(0:nR, 0:nC);

x11 = 0; y11 = 0;
x21 = 10; y21 = 1;
x12 = 1; y12 = 6;
x22 = 12; y22 = 9;

x = 1/nC/nR * (x11*(nC-iC).*(nR-iR) + x21*iC.*(nR-iR) + x12*(nC-iC).*iR + x22*iC.*iR);
y = 1/nC/nR * (y11*(nC-iC).*(nR-iR) + y21*iC.*(nR-iR) + y12*(nC-iC).*iR + y22*iC.*iR);

scatter(x(:),y(:)); set(gca,'ydir','reverse');