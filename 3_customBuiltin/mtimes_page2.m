% mutiple each page
function out = mtimes_page2(a,b)
for ii=1:size(a,3)
    out(:,:,ii) = a(:,:,ii)*b(:,:,ii);
end
end