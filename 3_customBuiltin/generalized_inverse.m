% chenzhe 2017-09-21
% 
% L = left inverse, good for col-full-rank
% R = right inverse, good for row-full-rank
% P = pseudo, optimized

function [L,R,P] = generalized_inverse(A)
    L = inv(A'*A)*A';
    R = A'*inv(A*A');
    P = pinv(A);
end