% normalize each column
function output = stats_norm(input)
[m,n] = size(input);
output = zeros(m,n);
output = input - repmat(nanmean(input,1),m,1);
output = output./repmat(nanstd(input,0,1),m,1);