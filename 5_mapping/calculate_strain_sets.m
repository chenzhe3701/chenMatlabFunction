% Chenzhe 2016-2-11
%
% function [e_Lagrange, e_Biot, e_Logrithmic, e_Small, R_Small, e_Almansi]...
%     = calculate_strain_area(X,Y,u,v,sigma, subset_size, fit_val)
%
% Calculate strain based on inputs, which is just a set of values of
% u/v/x/y.  All input value is used regardless of the location from which
% they come from, i.e., data can come from neighborhood of a slip trace,
% rather than a square.  In fact, most likely the data will not come from a
% square.  So, the calculation is not strickly following the definition of
% finite strain of calculating the change of the size of a 'square', but
% this gives us more options to examine how the relationship between
% u/v/x/y looks like.

function [ELagrange, EBiot, ELogrithmic, ESmall, R, EAlmansi]...
    = calculate_strain_sets(X,Y,u,v,sigma,fit_val)
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


% set fittype limits.  
% method 4 gives almost same result as 2, so no need to run method-4
fit_val = round(fit_val);
if fit_val < 1
    fit_val = 1;
elseif fit_val > 3
    fit_val = 3;
end

% Calculate deformed values
x = X + u;
y = Y + v;

warning('off', 'MATLAB:rankDeficientMatrix');

X_point = nanmean(X(:));
Y_point = nanmean(Y(:));
if length(sigma)~=length(X)
    sigma = zeros(size(X));
end
% Determine fit coeffiecients for x,y in terms of X,Y

OK = (sigma(:) ~= -1) & (~isnan(X(:))) & (~isnan(Y(:)));

switch fit_val
    case 1
        min_pts = 6;
    case 2
        min_pts = 12;
    case 3
        min_pts = 20;
    case 4
        min_pts = 12;
end


if sum(OK) >= min_pts;
    
    XX = X(OK);
    YY = Y(OK);
    xx = x(OK);
    yy = y(OK);
    
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
%         case 4
%             %  poly22 model
%             % (x,y) = aX^2 + bY^2 + cXY + dX + eY + f
%             A = [XX.^2,  YY.^2,  XX.*YY,  XX,  YY,  ones(size(YY))];
%             fitType = fittype('poly22');
%             fittedx = fit([X,Y],x,fitType);
%             fittedy = fit([X,Y],y,fitType);
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
%         case 4
%             coeff_x = [fittedx.p20; fittedx.p02; fittedx.p11; fittedx.p10; fittedx.p01; fittedx.p00];     % A*coeff_x = xx
%             coeff_y = [fittedy.p20; fittedy.p02; fittedy.p11; fittedy.p10; fittedy.p01; fittedy.p00];     % A*coeff_y = yy
%             dx_dX = ...
%                 2*coeff_x(1)*X_point + coeff_x(3)*Y_point + coeff_x(4);
%             dx_dY = ...
%                 2*coeff_x(2)*Y_point + coeff_x(3)*X_point + coeff_x(5);
%             dy_dX = ...
%                 2*coeff_y(1)*X_point + coeff_y(3)*Y_point + coeff_y(4);
%             dy_dY = ...
%                 2*coeff_y(2)*Y_point + coeff_y(3)*X_point + coeff_y(5);
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


warning('on', 'MATLAB:rankDeficientMatrix');

% This is a gaussian filter.  May not use.
% exx_Lagrange = filter2(fspecial('gaussian',2*subset_size+1,0.37),exx_Lagrange,'same');

end
