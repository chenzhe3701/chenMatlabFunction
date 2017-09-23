% Cartesian to Hex

clear;
clc;

c_a = 1.62;
cartesian = [0.4659 -0.0035 0.8848];
x = cartesian(1);
y = cartesian(2);
z = cartesian(3);

u = 2*x/3;
v = y/sqrt(3)-x/3;
w = z/c_a;
t = -u-v;
Direction = [u,v,t,w]