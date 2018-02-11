% normalize each column
function [val_zero_normalized, val_mean, val_std] = zero_normalize_column(M)

val_mean = nanmean(M,1);
val_std = nanstd(M,0,1);
val_zeroed = M - val_mean;
val_zero_normalized = val_zeroed./val_std;
