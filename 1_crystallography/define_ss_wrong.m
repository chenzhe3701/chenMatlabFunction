% ssa = define_ss(str1, str2); give material name in str1, such as 'Ti'.
% If want to include twin, use str2 = 'twin'.
% Return ssa which is slip systems.
% ssa(1,:,#) = slip plane for slip system #
% ssa(2,:,#) = slip direction for slip system #
% Zhe Chen, 2015-11-02

function [ssa, c_a] = define_ss(str1,str2)
if strcmpi(str1,'Ti')
    c_a = 1.58;
    %  basal <a>-glide
    ssa(:,:,1) = [0 0 0 1; 2 -1 -1 0];
    ssa(:,:,2) = [0 0 0 1; -1 2 -1 0];
    ssa(:,:,3) = [0 0 0 1; -1 -1 2 0];
    %  prism <a>-glide
    ssa(:,:,4) = [0 1 -1 0; 2 -1 -1 0];
    ssa(:,:,5) = [1 0 -1 0; -1 2 -1 0];
    ssa(:,:,6) = [-1 1 0 0; -1 -1 2 0];
    %  pyramidal <a>-glide
    ssa(:,:,7) = [0 1 -1 1; 2 -1 -1 0];
    ssa(:,:,8) = [1 0 -1 1; -1 2 -1 0];
    ssa(:,:,9) = [-1 1 0 1; -1 -1 2 0];
    ssa(:,:,10) = [0 -1 1 1; 2 -1 -1 0];
    ssa(:,:,11) = [-1 0 1 1; -1 2 -1 0];
    ssa(:,:,12) = [1 -1 0 1; -1 -1 2 0];
    %  pyramidal <c+a>-glide -- Note 2016-Jan  these should be changed so
    %  that they are in the same sequence as in ss#7-12
    ssa(:,:,13) = [1 0 -1 1; 2 -1 -1 -3];
    ssa(:,:,14) = [1 0 -1 1; 1 1 -2 -3];
    ssa(:,:,15) = [0 1 -1 1; 1 1 -2 -3];
    ssa(:,:,16) = [0 1 -1 1; -1 2 -1 -3];
    ssa(:,:,17) = [-1 1 0 1; -1 2 -1 -3];
    ssa(:,:,18) = [-1 1 0 1; -2 1 1 -3];
    ssa(:,:,19) = [-1 0 1 1; -2 1 1 -3];
    ssa(:,:,20) = [-1 0 1 1; -1 -1 2 -3];
    ssa(:,:,21) = [0 -1 1 1; -1 -1 2 -3];
    ssa(:,:,22) = [0 -1 1 1; 1 -2 1 -3];
    ssa(:,:,23) = [1 -1 0 1; 1 -2 1 -3];
    ssa(:,:,24) = [1 -1 0 1; 2 -1 -1 -3];
    if strcmpi(str2,'twin')
        % extension twin type-1
        ssa(:,:,25) = [1 0 -1 2; -1 0 1 1];
        ssa(:,:,26) = [0 1 -1 2; 0 -1 1 1];
        ssa(:,:,27) = [-1 1 0 2; 1 -1 0 1];
        ssa(:,:,28) = [-1 0 1 2; 1 0 -1 1];
        ssa(:,:,29) = [0 -1 1 2; 0 1 -1 1];
        ssa(:,:,30) = [1 -1 0 2; -1 1 0 1];
    end
else
    disp('no ss data for this material.');
    ssa = [];
    c_a = [];
end