
function result = nan_unique(x)
    % treat all 'nan' as the same
    % chenzhe, 2020-10-5
    result = unique(x);
    if sum(isnan(result))>0
       result(isnan(result)) = [];
       result = [result;nan];
    end
end