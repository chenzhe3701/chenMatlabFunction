% chenzhe, 2017-06-05
%
% combine two indMatch matrices. M1=[indA,indB], M2 = [indb,indc]
function M = combine_match(M1,M2)

M = M1;
N = size(M2,1);
h = waitbar(0,'progress of combining');
for ii = 1:N
    ind = find(M(:,2)==M2(ii,1));
    if ~isempty(ind)
        M(ind,3) = M2(ii,2);
    else
        M = [M;0,M2(ii,:)];
    end
    if rem(ii,10000)==1
       waitbar(ii/N,h); 
    end
end
close(h);
end