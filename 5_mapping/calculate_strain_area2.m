% Chenzhe 2016-2-11
%
% function [e_Lagrange, e_Biot, e_Logrithmic, e_Small, R_Small, e_Almansi]...
%     = calculate_strain_area(X,Y,u,v,sigma, subset_size, fit_val)
%
% Calculate strain within an area, based on inputs which gives the
% displacement data, and other variables

function [e_Lagrange, e_Biot, e_Logrithmic, e_Small, R_Small, e_Almansi]...
    = calculate_strain_area(X,Y,u,v,sigma, filterSize)
% X and Y should be in the reference configuration and u and v should be
% defined as X + u = x and Y + v = y, where x,y is the deformed
% configuration.
%
% Supported strain_types are: 'Lagrange', 'Biot', 'Logrithmic'
%
% Subset size is the halfwidth - 0.5 of the box used to partition data for
% the strain calculation. I.e. to calculate strain in 3x3 boxed subsets
% (the minimum size) the subset_size should be set to 1;

% fittype, Planar = 1, BiQuadratic = 2, BiCubic = 3;


% Set minimum strain box size
subset_size = 1;    % use this to make it same as vic2D.  Always use 3x3 to calculate strain. Use filter to adjust smoothness.
% if subset_size < 1
%     subset_size = 1;
% end

% set fittype limits
fit_val = 1;    % use this to make it same as vic2D.  Do not select order of fitting, and use the simplest relationship to calculate strain.
% fit_val = round(fit_val);
% if fit_val < 1
%     fit_val = 1;
% elseif fit_val > 3
%     fit_val = 3;
% end

% Calculate deformed values
x = X + u;
y = Y + v;

% Reshape and partition
[nRow, nCol] = size(X);

exx_Lagrange = zeros(nRow,nCol);
exy_Lagrange = zeros(nRow,nCol);
eyy_Lagrange = zeros(nRow,nCol);

exx_Biot = zeros(nRow,nCol);
exy_Biot = zeros(nRow,nCol);
eyy_Biot = zeros(nRow,nCol);

exx_Logrithmic = zeros(nRow,nCol);
exy_Logrithmic = zeros(nRow,nCol);
eyy_Logrithmic = zeros(nRow,nCol);

exx_Small = zeros(nRow,nCol);
exy_Small = zeros(nRow,nCol);
eyy_Small = zeros(nRow,nCol);

Rxx_Small = zeros(nRow,nCol);
Rxy_Small = zeros(nRow,nCol);
Ryy_Small = zeros(nRow,nCol);

exx_Almansi = zeros(nRow,nCol);
exy_Almansi = zeros(nRow,nCol);
eyy_Almansi = zeros(nRow,nCol);


warning('off', 'MATLAB:rankDeficientMatrix');

for ii = 1:nRow
    for jj = 1:nCol
        Xcell = X(max([1 ii-subset_size]):min([nRow ii+subset_size]),...
            max([1 jj-subset_size]):min([nCol jj+subset_size]));
        Ycell = Y(max([1 ii-subset_size]):min([nRow ii+subset_size]),...
            max([1 jj-subset_size]):min([nCol jj+subset_size]));
        xcell = x(max([1 ii-subset_size]):min([nRow ii+subset_size]),...
            max([1 jj-subset_size]):min([nCol jj+subset_size]));
        ycell = y(max([1 ii-subset_size]):min([nRow ii+subset_size]),...
            max([1 jj-subset_size]):min([nCol jj+subset_size]));
        scell = sigma(max([1 ii-subset_size]):min([nRow ii+subset_size]),...
            max([1 jj-subset_size]):min([nCol jj+subset_size]));
        
        X_point = X(ii,jj);
        Y_point = Y(ii,jj);
        
        % Determine fit coeffiecients for x,y in terms of X,Y
        
        OK = (scell(:) ~= -1) & (~isnan(xcell(:))) & (~isnan(ycell(:)));
        
        switch fit_val
            case 1
                min_pts = 6;
            case 2
                min_pts = 12;
            case 3
                min_pts = 20;
        end
        
        if sum(OK) >= min_pts;
            
            XX = Xcell(OK);
            YY = Ycell(OK);
            xx = xcell(OK);
            yy = ycell(OK);
            
            switch fit_val
                case 1
                    %  poly11 model
                    % (x,y) = aX + bY + c
                    A = [XX, YY, ones(size(YY))];
                case 2
                    %  poly22 model
                    % (x,y) = aX^2 + bY^2 + cXY + dX + eY + f
                    A = [XX.^2,  YY.^2,  XX.*YY,  XX,  YY,  ones(size(YY))];
                case 3
                    %  poly33 model
                    % (x,y) = aX^3 + bY^3 + cX^2Y + dXY^2 + eX^2 + fY^2 +
                    %              gXY + hX + iY + j
                    A = [XX.^3,  YY.^3,  XX.^2.*YY,  XX.*YY.^2,  XX.^2, ...
                        YY.^2,  XX.*YY,  XX,  YY,  ones(size(YY))];
            end
            coeff_x = A\xx;     % A*coeff_x = xx
            coeff_y = A\yy;     % A*coeff_y = yy
            switch fit_val
                case 1
                    dx_dX = coeff_x(1);
                    dx_dY = coeff_x(2);
                    dy_dX = coeff_y(1);
                    dy_dY = coeff_y(2);
                case 2
                    dx_dX = ...
                        2*coeff_x(1)*X_point + coeff_x(3)*Y_point + coeff_x(4);
                    dx_dY = ...
                        2*coeff_x(2)*Y_point + coeff_x(3)*X_point + coeff_x(5);
                    dy_dX = ...
                        2*coeff_y(1)*X_point + coeff_y(3)*Y_point + coeff_y(4);
                    dy_dY = ...
                        2*coeff_y(2)*Y_point + coeff_y(3)*X_point + coeff_y(5);
                case 3
                    dx_dX = ...
                        3*coeff_x(1)*X_point^2 + 2*coeff_x(3)*X_point*Y_point ...
                        + coeff_x(4)*Y_point^2 +2*coeff_x(5)*X_point ...
                        + coeff_x(7)*Y_point + coeff_x(8);
                    dx_dY = ...
                        3*coeff_x(2)*Y_point^2 + coeff_x(3)*X_point^2 ...
                        + 2*coeff_x(4)*X_point*Y_point +2*coeff_x(6)*Y_point ...
                        + coeff_x(7)*X_point + coeff_x(9);
                    dy_dX = ...
                        3*coeff_y(1)*X_point^2 + 2*coeff_y(3)*X_point*Y_point ...
                        + coeff_y(4)*Y_point^2 +2*coeff_y(5)*X_point ...
                        + coeff_y(7)*Y_point + coeff_y(8);
                    dy_dY = ...
                        3*coeff_y(2)*Y_point^2 + coeff_y(3)*X_point^2 ...
                        + 2*coeff_y(4)*X_point*Y_point +2*coeff_y(6)*Y_point ...
                        + coeff_y(7)*X_point + coeff_y(9);
            end
            
            F = [dx_dX dx_dY; dy_dX dy_dY];     % deformation gradient
            
            % Calculate U tensors (stretch)
            U = sqrtm(F'*F);
            R = F/U;
            
            %Determine strain values at each point
            ELagrange = 1/2*(U*U - eye(2));
            EBiot = U - eye(2);
            ELogrithmic = logm(U);
            ESmall = 1/2*(F + F') - eye(2);
            EAlmansi = 1/2*(eye(2) - inv(F*F'));
        else
            U = [NaN NaN; NaN NaN];
            R = [NaN NaN; NaN NaN];
            
            ELagrange = [NaN NaN; NaN NaN];
            EBiot = [NaN NaN; NaN NaN];
            ELogrithmic = [NaN NaN; NaN NaN];
            ESmall = [NaN NaN; NaN NaN];
            EAlmansi = [NaN NaN; NaN NaN];
        end
        
        exx_Lagrange(ii,jj) = ELagrange(1,1);
        exy_Lagrange(ii,jj) = ELagrange(1,2);
        eyy_Lagrange(ii,jj) = ELagrange(2,2);
        
        exx_Biot(ii,jj) = EBiot(1,1);
        exy_Biot(ii,jj) = EBiot(1,2);
        eyy_Biot(ii,jj) = EBiot(2,2);
        
        exx_Logrithmic(ii,jj) = ELogrithmic(1,1);
        exy_Logrithmic(ii,jj) = ELogrithmic(1,2);
        eyy_Logrithmic(ii,jj) = ELogrithmic(2,2);
        
        exx_Small(ii,jj) = ESmall(1,1);
        exy_Small(ii,jj) = ESmall(1,2);
        eyy_Small(ii,jj) = ESmall(2,2);
        
        Rxx_Small(ii,jj) = R(1,1);
        Rxy_Small(ii,jj) = R(1,2);
        Ryy_Small(ii,jj) = R(2,2);
        
        exx_Almansi(ii,jj) = EAlmansi(1,1);
        exy_Almansi(ii,jj) = EAlmansi(1,2);
        eyy_Almansi(ii,jj) = EAlmansi(2,2);
    end
    ii
end

warning('on', 'MATLAB:rankDeficientMatrix');

% This is a gaussian filter.  
if rem(filterSize,2)==0
    filterSize = filterSize+1;
    display('filter size used: ',num2str(filterSize));
end
myFilter = fspecial('gaussian',filterSize);

exx_Lagrange = filter2(fspecial('gaussian',2*subset_size+1,0.37),exx_Lagrange,'same');


e_Lagrange = cat(3, exx_Lagrange, exy_Lagrange, eyy_Lagrange);
e_Biot = cat(3, exx_Biot, exy_Biot, eyy_Biot);
e_Logrithmic = cat(3, exx_Logrithmic, exy_Logrithmic, eyy_Logrithmic);
e_Small = cat(3, exx_Small, exy_Small, eyy_Small);
R_Small = cat(3, Rxx_Small, Rxy_Small, Ryy_Small);
e_Almansi = cat(3, exx_Almansi, exy_Almansi, eyy_Almansi);

if rem(filterSize,2)==0
    filterSize = filterSize+1;
    display('filter size used: ',num2str(filterSize));
end
myFilter = fspecial('gaussian',filterSize);

end
