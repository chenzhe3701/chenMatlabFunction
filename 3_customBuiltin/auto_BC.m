
function I = auto_BC(I)
% image normalization 

p = quantile(I(:), [0.001, 0.999]);
old_min = p(1);
old_max = p(2);

new_min = 0;
new_max = 65535;

I = (I - old_min) * ((new_max - new_min)/(old_max - old_min)) + new_min;

I(I<0) = 0;
I(I>65535) = 65535;
I = round(I);

end