% mutiple each page
% chenzhe, 2016-11-4

function out = mtimes_page(varargin)
nPages = 0;
for ii = 1:length(varargin)
   M{ii} = varargin{ii}; 
   if nPages < size(M{ii},3)
       nPages = size(M{ii},3);
   end
end

for ii = 1:length(M)
   if size(M{ii},3)<nPages
      temp = repmat(M{ii},1,1,ceil(nPages/size(M{ii},3)));
      M{ii} = temp(:,:,1:nPages);
   end
end

for iPage=1:nPages
    out(:,:,iPage) = eye(size(M{1}(:,:,1)));
    for jj = 1:length(M)
        out(:,:,iPage) = out(:,:,iPage) * M{jj}(:,:,iPage);
    end
end
end