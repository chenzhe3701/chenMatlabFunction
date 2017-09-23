% Chenzhe 2016-12-8
% create artificial .ang files
% 
% Reference is the code described in the following:
% Copyright 2013 Max-Planck-Institut für Eisenforschung GmbH
% function fdata = write_oim_ang_file_v6(fdata, fpath, fname, varargin)
% Function used to write TSL-OIM .Ang file for OIM Analysis 6
% See TSL-OIM documentation for .Ang file format
%
% The fields of each line in the body of the file are as follows:
% phi1, phi, phi2, x, y,  IQ, CI, Phase ID, Detector Intensity, Fit
% where:
% phi1, phi, phi2: Euler angles (in radians) in Bunge's notation for
% describing the lattice orientations and are given in radians.
%
% A value of 4 is given to each Euler angle when an EBSP could not be
% indexed. These points receive negative confidence index values when read
% into an OIM dataset.
%
% x,y: The horizontal and vertical coordinates of the points in the scan,
% in microns. The origin (0,0) is defined as the top-left corner of the
% scan.
%
% IQ: The image quality parameter that characterizes the contrast of the
% EBSP associated with each measurement point.
%
% CI: The confidence index that describes how confident the software is
% that it has correctly indexed the EBSP, i.e., confidence that the angles
% are correct.
%
% Phase ID: The material phase identifier. This field is 0 for single phase
% OIM scans or 1,2,3... for multi-phase scans.
%
% Detector Intensity: An integer describing the intensity from whichever
% detector was hooked up to the OIM system at the time of data collection,
% typically a forward scatter detector.


% create your artifical EBSD data

[x,y] = meshgrid(0:2:200);
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

fdata.x_step = x(1,2)-x(1,1);
fdata.y_step = y(2)-y(1);
fdata.n_col_odd = size(x,2);
fdata.n_col_even = size(x,2);
fdata.n_rows = size(x,1);

fname = [uigetdir('','choose a folder to put the artificial file'),'/myArtificialAng_010.ang'];
% Creation of the ang. file
fid = fopen(fname,'w+');
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
fprintf(fid, ['# LatticeConstants      ' ...
    '2.950 2.950 4.680  90.000  90.000 120.000\r\n']);
fprintf(fid, '# NumberFamilies        8\r\n');
fprintf(fid, '# hklFamilies   	 1  0  0 1 0.000000 1\r\n');
fprintf(fid, '# hklFamilies   	 0  0  2 1 0.000000 1\r\n');
fprintf(fid, '# hklFamilies   	 1  0  1 1 0.000000 1\r\n');
fprintf(fid, '# hklFamilies   	 1  0  2 1 0.000000 1\r\n');
fprintf(fid, '# hklFamilies   	 1  1  0 1 0.000000 1\r\n');
fprintf(fid, '# hklFamilies   	 1  0  3 1 0.000000 1\r\n');
fprintf(fid, '# hklFamilies   	 1  1  2 1 0.000000 1\r\n');
fprintf(fid, '# hklFamilies   	 2  0  1 1 0.000000 1\r\n');
fprintf(fid, ['# ElasticConstants 	' ...
    '-1.000000 -1.000000 -1.000000 -1.000000 -1.000000 -1.000000\r\n']);
fprintf(fid, ['# ElasticConstants 	' ...
    '-1.000000 -1.000000 -1.000000 -1.000000 -1.000000 -1.000000\r\n']);
fprintf(fid, ['# ElasticConstants 	' ...
    '-1.000000 -1.000000 -1.000000 -1.000000 -1.000000 -1.000000\r\n']);
fprintf(fid, ['# ElasticConstants 	' ...
    '-1.000000 -1.000000 -1.000000 -1.000000 -1.000000 -1.000000\r\n']);
fprintf(fid, ['# ElasticConstants 	' ...
    '-1.000000 -1.000000 -1.000000 -1.000000 -1.000000 -1.000000\r\n']);
fprintf(fid, ['# ElasticConstants 	' ...
    '-1.000000 -1.000000 -1.000000 -1.000000 -1.000000 -1.000000\r\n']);
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
for ii = 1:size(x,1)
    for jj = 1:size(x,2)
    fprintf(fid, ['  %6.5f   %6.5f   %6.5f      %6.5f      %6.5f %6.1f' ...
        ' %6.3f  %i      %i  %4.3f  %7.6f  %7.6f  %7.6f  %7.6f \r\n'],...
        phi1(ii,jj), phi(ii,jj), phi2(ii,jj), x(ii,jj), y(ii,jj), ...
        13701, sqrt(rand()), 0, 1, 3*rand(), 0, 0, 0, 0);
    end
end
fclose(fid);
fclose all;


