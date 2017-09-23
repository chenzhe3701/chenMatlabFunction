% chenzhe, 2016-3-29
%
% [dist, uniqueGB] = city_block(uniqueGB, loop_limit), uniqueGB is a matrix,
% boundary is number, interior is 0 or nan
% calculate city block distance map from uniqueGB, for maximum of
% loop_limit loops.
% 
% output: (1) dist is the matrix containing city-block distance
% (2) uniqueGB is a matrix showing the id of the uniqueGB to which each
% pixel's city-block-distance is calculated from.

function [dist, uniqueGB] = city_block_slow(uniqueGB,loop_limit)

uniqueGB(uniqueGB==0) = nan;
dist = uniqueGB;
dist(isnan(dist))=0;
dist = double(logical(dist));

f = [0 1 0; 1 0 1; 0 1 0];
loop = 1;

while sum(isnan(uniqueGB(:))) && (loop<=loop_limit)

    disp(['current g.b. thickness: ',num2str(loop)]);
%     gbLayer = zeros(size(gb));
    ind = isnan(uniqueGB);
    a = repmat(uniqueGB,1,1,4);           % shift ID matrix to find G.B/T.P
    a(:,1:end-1,1) = a(:,2:end,1);  % shift left
    a(:,2:end,2) = a(:,1:end-1,2);  % shift right
    a(1:end-1,:,3) = a(2:end,:,3);  % shift up
    a(2:end,:,4) = a(1:end-1,:,4);  % shift down
%     a(1:end-1,1:end-1,6) = a(2:end,2:end,6);    % shift up-left
%     a(2:end,2:end,7) = a(1:end-1,1:end-1,7);    % shift down-right
%     a(1:end-1,2:end,8) = a(2:end,1:end-1,8);    % shift up-right
%     a(2:end,1:end-1,9) = a(1:end-1,2:end,9);    % shift down-left
    
    [nR,nC] = size(uniqueGB);
    nR_b = ceil(nR/7000);
    nC_b = ceil(nC/7000);
    for iR = 1:nR_b
        for iC = 1:nC_b
            uniqueGBLayer(1+(iR-1)*7000:min(iR*7000,nR),1+(iC-1)*7000:min(iC*7000,nC)) = mode(a(1+(iR-1)*7000:min(iR*7000,nR),1+(iC-1)*7000:min(iC*7000,nC),:),3);
        end
    end
    uniqueGB(ind) = uniqueGBLayer(ind);
    
%     uniqueGBLayer = mode(a,3);            % for large matrix, this is slow because it takes up all of the memory 
%     uniqueGB(ind) = uniqueGBLayer(ind);
%     
    grown = filter2(f,dist,'same');
    dist = dist + (logical(grown)-logical(dist))*loop;
    loop = loop + 1;
end

dist = dist - 1;
uniqueGB(isnan(uniqueGB))=0;

end