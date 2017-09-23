% write data into .ang file
% data contains fields:phi1,phi,phi2,x,y,IQ,CI,Phase,Intensity,Fit
%
% chenzhe, 2017-07-13
%
% chenzhe, note 2017-08-12:
% Currently this works for square grid.  So the data.x/y/... can actually
% be vectors.  

function write_ang(fName, sampleMaterial, data)
if isempty(data)
    data = generate_artificial_data();
end
phi1 = data.phi1;
phi = data.phi;
phi2 = data.phi2;
x = data.x;
y = data.y;
IQ = data.IQ;
CI = data.CI;
Phase = data.Phase;
Intensity = data.Intensity;
Fit = data.Fit;


fdata.x_step = unique(x(:));
fdata.x_step = fdata.x_step(2)-fdata.x_step(1);
fdata.y_step = y(2)-y(1);
fdata.n_col_odd = length(unique(x(:)));
fdata.n_col_even = length(unique(x(:)));    % this applies for hex grid. for square it should be equal.
fdata.n_rows = length(unique(y(:)));

% Creation of the ang. file
fid = fopen(fName,'w+');
write_ang_header(fid, fdata, sampleMaterial);
for ii = 1:size(x,1)
    for jj = 1:size(x,2)
        fprintf(fid, '%9.5f %9.5f %9.5f %12.5f %12.5f %9.1f %6.3f %2i %6i %6.3f %9.6f %9.6f %9.6f %9.6f \r\n',...
            phi1(ii,jj), phi(ii,jj), phi2(ii,jj), x(ii,jj), y(ii,jj), ...
            IQ(ii,jj), CI(ii,jj), Phase(ii,jj), Intensity(ii,jj), Fit(ii,jj), 0, 0, 0, 0);
    end
end
fclose(fid);
fclose all;


end

function data = generate_artificial_data()
[data.x,data.y] = meshgrid(0:2:200);
% I am going to make 3 grains
eulers = [2 2 2; 2 20 2; 92 10 272]/180*pi;
phi1 = zeros(101);
phi = zeros(101);
phi2 = zeros(101);

phi1(1:31,1:31) = eulers(1,1);    % grain 2
phi(1:31,1:31) = eulers(1,2);
phi2(1:31,1:31) = eulers(1,3);

phi1(32:101,1:31) = eulers(2,1);    % grain 2
phi(32:101,1:31) = eulers(2,2);
phi2(32:101,1:31) = eulers(2,3);

phi1(:,32:101) = eulers(3,1);   % grain 3
phi(:,32:101) = eulers(3,2);
phi2(:,32:101) = eulers(3,3);

data.phi1 = phi1;
data.phi = phi;
data.phi2 = phi2;
data.IQ = 300*rand(size(phi1));
data.CI = rand(size(phi1));
data.Phase = zeros(size(phi1));
data.Intensity = ones(size(phi1));
data.Fit = 3*rand(size(phi1));

end

function write_ang_header(fid, fdata, sampleMaterial)
switch sampleMaterial
    case {'Ti','ti','Titanium','titanium','Titanium-alpha'}
        fprintf(fid, '# TEM_PIXperUM          1.000000\r\n');
        fprintf(fid, '# x-star                0.540693\r\n');
        fprintf(fid, '# y-star                0.708550\r\n');
        fprintf(fid, '# z-star                0.793543\r\n');
        fprintf(fid, '# WorkingDistance       10.000000\r\n');
        fprintf(fid, '#\r\n');
        fprintf(fid, '# Phase 1\r\n');
        fprintf(fid, '# MaterialName  	Titanium (Alpha)\r\n');
        fprintf(fid, '# Formula     	Ti\r\n');
        fprintf(fid, '# Info 		\r\n');
        fprintf(fid, '# Symmetry              62\r\n');
        fprintf(fid, '# LatticeConstants      2.950 2.950 4.680  90.000  90.000 120.000\r\n');
        fprintf(fid, '# NumberFamilies        8\r\n');
        fprintf(fid, '# hklFamilies   	 1  0  0 1 0.000000 1\r\n');
        fprintf(fid, '# hklFamilies   	 0  0  2 1 0.000000 1\r\n');
        fprintf(fid, '# hklFamilies   	 1  0  1 1 0.000000 1\r\n');
        fprintf(fid, '# hklFamilies   	 1  0  2 1 0.000000 1\r\n');
        fprintf(fid, '# hklFamilies   	 1  1  0 1 0.000000 1\r\n');
        fprintf(fid, '# hklFamilies   	 1  0  3 1 0.000000 1\r\n');
        fprintf(fid, '# hklFamilies   	 1  1  2 1 0.000000 1\r\n');
        fprintf(fid, '# hklFamilies   	 2  0  1 1 0.000000 1\r\n');
        fprintf(fid, '# ElasticConstants 	-1.000000 -1.000000 -1.000000 -1.000000 -1.000000 -1.000000\r\n');
        fprintf(fid, '# ElasticConstants 	-1.000000 -1.000000 -1.000000 -1.000000 -1.000000 -1.000000\r\n');
        fprintf(fid, '# ElasticConstants 	-1.000000 -1.000000 -1.000000 -1.000000 -1.000000 -1.000000\r\n');
        fprintf(fid, '# ElasticConstants 	-1.000000 -1.000000 -1.000000 -1.000000 -1.000000 -1.000000\r\n');
        fprintf(fid, '# ElasticConstants 	-1.000000 -1.000000 -1.000000 -1.000000 -1.000000 -1.000000\r\n');
        fprintf(fid, '# ElasticConstants 	-1.000000 -1.000000 -1.000000 -1.000000 -1.000000 -1.000000\r\n');
        fprintf(fid, '# Categories1 1 1 1 1 \r\n');
        fprintf(fid, '#\r\n');
        fprintf(fid, '# GRID: SqrGrid\r\n');
        fprintf(fid, '# XSTEP: %6.6f\r\n', fdata.x_step);
        fprintf(fid, '# YSTEP: %6.6f\r\n', fdata.y_step);
        fprintf(fid, '# NCOLS_ODD: %i\r\n', fdata.n_col_odd);
        fprintf(fid, '# NCOLS_EVEN: %i\r\n', fdata.n_col_even);
        fprintf(fid, '# NROWS: %i\r\n', fdata.n_rows);
        fprintf(fid, '#\r\n');
        fprintf(fid, '# OPERATOR: 	zhec\r\n');
        fprintf(fid, '#\r\n');
        fprintf(fid, '# SAMPLEID: 	\r\n');
        fprintf(fid, '#\r\n');
        fprintf(fid, '# SCANID: 	\r\n');
        fprintf(fid, '#\r\n');
    case {'Mg','Magnesium','mg','magnesium'}
        fprintf(fid, '# TEM_PIXperUM          1.000000\r\n');
        fprintf(fid, '# x-star                0.547492\r\n');
        fprintf(fid, '# y-star                0.741129\r\n');
        fprintf(fid, '# z-star                0.630338\r\n');
        fprintf(fid, '# WorkingDistance       18.000000\r\n');
        fprintf(fid, '#\r\n');
        fprintf(fid, '# Phase 1\r\n');
        fprintf(fid, '# MaterialName  	Magnesium\r\n');
        fprintf(fid, '# Formula     	Mg\r\n');
        fprintf(fid, '# Info 		\r\n');
        fprintf(fid, '# Symmetry              62\r\n');
        fprintf(fid, '# LatticeConstants      3.200 3.200 5.200  90.000  90.000 120.000\r\n');
        fprintf(fid, '# NumberFamilies        100\r\n');
        fprintf(fid, '# hklFamilies   	 0  0 -2 1 4.087538 1\r\n');
        fprintf(fid, '# hklFamilies   	 0 -1  1 1 3.307773 1\r\n');
        fprintf(fid, '# hklFamilies   	 1 -2  0 1 2.311954 1\r\n');
        fprintf(fid, '# hklFamilies   	 0 -1  0 1 2.185637 1\r\n');
        fprintf(fid, '# hklFamilies   	 1 -2 -2 1 1.919068 1\r\n');
        fprintf(fid, '# hklFamilies   	 0  0 -4 0 1.817538 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -1  3 1 1.814241 1\r\n');
        fprintf(fid, '# hklFamilies   	 0 -2  1 1 1.624808 1\r\n');
        fprintf(fid, '# hklFamilies   	 0 -1  2 1 1.406529 1\r\n');
        fprintf(fid, '# hklFamilies   	 1 -2 -4 1 1.349050 1\r\n');
        fprintf(fid, '# hklFamilies   	 0 -2  3 0 1.268847 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -3  0 0 1.210179 0\r\n');
        fprintf(fid, '# hklFamilies   	 1 -3 -1 0 1.199466 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -1  5 1 1.121533 1\r\n');
        fprintf(fid, '# hklFamilies   	 0 -3  2 0 1.121479 0\r\n');
        fprintf(fid, '# hklFamilies   	 0  0 -6 0 1.115077 0\r\n');
        fprintf(fid, '# hklFamilies   	 1 -3 -3 0 1.013054 0\r\n');
        fprintf(fid, '# hklFamilies   	 2 -4  0 0 1.000921 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -2  0 0 0.984594 0\r\n');
        fprintf(fid, '# hklFamilies   	 2 -4 -2 0 0.938406 0\r\n');
        fprintf(fid, '# hklFamilies   	 1 -2 -6 0 0.934227 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -3  4 0 0.919099 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -2  5 0 0.910171 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -2  2 0 0.853248 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -1  4 0 0.807431 0\r\n');
        fprintf(fid, '# hklFamilies   	 1 -4 -1 0 0.801721 0\r\n');
        fprintf(fid, '# hklFamilies   	 2 -4 -4 0 0.797112 0\r\n');
        fprintf(fid, '# hklFamilies   	 1 -3 -5 0 0.777251 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -1  7 0 0.742272 0\r\n');
        fprintf(fid, '# hklFamilies   	 0  0 -8 0 0.742000 0\r\n');
        fprintf(fid, '# hklFamilies   	 1 -4 -3 0 0.716043 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -3  6 0 0.707900 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -4  1 0 0.701558 0\r\n');
        fprintf(fid, '# hklFamilies   	 1 -3  0 0 0.695632 0\r\n');
        fprintf(fid, '# hklFamilies   	 1 -5  0 0 0.661255 0\r\n');
        fprintf(fid, '# hklFamilies   	 1 -2 -8 0 0.657040 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -2  7 0 0.648482 0\r\n');
        fprintf(fid, '# hklFamilies   	 1 -3 -2 0 0.635669 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -4  3 0 0.634855 0\r\n');
        fprintf(fid, '# hklFamilies   	 1 -5 -2 0 0.634332 0\r\n');
        fprintf(fid, '# hklFamilies   	 2 -4 -6 0 0.632258 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -2  4 0 0.630455 0\r\n');
        fprintf(fid, '# hklFamilies   	 2 -5 -1 0 0.616537 0\r\n');
        fprintf(fid, '# hklFamilies   	 1 -4 -5 0 0.588011 0\r\n');
        fprintf(fid, '# hklFamilies   	 1 -3 -7 0 0.577192 0\r\n');
        fprintf(fid, '# hklFamilies   	 2 -5 -3 0 0.565906 0\r\n');
        fprintf(fid, '# hklFamilies   	 1 -5 -4 0 0.560790 0\r\n');
        fprintf(fid, '# hklFamilies   	 3 -6  0 0 0.536655 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -3  8 0 0.533847 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -4  5 0 0.532605 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -1  6 0 0.521177 0\r\n');
        fprintf(fid, '# hklFamilies   	 3 -6 -2 0 0.518309 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -1  9 0 0.512898 0\r\n');
        fprintf(fid, '# hklFamilies   	 1 -3 -4 0 0.506206 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -5  1 0 0.486503 0\r\n');
        fprintf(fid, '# hklFamilies   	 2 -4 -8 0 0.486298 0\r\n');
        fprintf(fid, '# hklFamilies   	 2 -5 -5 0 0.481650 0\r\n');
        fprintf(fid, '# hklFamilies   	 1 -4  0 0 0.481044 0\r\n');
        fprintf(fid, '# hklFamilies   	 1 -5 -6 0 0.471907 0\r\n');
        fprintf(fid, '# hklFamilies   	 3 -6 -4 0 0.468053 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -2  9 0 0.463627 0\r\n');
        fprintf(fid, '# hklFamilies   	 1 -4 -7 0 0.463168 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -5  3 0 0.454230 0\r\n');
        fprintf(fid, '# hklFamilies   	 1 -4 -2 0 0.453844 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -2  6 0 0.446958 0\r\n');
        fprintf(fid, '# hklFamilies   	 2 -6 -1 0 0.442517 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -4  7 0 0.426707 0\r\n');
        fprintf(fid, '# hklFamilies   	 1 -3 -9 0 0.425510 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -6  0 0 0.416894 0\r\n');
        fprintf(fid, '# hklFamilies   	 2 -6 -3 0 0.412050 0\r\n');
        fprintf(fid, '# hklFamilies   	 1 -6 -1 0 0.411514 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -6  2 0 0.404353 0\r\n');
        fprintf(fid, '# hklFamilies   	 3 -6 -6 0 0.403452 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -4  0 0 0.402148 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -5  5 0 0.397279 0\r\n');
        fprintf(fid, '# hklFamilies   	 2 -5 -7 0 0.394709 0\r\n');
        fprintf(fid, '# hklFamilies   	 1 -4 -4 0 0.388441 0\r\n');
        fprintf(fid, '# hklFamilies   	 1 -6 -3 0 0.388247 0\r\n');
        fprintf(fid, '# hklFamilies   	 2 -7  0 0 0.387890 0\r\n');
        fprintf(fid, '# hklFamilies   	 1 -5 -8 0 0.386392 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -4  2 0 0.382791 0\r\n');
        fprintf(fid, '# hklFamilies   	 1 -3 -6 0 0.381306 0\r\n');
        fprintf(fid, '# hklFamilies   	 2 -7 -2 0 0.378116 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -6  4 0 0.374674 0\r\n');
        fprintf(fid, '# hklFamilies   	 2 -6 -5 0 0.366161 0\r\n');
        fprintf(fid, '# hklFamilies   	 1 -4 -9 0 0.358809 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -1  8 0 0.353429 0\r\n');
        fprintf(fid, '# hklFamilies   	 3 -7 -1 0 0.353151 0\r\n');
        fprintf(fid, '# hklFamilies   	 2 -7 -4 0 0.349595 0\r\n');
        fprintf(fid, '# hklFamilies   	 2 -5  0 0 0.348458 0\r\n');
        fprintf(fid, '# hklFamilies   	 1 -6 -5 0 0.345637 0\r\n');
        fprintf(fid, '# hklFamilies   	 3 -6 -8 0 0.337848 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -4  9 0 0.337551 0\r\n');
        fprintf(fid, '# hklFamilies   	 3 -7 -3 0 0.335762 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -5  7 0 0.334551 0\r\n');
        fprintf(fid, '# hklFamilies   	 2 -5 -2 0 0.332438 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -4  4 0 0.331265 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -6  6 0 0.331173 0\r\n');
        fprintf(fid, '# hklFamilies   	 4 -8  0 0 0.319899 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -2  8 0 0.319002 0\r\n');
        fprintf(fid, '# ElasticConstants 	0.000000 0.000000 0.000000 0.000000 0.000000 0.000000\r\n');
        fprintf(fid, '# ElasticConstants 	0.000000 0.000000 0.000000 0.000000 0.000000 0.000000\r\n');
        fprintf(fid, '# ElasticConstants 	0.000000 0.000000 0.000000 0.000000 0.000000 0.000000\r\n');
        fprintf(fid, '# ElasticConstants 	0.000000 0.000000 0.000000 0.000000 0.000000 0.000000\r\n');
        fprintf(fid, '# ElasticConstants 	0.000000 0.000000 0.000000 0.000000 0.000000 0.000000\r\n');
        fprintf(fid, '# ElasticConstants 	0.000000 0.000000 0.000000 0.000000 0.000000 0.000000\r\n');
        fprintf(fid, '# Categories0 0 0 0 0 \r\n');
        fprintf(fid, '#\r\n');
        fprintf(fid, '# GRID: SqrGrid\r\n');
        fprintf(fid, '# XSTEP: %6.6f\r\n', fdata.x_step);
        fprintf(fid, '# YSTEP: %6.6f\r\n', fdata.y_step);
        fprintf(fid, '# NCOLS_ODD: %i\r\n', fdata.n_col_odd);
        fprintf(fid, '# NCOLS_EVEN: %i\r\n', fdata.n_col_even);
        fprintf(fid, '# NROWS: %i\r\n', fdata.n_rows);
        fprintf(fid, '#\r\n');
        fprintf(fid, '# OPERATOR: 	Administrator\r\n');
        fprintf(fid, '#\r\n');
        fprintf(fid, '# SAMPLEID: 	\r\n');
        fprintf(fid, '#\r\n');
        fprintf(fid, '# SCANID: 	\r\n');
        fprintf(fid, '#\r\n');
    case {'Al','Aluminum','al','aluminum'}
        fprintf(fid, '# TEM_PIXperUM          1.000000\r\n');
        fprintf(fid, '# x-star                0.515501\r\n');
        fprintf(fid, '# y-star                0.746615\r\n');
        fprintf(fid, '# z-star                0.646515\r\n');
        fprintf(fid, '# WorkingDistance       14.000000\r\n');
        fprintf(fid, '#\r\n');
        fprintf(fid, '# Phase 1\r\n');
        fprintf(fid, '# MaterialName  	Aluminum\r\n');
        fprintf(fid, '# Formula     	Al\r\n');
        fprintf(fid, '# Info 		\r\n');
        fprintf(fid, '# Symmetry              43\r\n');
        fprintf(fid, '# LatticeConstants      4.040 4.040 4.040  90.000  90.000  90.000\r\n');
        fprintf(fid, '# NumberFamilies        69\r\n');
        fprintf(fid, '# hklFamilies   	 1 -1 -1 1 8.469246 1\r\n');
        fprintf(fid, '# hklFamilies   	 0 -2  0 1 7.042059 1\r\n');
        fprintf(fid, '# hklFamilies   	 0 -2  2 1 4.443132 1\r\n');
        fprintf(fid, '# hklFamilies   	 1 -3 -1 1 3.608604 1\r\n');
        fprintf(fid, '# hklFamilies   	 2 -2 -2 0 3.412745 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -4  0 0 3.107525 0\r\n');
        fprintf(fid, '# hklFamilies   	 1 -3 -3 0 2.616925 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -4  2 0 2.453335 0\r\n');
        fprintf(fid, '# hklFamilies   	 2 -4 -2 0 2.175230 0\r\n');
        fprintf(fid, '# hklFamilies   	 1 -5 -1 0 2.007518 0\r\n');
        fprintf(fid, '# hklFamilies   	 3 -3 -3 0 2.007518 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -4  4 0 1.779666 0\r\n');
        fprintf(fid, '# hklFamilies   	 1 -5 -3 0 1.678286 0\r\n');
        fprintf(fid, '# hklFamilies   	 2 -4 -4 0 1.645465 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -6  0 0 1.645465 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -6  2 0 1.518535 0\r\n');
        fprintf(fid, '# hklFamilies   	 3 -5 -3 0 1.435321 0\r\n');
        fprintf(fid, '# hklFamilies   	 2 -6 -2 0 1.412052 0\r\n');
        fprintf(fid, '# hklFamilies   	 4 -4 -4 0 1.321522 0\r\n');
        fprintf(fid, '# hklFamilies   	 1 -5 -5 0 1.256076 0\r\n');
        fprintf(fid, '# hklFamilies   	 1 -7 -1 0 1.256076 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -6  4 0 1.234691 0\r\n');
        fprintf(fid, '# hklFamilies   	 2 -6 -4 0 1.164740 0\r\n');
        fprintf(fid, '# hklFamilies   	 1 -7 -3 0 1.116752 0\r\n');
        fprintf(fid, '# hklFamilies   	 3 -5 -5 0 1.116752 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -8  0 0 1.039406 0\r\n');
        fprintf(fid, '# hklFamilies   	 3 -7 -3 0 1.000181 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -8  2 0 0.988733 0\r\n');
        fprintf(fid, '# hklFamilies   	 4 -6 -4 0 0.988733 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -6  6 0 0.943759 0\r\n');
        fprintf(fid, '# hklFamilies   	 2 -8 -2 0 0.943759 0\r\n');
        fprintf(fid, '# hklFamilies   	 5 -5 -5 0 0.910843 0\r\n');
        fprintf(fid, '# hklFamilies   	 1 -7 -5 0 0.910843 0\r\n');
        fprintf(fid, '# hklFamilies   	 2 -6 -6 0 0.900018 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -8  4 0 0.859086 0\r\n');
        fprintf(fid, '# hklFamilies   	 1 -9 -1 0 0.832763 0\r\n');
        fprintf(fid, '# hklFamilies   	 3 -7 -5 0 0.832763 0\r\n');
        fprintf(fid, '# hklFamilies   	 2 -8 -4 0 0.824095 0\r\n');
        fprintf(fid, '# hklFamilies   	 4 -6 -6 0 0.789928 0\r\n');
        fprintf(fid, '# hklFamilies   	 1 -9 -3 0 0.764809 0\r\n');
        fprintf(fid, '# hklFamilies   	 4 -8 -4 0 0.727381 0\r\n');
        fprintf(fid, '# hklFamilies   	 3 -9 -3 0 0.708580 0\r\n');
        fprintf(fid, '# hklFamilies   	 1 -7 -7 0 0.708580 0\r\n');
        fprintf(fid, '# hklFamilies   	 5 -7 -5 0 0.708580 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -8  6 0 0.702376 0\r\n');
        fprintf(fid, '# hklFamilies   	 2 -8 -6 0 0.677866 0\r\n');
        fprintf(fid, '# hklFamilies   	 3 -7 -7 0 0.659792 0\r\n');
        fprintf(fid, '# hklFamilies   	 1 -9 -5 0 0.659792 0\r\n');
        fprintf(fid, '# hklFamilies   	 6 -6 -6 0 0.653824 0\r\n');
        fprintf(fid, '# hklFamilies   	 3 -9 -5 0 0.617149 0\r\n');
        fprintf(fid, '# hklFamilies   	 4 -8 -6 0 0.612312 0\r\n');
        fprintf(fid, '# hklFamilies   	 5 -7 -7 0 0.579023 0\r\n');
        fprintf(fid, '# hklFamilies   	 0 -8  8 0 0.555865 0\r\n');
        fprintf(fid, '# hklFamilies   	 5 -9 -5 0 0.545424 0\r\n');
        fprintf(fid, '# hklFamilies   	 1 -9 -7 0 0.545424 0\r\n');
        fprintf(fid, '# hklFamilies   	 2 -8 -8 0 0.541970 0\r\n');
        fprintf(fid, '# hklFamilies   	 6 -8 -6 0 0.528285 0\r\n');
        fprintf(fid, '# hklFamilies   	 3 -9 -7 0 0.518152 0\r\n');
        fprintf(fid, '# hklFamilies   	 4 -8 -8 0 0.501505 0\r\n');
        fprintf(fid, '# hklFamilies   	 7 -7 -7 0 0.491698 0\r\n');
        fprintf(fid, '# hklFamilies   	 5 -9 -7 0 0.469136 0\r\n');
        fprintf(fid, '# hklFamilies   	 1 -9 -9 0 0.447148 0\r\n');
        fprintf(fid, '# hklFamilies   	 6 -8 -8 0 0.444438 0\r\n');
        fprintf(fid, '# hklFamilies   	 3 -9 -9 0 0.426430 0\r\n');
        fprintf(fid, '# hklFamilies   	 7 -9 -7 0 0.406970 0\r\n');
        fprintf(fid, '# hklFamilies   	 5 -9 -9 0 0.387939 0\r\n');
        fprintf(fid, '# hklFamilies   	 8 -8 -8 0 0.378635 0\r\n');
        fprintf(fid, '# hklFamilies   	 7 -9 -9 0 0.348809 0\r\n');
        fprintf(fid, '# hklFamilies   	 9 -9 -9 0 0.302635 0\r\n');
        fprintf(fid, '# ElasticConstants 	-1.000000 -1.000000 -1.000000 -1.000000 -1.000000 -1.000000\r\n');
        fprintf(fid, '# ElasticConstants 	-1.000000 -1.000000 -1.000000 -1.000000 -1.000000 -1.000000\r\n');
        fprintf(fid, '# ElasticConstants 	-1.000000 -1.000000 -1.000000 -1.000000 -1.000000 -1.000000\r\n');
        fprintf(fid, '# ElasticConstants 	-1.000000 -1.000000 -1.000000 -1.000000 -1.000000 -1.000000\r\n');
        fprintf(fid, '# ElasticConstants 	-1.000000 -1.000000 -1.000000 -1.000000 -1.000000 -1.000000\r\n');
        fprintf(fid, '# ElasticConstants 	-1.000000 -1.000000 -1.000000 -1.000000 -1.000000 -1.000000\r\n');
        fprintf(fid, '# Categories0 0 0 0 0 \r\n');
        fprintf(fid, '#\r\n');
        fprintf(fid, '# GRID: SqrGrid\r\n');
        fprintf(fid, '# XSTEP: %6.6f\r\n', fdata.x_step);
        fprintf(fid, '# YSTEP: %6.6f\r\n', fdata.y_step);
        fprintf(fid, '# NCOLS_ODD: %i\r\n', fdata.n_col_odd);
        fprintf(fid, '# NCOLS_EVEN: %i\r\n', fdata.n_col_even);
        fprintf(fid, '# NROWS: %i\r\n', fdata.n_rows);
        fprintf(fid, '#\r\n');
        fprintf(fid, '# OPERATOR: 	supervisor\r\n');
        fprintf(fid, '#\r\n');
        fprintf(fid, '# SAMPLEID: 	\r\n');
        fprintf(fid, '#\r\n');
        fprintf(fid, '# SCANID: 	\r\n');
        fprintf(fid, '#\r\n');
end

end