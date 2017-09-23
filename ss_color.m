function ss_color = ss_color(str)
if strcmpi(str, 'Mg')
    ss_color = [repmat([1 0 0],3,1); repmat([0 0 1],3,1); repmat([0 1 0], 6, 1); repmat([0 0 0], 6, 1); repmat([1 0.6 0], 6, 1)];
elseif strcmpi(str, 'Ti')
    ss_color = [repmat([1 0 0],3,1); repmat([0 0 1],3,1); repmat([0 1 0], 6, 1); repmat([0 0 0], 12, 1); repmat([1 0.6 0], 6, 1)];
end