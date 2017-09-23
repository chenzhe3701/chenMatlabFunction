% script for quaternion misorientation
q = [1, 0, 0, 0];
Q = [0.8660, 0, 0, 0.5000];

delta = [q*Q', q(1)*Q(2:4) - Q(1)*q(2:4) - cross(q(2:4),Q(2:4))];
theta = 2*acosd( delta(1) );
v = delta(2:4);