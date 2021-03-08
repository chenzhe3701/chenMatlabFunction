function axang = my_quat2axang(quat)
% the function quat2axang is no longer available.  Therefore, write my own.
% quat = a + bi + cj + dk
% chenzhe, 2019-04-02

g=quat2dcm(quat);
R = g'; % note: derotation uses R rather than M
[thetad, v] = derotation(R);

axang(1:3) = v(1:3);
axang(4) = thetad/180*pi;

end
