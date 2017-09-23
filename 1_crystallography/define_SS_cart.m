% use function [ssa,c_a] = define_SS
% then convert ssa (hex) to ss (cart)
function [ss,c_a,ssa] = define_SS_cart(str1,str2)
[ssa,c_a] = define_SS(str1,str2);
ss = hex_to_cart_ss(ssa,c_a);