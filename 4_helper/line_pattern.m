function pattern = line_pattern()
pt_color = {'r','g','b','k','m'};
pt_line = {'-',':','--'};
pt_symbol = {'o','s','d','h'};
for ii=1:20
   pattern{ii} = [pt_color{rem(ii-1,length(pt_color))+1},pt_line{rem(ii-1,length(pt_line))+1},pt_symbol{rem(ii-1,length(pt_symbol))+1}]; 
end