% Chenzhe, 2016-2-10;
% Elastic constants of Titanium
function [C,S] = elastic_constant(str)

if strcmpi(str,'Ti')
    
    % C, GPa
    C11 = 160;  C33 = 181;  C44 = 46.5; C12 = 90;   C13 = 66;   % Ti
    % S, TPa^-1;
    S11 = 9.62; S33 = 6.84;     S44 = 21.5;     S12 = -4.67;    S13 = -1.81;    % Ti
elseif strcmpi(str,'Mg')
    % C, GPa
    C11 = 59.7; C33 = 61.7; C44 = 16.4; C12 = 26.2; C13 = 21.7; % Mg
    % S, TPa^-1;
    S11 = 22;   S33 = 19.71;    S44 = 61.01;    S12 = -7.86;    S13 = -4.97;    % Mg
end

S = [S11, S12, S13, 0, 0, 0;
    S12, S11, S13, 0, 0, 0;
    S13, S13, S33, 0, 0, 0;
    0, 0, 0, S44, 0, 0;
    0, 0, 0, 0, S44, 0;
    0, 0, 0, 0, 0, 2*(S11-S12)];

C = [C11, C12, C13, 0, 0, 0;
    C12, C11, C13, 0, 0, 0;
    C13, C13, C33, 0, 0, 0;
    0, 0, 0, C44, 0, 0;
    0, 0, 0, 0, C44, 0;
    0, 0, 0, 0, 0, 0.5*(C11-C12)];
end