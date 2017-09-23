% Load a processed 3D data
% The data set can be changed later.  But temporarily, because I use some data
% so often, so I need to write it in a convenient way.
% load_data(#) to load specifit data set
% set 1: tempWS8.mat
%
% Zhe Chen, 2015-9-28

function load_data(varargin)

str{1}='''C:\Users\chenzhe\Desktop\Matlabed-3D-analysis\IPF analysis Code V-11-17\tempWS8.mat''';
str{2}='''C:\Users\chenzhe\Desktop\Matlabed-3D-analysis\IPF analysis Code V-11-17\tempWS7.mat''';

if ~isempty(varargin)
    setNum = varargin{1};
    switch setNum
        case 1
            evalin('base',['load ', str{1}]);
        case 2
            evalin('base',['load ', str{2}]);
    end
else
    disp('specify a data set: load_data(#)');
end

end