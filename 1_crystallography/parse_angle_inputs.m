% chenzhe, revised 2016-5-1
% 
% now this can be used either as a subfunction, or used alone.
% 
% chenzhe, revised 2016-6-30 to take phi_error as 1x3 vector.

function [euler,phi_sys,phi_error,TF] = parse_angle_inputs(varargin)
TF = true;
phi_sys = [-90,180,0];  % rotate imaging system to EBSD detector system
phi_error = [0, 0, 0];  % angle error caused by placing the sample when doing experiment. i.e., rotate EBSD map into In-situ SEM image orientation.
% Note 12-10-2013: If you need to rotate SEM image CCW to match EBSD map, then this angle is Positive.
euler=[30 40 50];  % Euler angle given by EBSD map.  In MSU EB CamScan, EBSD Lab system X is down, Y is right.
str = 'format: slip_trace_Mg = (euler(3 seperate value, or 3x1 vector),phi_sys(optional, 3 seperate value, or 3x1 vector),phi_error(optional))';
if isempty(varargin)
    disp(str);
    TF = false;
else
    % if this is used as a subfunction, varargin = {varargin_of_main_function},  
    % i.e., the inputs of the main function all wrapped together into a cell. 
    % Therefore, use extract the contents, make it the same form as the input of the main function. 
    if iscell(varargin{1})     
        varargin = varargin{1};
    end
    switch length(varargin)
        case 1                          % get euler
            if length(varargin{1})==3
                euler = varargin{1};
            else
                disp(str);
                TF = false;
            end
        case 2                          % euler, phi_sys
            if length(varargin{1})==3 && length(varargin{2})==3           % get euler and phi_sys
                euler = varargin{1};
                phi_sys = varargin{2};
            else
                disp(str);
                TF = false;
            end
        case 3                          % euler1,euler2,euler3, or euler,phi_sys,phi_error
            if length(varargin{1})==3 && length(varargin{2})==3 && length(varargin{3})==3
                euler = varargin{1};
                phi_sys = varargin{2};
                phi_error = varargin{3};
            elseif length(varargin{1})==1 && length(varargin{2})==1 && length(varargin{3})==1
                euler(1) = varargin{1};
                euler(2) = varargin{2};
                euler(3) = varargin{3};
            else
                disp(str);
                TF = false;
            end
        case 6
            if length(varargin{1})==1 && length(varargin{2})==1 && length(varargin{3})==1 && length(varargin{4})==1 && length(varargin{5})==1 && length(varargin{6})==1
                euler(1) = varargin{1};
                euler(2) = varargin{2};
                euler(3) = varargin{3};
                phi_sys(1) = varargin{4};
                phi_sys(2) = varargin{5};
                phi_sys(3) = varargin{6};
            else
                disp(str);
                TF = false;
            end
        case 9
            if length(varargin{1})==1 && length(varargin{2})==1 && length(varargin{3})==1 && length(varargin{4})==1 && length(varargin{5})==1 && length(varargin{6})==1 && length(varargin{7})==1
                euler(1) = varargin{1};
                euler(2) = varargin{2};
                euler(3) = varargin{3};
                phi_sys(1) = varargin{4};
                phi_sys(2) = varargin{5};
                phi_sys(3) = varargin{6};
                phi_error(1) = varargin{7};
                phi_error(2) = varargin{8};
                phi_error(3) = varargin{9};
            else
                disp(str);
                TF = false;
            end
        otherwise
            disp(str);
            TF = false;
    end
end

end