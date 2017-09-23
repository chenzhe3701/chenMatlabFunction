% two similar orientations, but expressed in a very different way
E1 = [74,53,261]/180*pi         % euler angle-1
E2 = [255,126,278]/180*pi       % euler angle-2
hcp_cell_Mg(E1/pi*180);
hcp_cell_Mg(E2/pi*180);
calculate_misorientation_hcp(E1/pi*180,E2/pi*180)   % the two orientations are similar (Symmetry considered)
calculate_misorientation_hcp(E1/pi*180,[0 0 0])     % misorientation wrt "no-rotation" (Symmetry considered)
calculate_misorientation_hcp(E2/pi*180,[0 0 0])     % misorientation wrt "no-rotation" (Symmetry considered)

Q1 = angle2quat(E1(1),E1(2),E1(3),'zxz')    % convert to quaternion-1
Q2 = angle2quat(E2(1),E2(2),E2(3),'zxz')    % convert to quaternion-2
calculate_misorientation_quaternion_hcp(Q1,Q2)      % using the converted quaternion, the misorientation is still small (Symmetry considered)
% this shows that from misorientation point of view, the two quaternions represent similar orientation
calculate_misorientation_quaternion_hcp(Q1,[1 0 0 0])
calculate_misorientation_quaternion_hcp(Q2,[1 0 0 0])

Qa = (Q1+Q2)/quatmod(Q1+Q2)             % calculate the average orientation using Q1 and Q2, According to Rollet Paper
% calculate misorientation between Q1, Q2, and their avg orientation Qa
% they should be ~0, but turned out both to be ~90
        % using code to draw hexagons may be helpful for illustrating what happend
calculate_misorientation_quaternion_hcp(Q1,Qa)           
calculate_misorientation_quaternion_hcp(Q1,Qa)


[E11,E12,E13] = quat2angle(Q1,'zxz');   % convert back to euler angle expression
E1new = [E11,E12,E13]                       %  euler angel-1 is the same
[E21,E22,E23] = quat2angle(Q2,'zxz');
E2new = [E21,E22,E23]                       % but euler angle-2 is different
hcp_cell_Mg(E1new/pi*180);
hcp_cell_Mg(E2new/pi*180);          % However, if you plot, it still look the same.  %%%%%%% This means quat2angle(angle2quat()) does not solve the problem
calculate_misorientation_hcp(E1new/pi*180,E2/pi*180)    % misorientation keeps the same (Symmetry considered)
calculate_misorientation_hcp(E1new/pi*180,[0 0 0])     % misorientation wrt "no-rotation" (Symmetry considered)
calculate_misorientation_hcp(E2new/pi*180,[0 0 0])     % misorientation wrt "no-rotation" (Symmetry considered)

Q1new = angle2quat(E1new(1),E1new(2),E1new(3),'zxz')    % convert to quaternion-1
Q2new = angle2quat(E2new(1),E2new(2),E2new(3),'zxz')    % convert to quaternion-2
%%%%%%% The above still look quite similar to Q1, Q2, sign might be different
calculate_misorientation_quaternion_hcp(Q1new,Q2new)      % using the converted quaternion, the misorientation is still small (Symmetry considered)
% this shows that from misorientation point of view, the two quaternions represent similar orientation
calculate_misorientation_quaternion_hcp(Q1new,[1 0 0 0])    
calculate_misorientation_quaternion_hcp(Q2new,[1 0 0 0])

QaNew = (Q1new+Q2new)/quatmod(Q1new+Q2new)             % calculate the average orientation using Q1 and Q2, According to Rollet Paper
% calculate misorientation between Q1, Q2, and their avg orientation Qa
% they should be ~0, but turned out both to be ~90
        % using code to draw hexagons may be helpful for illustrating what happend
calculate_misorientation_quaternion_hcp(Q1new,QaNew)           
calculate_misorientation_quaternion_hcp(Q1new,QaNew)


