function calculate_strain_LagrangeOnInterp(matfile, subset_size, fit_val)
% Appends strain data onto csv data of X, Y, u, and v data. X and Y should
% be in the reference configuration and u and v should be defined as
% X + u = x and Y + v = y, where x,y is the deformed configuration.
%
% The code is setup to take advantage of parallel computing within MATLAB
% through the use of matlabpool and the Parallel Processing Toolbox (if
% avaiable). Each instance of calculate_strain can run completely
% independantly in its own matlabpool helper. The recommendation for
% parallel operation is to call an iteration of calculate_strain in a
% parfor loop for a predetermined list of matfile names.
%
% Supported strain_types are: 'Lagrange', 'Biot', 'Logrithmic'
%
% Currently only 2-D strain definitions are supported, however the code is
% writtent to easily expand into 3-D in the eventuality.
%
% Subset size is the halfwidth - 0.5 of the box used to partition data for
% the strain calculation. I.e. to calculate strain in 3x3 boxed subsets
% (the minimum size) the subset_size should be set to 1.
%
% chenzhe2017-05-14, to make this work in interpolated u and v, ignore the
% sigma~=1 criterion in calculating strain, because I didn't change the
% sigma after interpolating the u and v.

switch nargin
    case 0
        % Choose mat data
        [f, p] = uigetfile({'*.mat', 'MAT Data File'},...
            'Select Displacement Data File');
        matfile = [p f];
        
        % Choose subset size
        prompt = strcat('Input Subset Size. Subset size is ',...
            'the halfwidth - 0.5 of the box used to partition data for  ',...
            'the strain calculation. I.e. to calculate strain in 3x3  ',...
            'boxed subsets (the minimum size) the subset_size should  ',...
            'be set to 1.');
        subset_size_string = inputdlg({prompt}, '', 1, {'3'});
        subset_size = str2double(subset_size_string);
        
        % Choose fittype
        prompt = strcat('Input fit type. Planar = 1, BiQuadratic = 2,',...
            'BiCubic = 3');
        fittype_string = inputdlg({prompt}, '', 1, {'3'});
        fit_val = round(str2double(fittype_string));
    case 1
        % Extract filename
        f = matfile(max(strfind(matfile, '\'))+1:end);
        
        % Choose subset size
        prompt = strcat('Input Subset Size. Subset size is ',...
            'the halfwidth - 0.5 of the box used to partition data for  ',...
            'the strain calculation. I.e. to calculate strain in 3x3  ',...
            'boxed subsets (the minimum size) the subset_size should  ',...
            'be set to 1.');
        subset_size_string = inputdlg({prompt}, '', 1, {'3'});
        subset_size = str2double(subset_size_string);
        
        % Choose fittype
        prompt = strcat('Input fit type. Planar = 1, BiQuadratic = 2,',...
            'BiCubic = 3');
        fittype_string = inputdlg({prompt}, '', 1, {'3'});
        fit_val = str2double(fittype_string);
    case 2
        % Choose fittype
        prompt = strcat('Input fit type. Planar = 1, BiQuadratic = 2,',...
            'BiCubic = 3');
        fittype_string = inputdlg({prompt}, '', 1, {'3'});
        fit_val = str2double(fittype_string);
    otherwise
        % Extract filename
        f = matfile(max(strfind(matfile, '\'))+1:end);
end

% Set minimum strain box size
if subset_size < 1
    subset_size = 1;
end

% set fittype limits
fit_val = round(fit_val);
if fit_val < 1
    fit_val = 1;
elseif fit_val > 3
    fit_val = 3;
end


% Import Reference Data
try
    a=load(matfile, 'x', 'y', 'u' , 'v', 'sigma');
    X=a.x;
    Y=a.y;
    U=a.u;
    V=a.v;
    sigma=a.sigma;
catch
    a=load(matfile, 'X', 'Y', 'U' , 'V', 'sigma');
    X=a.X;
    Y=a.Y;
    U=a.U;
    V=a.V;
    sigma=a.sigma;
end



% Calculate deformed values
x = X + U; %#ok<*NODEF>
y = Y + V;

% Reshape and partition
n = length(unique(Y));
m = length(unique(X));

exx_Lagrange = zeros(n,m);
exy_Lagrange = zeros(n,m);
eyy_Lagrange = zeros(n,m);



warning('off', 'MATLAB:rankDeficientMatrix');

for ii = 1:n
    for jj = 1:m
        Xcell = ...
            X(max([1 ii-subset_size]):min([n ii+subset_size]), max([1 jj-subset_size]):min([m jj+subset_size]));
        Ycell = ...
            Y(max([1 ii-subset_size]):min([n ii+subset_size]), max([1 jj-subset_size]):min([m jj+subset_size]));
        xcell = ...
            x(max([1 ii-subset_size]):min([n ii+subset_size]), max([1 jj-subset_size]):min([m jj+subset_size]));
        ycell = ...
            y(max([1 ii-subset_size]):min([n ii+subset_size]), max([1 jj-subset_size]):min([m jj+subset_size]));
        scell = ...
            sigma(max([1 ii-subset_size]):min([n ii+subset_size]), max([1 jj-subset_size]):min([m jj+subset_size]));
        
        X_point = X(ii,jj);
        Y_point = Y(ii,jj);
        
        % Determine fit coeffiecients for x,y in terms of X,Y
        
        
        OK = (~isnan(xcell(:))) & (~isnan(ycell(:)));
        
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
                    A = [XX YY ones(size(YY))];
                case 2
                    %  poly22 model
                    % (x,y) = aX^2 + bY^2 + cXY + dX + eY + f
                    A = [XX.^2 YY.^2 XX.*YY XX YY ones(size(YY))];
                case 3
                    %  poly33 model
                    % (x,y) = aX^3 + bY^3 + cX^2Y + dXY^2 + eX^2 + fY^2 +
                    %              gXY + hX + iY + j
                    A = [XX.^3 YY.^3 XX.^2.*YY XX.*YY.^2 XX.^2 ...
                        YY.^2 XX.*YY XX YY ones(size(YY))];
            end
            coeff_x = A\xx;
            coeff_y = A\yy;
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
            
            F = [dx_dX dx_dY; dy_dX dy_dY];
            
            % Calculate U tensors
            U = sqrtm(F'*F);
            
            %Determine strain values at each point
            ELagrange = 1/2*(U*U - eye(2));

        else
            ELagrange = [NaN NaN; NaN NaN];

        end
        
        exx_Lagrange(ii,jj) = ELagrange(1,1); %#ok<*PFOUS>
        exy_Lagrange(ii,jj) = ELagrange(1,2);
        eyy_Lagrange(ii,jj) = ELagrange(2,2);
        

    end
    if rem(ii,100)==0
        disp(['finished ',num2str(ii),' of ',num2str(n),' lines']);
    end
end

warning('on', 'MATLAB:rankDeficientMatrix');

save(matfile, 'exx_Lagrange', 'exy_Lagrange', 'eyy_Lagrange', '-append')
disp(['...' matfile ' DONE!'])
clear
