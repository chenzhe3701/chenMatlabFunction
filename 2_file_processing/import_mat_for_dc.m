% [ZChen note] 
% This funct MODIFIES the mat file themselves in the input directory.
% The original mat file has x, x_c, y, y_c, u, u_c, v, v_c, sigma.
% But only x, y, u, v, sigma are loaded
% Then the variable names are changed in the output file to be:
% X, Y, U, V, sigma, U_r, V_r
%
% edit 2017-05-09 put this function into my folder so it can be used outside of distortion correctin code

function import_mat_for_dc(directory)

if ~strcmp(directory(end), '\')
    directory = [directory '\'];
end

VIC2Dmats = dir([directory '*.mat']);
VIC2Dmats = struct2cell(VIC2Dmats);
VIC2Dmats = VIC2Dmats(1,:)';

for ii = 1:length(VIC2Dmats)
  
    matdata = load([directory VIC2Dmats{ii}]);
    
    try
    X = matdata.x;
    Y = matdata.y;
    U_r = matdata.u;
    V_r = matdata.v;
    sigma = matdata.sigma;
    catch
    X = matdata.X;
    Y = matdata.Y;
    U_r = matdata.U;
    V_r = matdata.V;
    sigma = matdata.sigma;   
    end
    
    
    U = U_r;
    V = V_r;
       
    savename = [directory VIC2Dmats{ii}];
    
    save(savename, 'X', 'Y', 'U', 'V', 'sigma', 'U_r', 'V_r', '-append');
 
end