% chenzhe, 2017-06-08
% deduce FCC Al crystal symmetry operation

function [S, M] = fcc_symmetry()
S = [1  0   0   0;
    0   1   0   0;
    0   0   1   0;
    0   0   0   1;
    1/sqrt(2)   1/sqrt(2)  0   0;
    1/sqrt(2)  -1/sqrt(2)  0   0;
    1/sqrt(2)   0   1/sqrt(2)   0;
   	1/sqrt(2)   0  -1/sqrt(2)   0;
    1/sqrt(2)   0   0   1/sqrt(2);
    1/sqrt(2)   0   0  -1/sqrt(2);
    1/2     1/2     1/2     1/2;
    1/2    -1/2    -1/2    -1/2;
    1/2     1/2    -1/2     1/2;
    1/2    -1/2     1/2    -1/2;    
    1/2    -1/2    -1/2     1/2;
    1/2     1/2     1/2    -1/2;    
    1/2    -1/2     1/2     1/2;
    1/2     1/2    -1/2    -1/2; 
    0   1/sqrt(2)   1/sqrt(2)  0;
    0  -1/sqrt(2)  1/sqrt(2)   0;
    0   1/sqrt(2)   0   1/sqrt(2);
    0   -1/sqrt(2)  0   1/sqrt(2);
    0   0   1/sqrt(2)   1/sqrt(2);
    0   0   -1/sqrt(2)  1/sqrt(2)];
for ii=1:size(S,1)
   M(:,:,ii) = quat2dcm(S(ii,:)); 
end

% % 4-fold about [1 0 0]
% A1 = [cosd(0),  sind(0),    sind(0),    sind(0);
%     cosd(45),   sind(45),   sind(45),   sind(45);
%     cosd(90),   sind(90),   sind(90),   sind(90);
%     cosd(135),  sind(135),  sind(135),  sind(135)];
% 
% B1 = repmat([1 1 0 0], 4,1);
% B2 = repmat([1 0 1 0], 4,1);
% B3 = repmat([1 0 0 1], 4,1);
% B4 = repmat([1 -1 0 0], 4,1);
% B5 = repmat([1 0 -1 0], 4,1);
% B6 = repmat([1 0 0 -1], 4,1);
% 
% AB = [A1.*B1; A1.*B2; A1.*B3; A1.*B4; A1.*B5; A1.*B6];
% 
% % 3-fold about [1 1 1]
% A2 = [cosd(0),  sind(0),    sind(0),    sind(0);
%     cosd(60),   sind(60),   sind(60),   sind(60);
%     cosd(120),   sind(120),   sind(120),   sind(120)];
% C1 = repmat([1 1/sqrt(3) 1/sqrt(3) 1/sqrt(3)], 3,1);
% C2 = repmat([1 1/sqrt(3) -1/sqrt(3) 1/sqrt(3)], 3,1);
% C3 = repmat([1 -1/sqrt(3) -1/sqrt(3) 1/sqrt(3)], 3,1);
% C4 = repmat([1 -1/sqrt(3) 1/sqrt(3) 1/sqrt(3)], 3,1);
% C5 = repmat([1 1/sqrt(3) 1/sqrt(3) -1/sqrt(3)], 3,1);
% C6 = repmat([1 1/sqrt(3) -1/sqrt(3) -1/sqrt(3)], 3,1);
% C7 = repmat([1 -1/sqrt(3) -1/sqrt(3) -1/sqrt(3)], 3,1);
% C8 = repmat([1 -1/sqrt(3) 1/sqrt(3) -1/sqrt(3)], 3,1);
% AC = [A2.*C1; A2.*C2; A2.*C3; A2.*C4; A2.*C5; A2.*C6; A2.*C7; A2.*C8];
% 
% % 2-fold about [1 1 0]
% A3 = [cosd(0),  sind(0),    sind(0),    sind(0);
%     cosd(90),   sind(90),   sind(90),   sind(90)];
% D1 = repmat([1 1/sqrt(2) 1/sqrt(2) 0], 2,1);
% D2 = repmat([1 1/sqrt(2) -1/sqrt(2) 0], 2,1);
% D3 = repmat([1 -1/sqrt(2) -1/sqrt(2) 0], 2,1);
% D4 = repmat([1 -1/sqrt(2) 1/sqrt(2) 0], 2,1);
% D5 = repmat([1 1/sqrt(2) 0 1/sqrt(2)], 2,1);
% D6 = repmat([1 1/sqrt(2) 0 -1/sqrt(2)], 2,1);
% D7 = repmat([1 -1/sqrt(2) 0 -1/sqrt(2)], 2,1);
% D8 = repmat([1 -1/sqrt(2) 0 1/sqrt(2)], 2,1);
% D9 = repmat([1 0 1/sqrt(2) 1/sqrt(2)], 2,1);
% D10 = repmat([1 0 1/sqrt(2) -1/sqrt(2)], 2,1);
% D11 = repmat([1 0 -1/sqrt(2) -1/sqrt(2)], 2,1);
% D12 = repmat([1 0 -1/sqrt(2) 1/sqrt(2)], 2,1);
% AD = [A3.*D1; A3.*D2; A3.*D3; A3.*D4; A3.*D5; A3.*D6; A3.*D7; A3.*D8; A3.*D9; A3.*D10; A3.*D11; A3.*D12];
% 
% A = [AB;AC;AD];
% iRow = 1;
% while (iRow<size(A,1))
%     ind = [];
%     for ii=iRow+1:size(A,1)
%         if isequal(A(iRow,:),A(ii,:))||isequal(A(iRow,:),-A(ii,:))
%             ind = [ind;ii];
%         end
%     end
%     A(ind,:) = [];
%     iRow = iRow + 1;
% end


end





