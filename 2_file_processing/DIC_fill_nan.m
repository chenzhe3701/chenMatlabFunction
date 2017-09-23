% [Zhe Chen] 2015-10-28
%
% After fix DIC data with patches, fill the holes.
% If a point is within 50 DIC data points from boundary of picture, do not fill

directory_b = uigetdir('','choose base directory');
directory_n = uigetdir('','choose new directory');

baseFiles = dir([directory_b '\*.mat']);
baseFiles = struct2cell(baseFiles);
baseFiles = baseFiles(1,:)';

for iFiles = 1:length(baseFiles)
    close all;
    % import data of base map, -- the whole base map
    data_1 = load([directory_b,'\',baseFiles{iFiles}]);
    x = data_1.x;
    y = data_1.y;
    u = data_1.u;
    v = data_1.v;
    sigma = data_1.sigma;
    exx = data_1.exx;
    exy = data_1.exy;
    eyy = data_1.eyy;
    
    ind_nan = (sigma == -1);    % index for sigma=-1 points
    ind_num = double(sigma ~= -1);
    filter1 = [ones(1,50), zeros(1,49)];
    filter2 = [zeros(1,49), ones(1,50)];
    filter3 = [ones(50,1); zeros(49,1)];
    filter4 = [zeros(49,1); ones(50,1)];
    ind_frame = conv2(ind_num,filter1,'same')==0|conv2(ind_num,filter2,'same')==0|...
        conv2(ind_num,filter3,'same')==0|conv2(ind_num,filter4,'same')==0;
    
    u(ind_nan) = nan;
    v(ind_nan) = nan;
    exx(ind_nan) = nan;
    exy(ind_nan) = nan;
    eyy(ind_nan) = nan;
    sigma(ind_nan) = nan;
    
    % interpolate/extrapolate
    u = inpaint_nans(u,4);
    v = inpaint_nans(v,4);
    exx = inpaint_nans(exx,4);
    exy = inpaint_nans(exy,4);
    eyy = inpaint_nans(eyy,4);
    sigma = inpaint_nans(sigma,4);
    
    % fill frame regions back with 0
    u(ind_frame) = 0;
    v(ind_frame) = 0;
    exx(ind_frame) = 0;
    exy(ind_frame) = 0;
    eyy(ind_frame) = 0;
    sigma(ind_frame) = -1;    
    
    save([directory_n,'\',baseFiles{iFiles}],'x','y','u','v','sigma','exx','exy','eyy');
end
