% this is generation for each point, so it should be very slow
%
% chenzhe, 2019-10-29,
% modify to take input phi_sys

function RGBout = generate_IPF_map_in_ND(x,y,phi1,phi,phi2,boundaryTF,phi_sys)
if size(x,2)==1     % if input is not matrix, change it to matrix
    uniqueX = unique(x(:));
    uniqueY = unique(y(:));
    m = length(uniqueX);
    n = length(uniqueY);
    transposeTF = x(2)-x(1);
    if transposeTF == 1
        x = reshape(x,m,n)';
        y = reshape(y,m,n)';
        boundaryTF = reshape(boundaryTF,m,n)';
        phi1 = reshape(phi1,m,n)';
        phi = reshape(phi,m,n)';
        phi2 = reshape(phi2,m,n)';
    elseif transposeTF == 0;
        x = reshape(x,n,m);
        y = reshape(y,n,m);
        boundaryTF = reshape(boundaryTF,n,m);
        phi1 = reshape(phi1,n,m);
        phi = reshape(phi,n,m);
        phi2 = reshape(phi2,n,m);
    end
end

for ii = 1:size(x,1)
    for jj = 1:size(x,2)
        if boundaryTF(ii,jj) == 1
            RGB = [0 0 0];
        else
            RGB = calculate_IPF_color_hcp([phi1(ii,jj),phi(ii,jj),phi2(ii,jj)], phi_sys, [0 0 1]);
        end
        R(ii,jj) = RGB(1);
        G(ii,jj) = RGB(2);
        B(ii,jj) = RGB(3);
    end
end

RGBout(:,:,1) = R;
RGBout(:,:,2) = G;
RGBout(:,:,3) = B;