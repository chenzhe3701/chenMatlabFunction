% [Zhe Chen] 2015-10-27
% large DIC maps can have some regions not identified.
% DIC can run on these regions, and we can use runs on these smaller regions to
% fix the large DIC data.

directory_b = uigetdir('','choose base directory');
directory_n = uigetdir('','choose new directory');
baseFiles = dir([directory_b '\*.mat']);
baseFiles = struct2cell(baseFiles);
baseFiles = baseFiles(1,:)';

%%
directory_p = uigetdir('','choose patch directory');
patchFiles = dir([directory_p '\*.mat']);
patchFiles = struct2cell(patchFiles);
patchFiles = patchFiles(1,:)';

for iFiles = 1:length(baseFiles)
    close all;
    ind_patch_file = find(strcmpi(baseFiles{iFiles},patchFiles));
    if ~isempty(ind_patch_file)
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
        
        % import data of patch map, -- the smaller map
        data_2 = load([directory_p,'\',patchFiles{ind_patch_file}]);
        x2 = data_2.x;
        y2 = data_2.y;
        u2 = data_2.u;
        v2 = data_2.v;
        sigma2 = data_2.sigma;
        exx2 = data_2.exx;
        exy2 = data_2.exy;
        eyy2 = data_2.eyy;
        
        % make data_2 range within data_1
        ind_c_data2_1 = find(x2(1,:) == min(x(:)));
        if isempty(ind_c_data2_1)
            ind_c_data2_1 = 1;
        end
        
        ind_c_data2_2 = find(x2(1,:) == max(x(:)));
        if isempty(ind_c_data2_2)
            ind_c_data2_2 = size(x2, 2);
        end
        
        ind_r_data2_1 = find(y2(:,1) == min(y(:)));
        if isempty(ind_r_data2_1)
            ind_r_data2_1 = 1;
        end
        
        ind_r_data2_2 = find(y2(:,1) == max(y(:)));
        if isempty(ind_r_data2_2)
            ind_r_data2_2 = size(y2, 1);
        end
        
        x2 = x2(ind_r_data2_1:ind_r_data2_2, ind_c_data2_1:ind_c_data2_2);
        y2 = y2(ind_r_data2_1:ind_r_data2_2, ind_c_data2_1:ind_c_data2_2);
        u2 = u2(ind_r_data2_1:ind_r_data2_2, ind_c_data2_1:ind_c_data2_2);
        v2 = v2(ind_r_data2_1:ind_r_data2_2, ind_c_data2_1:ind_c_data2_2);
        sigma2 = sigma2(ind_r_data2_1:ind_r_data2_2, ind_c_data2_1:ind_c_data2_2);
        exx2 = exx2(ind_r_data2_1:ind_r_data2_2, ind_c_data2_1:ind_c_data2_2);
        exy2 = exy2(ind_r_data2_1:ind_r_data2_2, ind_c_data2_1:ind_c_data2_2);
        eyy2 = eyy2(ind_r_data2_1:ind_r_data2_2, ind_c_data2_1:ind_c_data2_2);
        
        
        
        % matrix to hold patch data, regions outside of patch filled with zero/one/nan
        u_p = zeros(size(u));
        v_p = zeros(size(u));
        exx_p = zeros(size(u));
        exy_p = zeros(size(u));
        eyy_p = zeros(size(u));
        sigma_p = ones(size(u))*(-1);
        % make map_B the same size as map_A, fill missing values properly
        ind_c_min = find(x(1,:)==min(x2(1,:)));
        if isempty(ind_c_min)
            ind_c_min = 1;
        end
        ind_c_max = find(x(1,:)==max(x2(1,:)));
        if isempty(ind_c_max)
            ind_c_max = length(x(1,:));
        end
        ind_r_min = find(y(:,1)==min(y2(:,1)));
        if isempty(ind_r_min)
            ind_r_min = 1;
        end
        ind_r_max = find(y(:,1)==max(y2(:,1)));
        if isempty(ind_r_max)
            ind_r_max = length(y(:,1));
        end
        % fill patch matrix
        u_p(ind_r_min:ind_r_max,ind_c_min:ind_c_max) = u2;
        v_p(ind_r_min:ind_r_max,ind_c_min:ind_c_max) = v2;
        exx_p(ind_r_min:ind_r_max,ind_c_min:ind_c_max) = exx2;
        exy_p(ind_r_min:ind_r_max,ind_c_min:ind_c_max) = exy2;
        eyy_p(ind_r_min:ind_r_max,ind_c_min:ind_c_max) = eyy2;
        sigma_p(ind_r_min:ind_r_max,ind_c_min:ind_c_max) = sigma2;
        
        
        % change base map's value if patch map has corresponding values
        inds = (sigma_p ~= -1);
        u(inds) = u_p(inds);
        v(inds) = v_p(inds);
        exx(inds) = exx_p(inds);
        exy(inds) = exy_p(inds);
        eyy(inds) = eyy_p(inds);
        sigma(inds) = sigma_p(inds);
        
        save([directory_n,'\',baseFiles{iFiles}],'x','y','u','v','sigma','exx','exy','eyy');
    end
end
