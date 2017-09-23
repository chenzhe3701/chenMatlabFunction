% chenzhe, 2016-3-28
% I have a new version called city-block, it should work the same, and has
% more abilities
%
% gb = grow_unique_gb(gb=uniqueGB input,loop=thickness to grow)
%
% grow the thickness of grain boundary. grain boundary is represented by
% its unique gb_id.  The growth is based on city-block distance.

function gb = grow_unique_gb(gb,loop)

gb(gb==0) = nan;

for ii=1:loop
    disp(['current g.b. thickness: ',num2str(ii)]);
%     gbLayer = zeros(size(gb));
    ind = isnan(gb);
    a = repmat(gb,1,1,4);           % shift ID matrix to find G.B/T.P
    a(:,1:end-1,1) = a(:,2:end,1);  % shift left
    a(:,2:end,2) = a(:,1:end-1,2);  % shift right
    a(1:end-1,:,3) = a(2:end,:,3);  % shift up
    a(2:end,:,4) = a(1:end-1,:,4);  % shift down
%     a(1:end-1,1:end-1,6) = a(2:end,2:end,6);    % shift up-left
%     a(2:end,2:end,7) = a(1:end-1,1:end-1,7);    % shift down-right
%     a(1:end-1,2:end,8) = a(2:end,1:end-1,8);    % shift up-right
%     a(2:end,1:end-1,9) = a(1:end-1,2:end,9);    % shift down-left
    
%     [nR,nC] = size(gb);
%     nR_b = ceil(nR/13000);
%     nC_b = ceil(nC/13000);
%     for iR = 1:nR_b
%         for iC = 1:nC_b
%             gbLayer(1+(iR-1)*3000:min(iR*3000,nR),1+(iC-1)*3000:min(iC*3000,nC)) = mode(a(1+(iR-1)*3000:min(iR*3000,nR),1+(iC-1)*3000:min(iC*3000,nC),:),3);
%         end
%     end
%     gb(ind) = gbLayer(ind);
    
    gbLayer = mode(a,3);
    gb(ind) = gbLayer(ind);
    
end
gb(isnan(gb))=0;

end