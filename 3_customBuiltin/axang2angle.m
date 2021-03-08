% Convert axis-angle to euler angle
% The conversion is:
% axang->dcm, using custom functin 'axang2dcm', which include two steps
% (explicitly as)
%     axang->q, using 'axang2quat'
%     q->dcm, using 'quat2dcm'
%
% chenzhe, 2021-03-08

function [r1,r2,r3, eulerd] = axang2angle(axang, varargin)

% This is my custom function M = axang2dcm(axang)
q = axang2quat(axang);
M = quat2dcm(q);

% using built-in function 'dcm2angle'
[r1,r2,r3] = dcm2angle(M, varargin{:});

euler = [r1, r2, r3];
eulerd = euler/pi*180;

end
