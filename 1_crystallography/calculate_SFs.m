% [sfBasal, sfPrism, sfPyramidalA, sfPyramidalCA, sfTT, sfBasalNum, sfPrismNum, sfPyramidalANum, sfPyramidalCANum, sfTTNum, SF{iSS}, schmidFactor{iPair}]
%    = calculate_SF(phi1, phi, phi2, ss, phi1_sys, phi_sys, phi2_sys, phiError, stressTensor,varargin)
%
% Uses cellfun to speed up
% varargin = 'HCP-Ti' or 'HCP-Mg'
% Input can be Euler angles or Matrix of Euler angles.
% Assumes Ti: 1:3 basal, 4:6 prism, 7:12 pyramidal, 13:24 pyramidal C+A; 25:30 tensile twin.
% Assume Mg: 1:3 basal, 4:6 prism, 7:12 pyramidal, 13:18 pyramidal ii C+A; 19:24 tensile twin.
% Returns for each slip system the max SF and the ss number in the 1:30(24) range
% If the ss is only 24 without twinning, it's still ok.  Twin output will be [].
%
% Zhe Chen, 2015-08-10 revised.
% Zhe Chen, 2016-5-24 revised.
% Zhe Chen, 2016-8-16, extend to include Mg. Change phi_error to take 3 inputs. 
% corrected an error: previously when constructing M, phi1_sys and phi2_sys was flipped in sequence ... Hopefully no significant error. 

function [sfBasal, sfPrism, sfPyramidalA, sfPyramidalCA, sfTT, sfBasalNum, sfPrismNum, sfPyramidalANum, sfPyramidalCANum, sfTTNum, SF, schmidFactor]...
    = calculate_SFs(phi1, phi, phi2, ss, phi1_sys, phi_sys, phi2_sys, phi1_error, phi_error, phi2_error, stressTensor, varargin)

phi1_sys = ones(size(phi1)).*phi1_sys;
phi_sys = ones(size(phi1)).*phi_sys;
phi2_sys = ones(size(phi1)).*phi2_sys;
phi1_error = ones(size(phi1)).*phi1_error;
phi_error = ones(size(phi1)).*phi_error;
phi2_error = ones(size(phi1)).*phi2_error;

    mPhi1_sys = arrayfun(@(x) [cosd(x) cosd(x-90) 0; cosd(x+90) cosd(x) 0; 0 0 1], phi1_sys, 'UniformOutput',false);
    mPhi_sys = arrayfun(@(x) [1 0 0; 0 cosd(x) cosd(x-90); 0 cosd(x+90) cosd(x)], phi_sys, 'UniformOutput',false);
    mPhi2_sys = arrayfun(@(x) [cosd(x) cosd(x-90) 0; cosd(x+90) cosd(x) 0; 0 0 1], phi2_sys, 'UniformOutput',false);
    
    mPhi1_error = arrayfun(@(x) [cosd(x) cosd(x-90) 0; cosd(x+90) cosd(x) 0; 0 0 1], phi1_error, 'UniformOutput',false);
    mPhi_error = arrayfun(@(x) [1 0 0; 0 cosd(x) cosd(x-90); 0 cosd(x+90) cosd(x)], phi_error, 'UniformOutput',false);
    mPhi2_error = arrayfun(@(x) [cosd(x) cosd(x-90) 0; cosd(x+90) cosd(x) 0; 0 0 1], phi2_error, 'UniformOutput',false);
    
    mPhi1 = arrayfun(@(x) [cosd(x) cosd(x-90) 0; cosd(x+90) cosd(x) 0; 0 0 1], phi1, 'UniformOutput',false);
    mPhi = arrayfun(@(x) [1 0 0; 0 cosd(x) cosd(x-90); 0 cosd(x+90) cosd(x)], phi, 'UniformOutput',false);
    mPhi2 = arrayfun(@(x) [cosd(x) cosd(x-90) 0; cosd(x+90) cosd(x) 0; 0 0 1], phi2, 'UniformOutput',false);
    
    mMatrix = cellfun(@(x1,x2,x3,x4,x5,x6,x7,x8,x9) x1*x2*x3*x4*x5*x6*x7*x8*x9, mPhi2, mPhi, mPhi1, mPhi2_sys, mPhi_sys, mPhi1_sys, mPhi2_error, mPhi_error, mPhi1_error, 'UniformOutput',false);   % g is the 'transformation matrix' defined in continuum mechanics: x=g*X, X is Global corrdinate
    
if isempty(varargin)||strcmpi(varargin{1},'HCP-Ti')||strcmpi(varargin{1},'Ti')
        
    nSS = size(ss,3);   % number of slip systems

    sfTT = [];
    sfTTNum = [];
    
    for iSS = 1:nSS
        slipPlane(iSS,:) = ss(1,:,iSS);
        slipDirection(iSS,:) = ss(2,:,iSS);
    end
    
    schmidFactor = cellfun(@(x) sum(slipPlane * x * stressTensor .* (slipDirection * x), 2), mMatrix, 'UniformOutput', false);  %  .* operation because [a,b,c]*[d e f]T = sum([a,b,c].*[d e f])
    
    if iSS<25
        schmidFactor = cellfun(@(x) abs(x), schmidFactor, 'UniformOutput', false);                          % no twin system
    else
        schmidFactor = cellfun(@(x) [abs(x(1:24,:));x(25:end,:)], schmidFactor, 'UniformOutput', false);    % Have twin system
    end
    
    sfBasal = cellfun(@(x) max(x(1:3)), schmidFactor, 'UniformOutput', false);
    sfBasalNum = cellfun(@(x,y) find(x==y(1:3)), sfBasal, schmidFactor, 'UniformOutput', false);
    sfBasalNum(cellfun(@(x) isempty(x), sfBasalNum))={nan};                 % assign nan to empty cells, in order to use cell2mat later.

    sfPrism = cellfun(@(x) max(x(4:6)), schmidFactor, 'UniformOutput', false);
    sfPrismNum = cellfun(@(x,y) 3 + find(x==y(4:6)), sfPrism, schmidFactor, 'UniformOutput', false);
    sfPrismNum(cellfun(@(x) isempty(x), sfPrismNum))={nan};
    
    sfPyramidalA = cellfun(@(x) max(x(7:12)), schmidFactor, 'UniformOutput', false);
    sfPyramidalANum = cellfun(@(x,y) 6 + find(x==y(7:12)), sfPyramidalA, schmidFactor, 'UniformOutput', false);
    sfPyramidalANum(cellfun(@(x) isempty(x), sfPyramidalANum))={nan};
    
    sfPyramidalCA = cellfun(@(x) max(x(13:24)), schmidFactor, 'UniformOutput', false);
    sfPyramidalCANum = cellfun(@(x,y) 12 + find(x==y(13:24)), sfPyramidalCA, schmidFactor, 'UniformOutput', false);
    sfPyramidalCANum(cellfun(@(x) isempty(x), sfPyramidalCANum))={nan};
    
    sfBasal = cell2mat(sfBasal);
    sfBasalNum = cell2mat(sfBasalNum);
    sfPrism = cell2mat(sfPrism);
    sfPrismNum = cell2mat(sfPrismNum);
    sfPyramidalA = cell2mat(sfPyramidalA);
    sfPyramidalANum = cell2mat(sfPyramidalANum);
    sfPyramidalCA = cell2mat(sfPyramidalCA);
    sfPyramidalCANum = cell2mat(sfPyramidalCANum);
    
    if iSS>24
        sfTT = cellfun(@(x) max(x(25:30)), schmidFactor, 'UniformOutput', false);
        sfTTNum = cellfun(@(x,y) 24 + find(x==y(25:30)), sfTT, schmidFactor, 'UniformOutput', false);
        sfTTNum(cellfun(@(x) isempty(x), sfTTNum))={nan};
        
        sfTT = cell2mat(sfTT);
        sfTTNum = cell2mat(sfTTNum);
    end
    
    for ii = 1:iSS
        SF{ii} = cellfun(@(x) x(ii), schmidFactor, 'UniformOutput', false);
    end
    
    display('calculated Schmid Factors');
    display(datestr(now));
    
elseif isempty(varargin)||strcmpi(varargin{1},'HCP-Mg')||strcmpi(varargin{1},'Mg') 
        
    nSS = size(ss,3);   % number of slip systems

    sfTT = [];
    sfTTNum = [];
    
    for iSS = 1:nSS
        slipPlane(iSS,:) = ss(1,:,iSS);
        slipDirection(iSS,:) = ss(2,:,iSS);
    end
    
    schmidFactor = cellfun(@(x) sum(slipPlane * x * stressTensor .* (slipDirection * x), 2), mMatrix, 'UniformOutput', false);  %  .* operation because [a,b,c]*[d e f]T = sum([a,b,c].*[d e f])
    
    if iSS<19
        schmidFactor = cellfun(@(x) abs(x), schmidFactor, 'UniformOutput', false);                          % no twin system
    else
        schmidFactor = cellfun(@(x) [abs(x(1:18,:));x(19:end,:)], schmidFactor, 'UniformOutput', false);    % Have twin system
    end
    
    sfBasal = cellfun(@(x) max(x(1:3)), schmidFactor, 'UniformOutput', false);
    sfBasalNum = cellfun(@(x,y) find(x==y(1:3)), sfBasal, schmidFactor, 'UniformOutput', false);
    sfBasalNum(cellfun(@(x) isempty(x), sfBasalNum))={nan};                 % assign nan to empty cells, in order to use cell2mat later.

    sfPrism = cellfun(@(x) max(x(4:6)), schmidFactor, 'UniformOutput', false);
    sfPrismNum = cellfun(@(x,y) 3 + find(x==y(4:6)), sfPrism, schmidFactor, 'UniformOutput', false);
    sfPrismNum(cellfun(@(x) isempty(x), sfPrismNum))={nan};
    
    sfPyramidalA = cellfun(@(x) max(x(7:12)), schmidFactor, 'UniformOutput', false);
    sfPyramidalANum = cellfun(@(x,y) 6 + find(x==y(7:12)), sfPyramidalA, schmidFactor, 'UniformOutput', false);
    sfPyramidalANum(cellfun(@(x) isempty(x), sfPyramidalANum))={nan};
    
    sfPyramidalCA = cellfun(@(x) max(x(13:18)), schmidFactor, 'UniformOutput', false);
    sfPyramidalCANum = cellfun(@(x,y) 12 + find(x==y(13:24)), sfPyramidalCA, schmidFactor, 'UniformOutput', false);
    sfPyramidalCANum(cellfun(@(x) isempty(x), sfPyramidalCANum))={nan};
    
    sfBasal = cell2mat(sfBasal);
    sfBasalNum = cell2mat(sfBasalNum);
    sfPrism = cell2mat(sfPrism);
    sfPrismNum = cell2mat(sfPrismNum);
    sfPyramidalA = cell2mat(sfPyramidalA);
    sfPyramidalANum = cell2mat(sfPyramidalANum);
    sfPyramidalCA = cell2mat(sfPyramidalCA);
    sfPyramidalCANum = cell2mat(sfPyramidalCANum);
    
    if iSS>18
        sfTT = cellfun(@(x) max(x(19:24)), schmidFactor, 'UniformOutput', false);
        sfTTNum = cellfun(@(x,y) 18 + find(x==y(19:24)), sfTT, schmidFactor, 'UniformOutput', false);
        sfTTNum(cellfun(@(x) isempty(x), sfTTNum))={nan};
        
        sfTT = cell2mat(sfTT);
        sfTTNum = cell2mat(sfTTNum);
    end
    
    for ii = 1:iSS
        SF{ii} = cellfun(@(x) x(ii), schmidFactor, 'UniformOutput', false);
    end
    
    display('calculated Schmid Factors');
    display(datestr(now));
    
else
    disp('temporarily don not have info for this crystal structure');
end

end