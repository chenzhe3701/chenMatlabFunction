
% write grain id + rodrigers vector for CPFE input
[f, p] = uigetfile('*.txt','choose txt file to write orientations');
fid = fopen(fullfile(p,f),'w');
fprintf(fid, '%s\r\n','**Grain ID, Rodrigues vector r_x, r_y, r_z');
for ii=1:size(gID,1)
   fprintf(fid, '%d\t%f\t%f\t%f\r\n', [gID(ii),rodV(ii,:)]); 
end
fclose(fid);

%% 75x75 area
ID_local = ID(400:5:770, 520:5:890);
e_local = e0(400:5:770, 520:5:890);
ID_local = repmat(ID_local(:),1,10);

%% write  grainID file
[f, p] = uigetfile('*.txt','choose txt file to write grainID');
fid = fopen(fullfile(p,f),'w');
fprintf(fid, '%s\r\n','**Total header lines = 5');
fprintf(fid, '%s\r\n','**Grain ID File ');
fprintf(fid, '%s\r\n','**3D Volume has dimensions [20 x 20 x 22] voxels');
fprintf(fid, '%s\r\n','**Data arranged in a 2D array of 400 x 22 integer values');
fprintf(fid, '%s\r\n','**');
for ii=1:size(ID_local,1)
    for jj=1:size(ID_local,2)
        fprintf(fid, '%d\t', ID_local(ii,jj));
    end
    fprintf(fid, '\r\n');
end
fclose(fid);


