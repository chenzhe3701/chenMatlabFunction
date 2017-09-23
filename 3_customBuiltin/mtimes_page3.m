% mutiple each page
function out = mtimes_page3(a,b,c)
if size(b,3)==1
   b = repmat(b,1,1,size(a,3)); 
end
for ii=1:size(a,3)
    out(:,:,ii) = a(:,:,ii)*b(:,:,ii)*c(:,:,ii);
end
end