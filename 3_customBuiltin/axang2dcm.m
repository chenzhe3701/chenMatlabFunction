% The conversion is:
% axang->q, using 'axang2quat'
% q->dcm, using 'quat2dcm'
%
% chenzhe, 2021-03-08

function M = axang2dcm(axang)

q = axang2quat(axang);
M = quat2dcm(q);

end