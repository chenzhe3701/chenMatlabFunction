% matOut = remove_outlier_by_quantile(matIn,pctLow,pctHigh)
%
% matIn and matOut can be vector or matrix.
% pctLow and pctHigh are the quantiles to use.

% Zhe Chen, 2015-08-10 revised.

function matOut = remove_outlier_by_quantile(matIn,pctLow,pctHigh)
    valueFloor = quantile(matIn(:),pctLow);
    valueCeil = quantile(matIn(:),pctHigh);
    matOut = matIn;
    matOut(matOut > valueCeil) = valueCeil;
    matOut(matOut < valueFloor) = valueFloor;
end