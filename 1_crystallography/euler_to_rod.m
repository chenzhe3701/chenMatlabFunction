% This code is based on Sriram's code. The definition is also found in Rollet's slides. 
%
% Zhe Chen, 2016-6-16

function [rod]=euler_to_rod(euler_r)

%Euler angles phi1, PHI and phi2 are in radians
% euler(1)=phi1;  
% euler(2)=PHI;  
% euler(3)=phi2;  

% Rodrigues Vector  
rod=[tan(euler_r(2)/2)*cos((euler_r(1)-euler_r(3))/2)/cos((euler_r(1)+euler_r(3))/2),...
    tan(euler_r(2)/2)*sin((euler_r(1)-euler_r(3) )/2)/cos((euler_r(1)+euler_r(3))/2),...
    tan((euler_r(1)+euler_r(3))/2)]; 