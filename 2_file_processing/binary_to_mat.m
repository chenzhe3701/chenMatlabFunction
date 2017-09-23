% helper to read binary into an array
% varargin{1} = path+fileName
% varargin{2} = method, e.g., 'uint=>double'
% chenzhe, 2017-07-20

function A = binary_to_mat(varargin)
if length(varargin) == 2
    var1 = varargin{1};
    var2 = varargin{2};
elseif length(varargin) == 1
    var1 = varargin{1};
    var2 = 'uint8=>double';
else
    [f,p] = uigetfile('','select file');
    var1 = [p,f];
    var2 = 'uint8=>double';
end

fid = fopen(var1,'rb+');

A = fread(fid, Inf, var2);
fclose(fid);