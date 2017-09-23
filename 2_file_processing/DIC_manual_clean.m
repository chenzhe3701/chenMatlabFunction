% ZheChen 2015-10-28
%
% after DIC is corrected with patches, there might be some regions near frame
% that you want to make them as nan/0.  The code use the row-index, column-index
% you set manually to do the cleaning.

%% For Ti7Al#B6, fov-2, stop-14
% index: [row_start, stop, column_start,stop]
load('C:\Users\chenzhe\Desktop\E\Ti7Al_#B6_fov_002_stop_014.mat')
ref = [200, 500, 40, 65;
    501, 750, 30, 60;
    1351, 1750, 1960, 2010];

for ii=1:size(ref,1)
    sigma(ref(ii,1):ref(ii,2), ref(ii,3):ref(ii,4)) = -1;
    u(ref(ii,1):ref(ii,2), ref(ii,3):ref(ii,4)) = 0;
    v(ref(ii,1):ref(ii,2), ref(ii,3):ref(ii,4)) = 0;
    exx(ref(ii,1):ref(ii,2), ref(ii,3):ref(ii,4)) = 0;
    exy(ref(ii,1):ref(ii,2), ref(ii,3):ref(ii,4)) = 0;
    eyy(ref(ii,1):ref(ii,2), ref(ii,3):ref(ii,4)) = 0;
end
save('C:\Users\chenzhe\Desktop\E\Ti7Al_#B6_fov_002_stop_014a',...
    'exx','exy','eyy','sigma','u','v','x','y');

%% For Ti7Al#B6, fov-2, stop-15
% index: [row_start, stop, column_start,stop]
load('C:\Users\chenzhe\Desktop\E\Ti7Al_#B6_fov_002_stop_015.mat')
ref = [400, 750, 35, 65;
    1390, 1750, 1960, 2020];

for ii=1:size(ref,1)
    sigma(ref(ii,1):ref(ii,2), ref(ii,3):ref(ii,4)) = -1;
    u(ref(ii,1):ref(ii,2), ref(ii,3):ref(ii,4)) = 0;
    v(ref(ii,1):ref(ii,2), ref(ii,3):ref(ii,4)) = 0;
    exx(ref(ii,1):ref(ii,2), ref(ii,3):ref(ii,4)) = 0;
    exy(ref(ii,1):ref(ii,2), ref(ii,3):ref(ii,4)) = 0;
    eyy(ref(ii,1):ref(ii,2), ref(ii,3):ref(ii,4)) = 0;
end
save('C:\Users\chenzhe\Desktop\E\Ti7Al_#B6_fov_002_stop_015a',...
    'exx','exy','eyy','sigma','u','v','x','y');