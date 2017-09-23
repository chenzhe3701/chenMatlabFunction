% based on 2016_02_09 code, trace_analysis_7g
% Average the strain by a filter with varying filter size,
% which is min of [given_size, half_grain_size]
% function [exxA, exyA, eyyA, exxA_withNaN, exyA_withNaN, eyyA_withNaN] = average_by_varying_filter(exx, exy, eyy, ID, filterSize_min)

function [exxA, exyA, eyyA, exxA_withNaN, exyA_withNaN, eyyA_withNaN] = average_by_varying_filter(exx, exy, eyy, varargin)
    if isempty(varargin{1})
        ID = ones(size(exx));
    else
        ID = varargin{1};
    end
    uniqueID = reshape(unique(ID(:)), 1, []);
    if isempty(varargin{2})
        filterSize_min = 601;
    else
        filterSize_min = varargin{2};
    end
    
    exxA = zeros(size(exx));
    exyA = zeros(size(exy));
    eyyA = zeros(size(eyy));
    ss = [];
    for id = uniqueID
        ind_isGrain = (ID == id);
        ind_global = find(ind_isGrain);     % global index of grain points (in large matrix)
        [indR,indC] = find(ind_isGrain);
        indR_min = min(indR);
        indR_max = max(indR);
        indC_min = min(indC);
        indC_max = max(indC);
        
        filterSize = min([filterSize_min, 1+2*round(sqrt((indR_max-indR_min)*(indC_max-indC_min))/2)]);    % us a changing filterSize
        hFilter = fspecial('average',filterSize);
        
        ind_isGrain = ind_isGrain(indR_min:indR_max,indC_min:indC_max); % trim the matrix, make it smaller
        ind_local = find(ind_isGrain);      % local index of grain points (in the trimed matrix)
        ind_notGrain = ~ind_isGrain;
        isGrainPct = filter2(hFilter, ind_isGrain, 'same');     % percentage of the averaged area that belongs to the selected grain
        
        exxLocal = exx(indR_min:indR_max,indC_min:indC_max);
        exxLocal(ind_notGrain) = 0;  % 'e_grain' is strain of This grain. 'e_current' is strian of this region.
        exxLocal(isnan(exxLocal)) = 0;
        exxLocal = filter2(hFilter, exxLocal, 'same')./isGrainPct;
        exxA(ind_global) = exxLocal(ind_local);
        
        exyLocal = exy(indR_min:indR_max,indC_min:indC_max);
        exyLocal(ind_notGrain) = 0;  % 'e_grain' is strain of This grain. 'e_current' is strian of this region.
        exyLocal(isnan(exyLocal)) = 0;
        exyLocal = filter2(hFilter, exyLocal, 'same')./isGrainPct;
        exyA(ind_global) = exyLocal(ind_local);
        
        eyyLocal = eyy(indR_min:indR_max,indC_min:indC_max);
        eyyLocal(ind_notGrain) = 0;  % 'e_grain' is strain of This grain. 'e_current' is strian of this region.
        eyyLocal(isnan(eyyLocal)) = 0;
        eyyLocal = filter2(hFilter, eyyLocal, 'same')./isGrainPct;
        eyyA(ind_global) = eyyLocal(ind_local);
        ss = [ss, num2str(id),',',num2str(filterSize),'; '];
        if length(ss)>75
            disp(ss);
            ss = [];
        end
    end
    
    exxA_withNaN = exxA;
    exyA_withNaN = exyA;
    eyyA_withNaN = eyyA;
    exxA_withNaN(isnan(exx)) = nan;
    exyA_withNaN(isnan(exy)) = nan;
    eyyA_withNaN(isnan(eyy)) = nan;
    
%     % This shows how the average over all points in a window look like.
%     % But this quantity was not used. For Ti7Al#B6_stop_9
%     filterSize = 601;
%     hFilter = fspecial('average',filterSize);
%     exxAA = filter2(hFilter, exx, 'same');
%     myplot(exx(1:5:end,1:5:end),boundaryTF{1}(1:5:end,1:5:end));caxis([0,0.025]);
%     myplot(exxA(1:5:end,1:5:end),boundaryTF{1}(1:5:end,1:5:end));caxis([0,0.025]);
%     myplot(exxA(1:5:end,1:5:end) - exxAA(1:5:end,1:5:end),boundaryTF{1}(1:5:end,1:5:end));caxis([-0.005,0.005]);
end