function colors = mix_color(n)

c1 = inferno(n);
c2 = viridis(n);

clear colors
for ii = 1:2:n
    colors(ii,:) = c1(ii,:);
end
for jj = 2:2:n
    colors(jj,:) = c2(jj,:);
end

end