% chenzhe, 2016-4-5 revised
% chenzhe, 2016-3-11
%
% The grain boundary is approximated by strainght lines between triple points
%
% The gb position is defined by two end points: [pt1_x, pt1_y, pt2_x,
% pt2_y], pt1 is always on the left. (In extreme condition,pt1 is on top).
%
% The gb direction is [x,y,0], x is always > = 0. If x=0, then y>0.
%
% The gb normal direction is [x,y,0], y is always >=0.  If y=0, then x>0.
%
% the normal_into_grain is [x,y,0]. It points into grain_#1.

function gbStruct = construct_grain_boundary_structrue_from_ID_matrix(ID_,X,Y)

[boundaryTF, ~, ~,tripleTF,~] = find_boundary_from_ID_matrix(ID_);  % find g.b.

% if boundary meet edge of map, this is turned into a triple point
[nR,nC] = size(boundaryTF);
tripleTF(1,logical(boundaryTF(1,:))) = 1;
tripleTF(nR,logical(boundaryTF(nR,:))) = 1;
tripleTF(logical(boundaryTF(:,1)),1) = 1;
tripleTF(logical(boundaryTF(:,nC)),nC) = 1;

% assume there is a 3x3 matrix centered at a tripple point
% ind22 is the global-index of the (2,2) element of this local matrix.
% similarly, ind2i is the global index of the 2nd row of this local matrix. 
% Special care was taken on edge elements.
ind22 = find(tripleTF(:));
ind21 = ind22 - nR*(ceil(ind22/nR)>1);
ind23 = ind22 + nR*(ceil(ind22/nR)<nC);
ind2i = [ind21;ind22;ind23];
ind1i = ind2i - 1*(rem(ind2i,nR)>1);
ind3i = ind2i + 1*(rem(ind2i,nR)>0);
indNb = [ind1i;ind2i;ind3i];
ind = repmat(ind22,9,1);


gbMat = [ID_(ind),ID_(indNb),X(ind),Y(ind)];
gbMat = sortrows(gbMat,[1,2,3,4]);
gbMat = gbMat(gbMat(:,1)~=gbMat(:,2),:);
uniquePair = unique(gbMat(:,[1,2]),'rows'); % unique grain pairs


for ii = 1:length(uniquePair)
    inds = (gbMat(:,1)==uniquePair(ii,1))&(gbMat(:,2)==uniquePair(ii,2));
    gb = gbMat(inds,[3,4]); % grain boundary points
    if range(gb(:,1))>range(gb(:,2))
        gb = sortrows(gb,1);
    else
        gb = sortrows(gb,2);
    end
    gbStruct.g1(ii) = uniquePair(ii,1);
    gbStruct.g2(ii) = uniquePair(ii,2);
    % for the two points defining gb, always start with the one with smaller x_coordinate. If x_coord are the same, then start with smaller y_coord.
    if gb(1,1)<gb(end,1)
        gbStruct.pos(ii,:) = [gb(1,:),gb(end,:)];
    elseif gb(1,1)>gb(end,1)
        gbStruct.pos(ii,:) = [gb(end,:),gb(1,:)];
    elseif gb(1,2)<gb(end,2)
        gbStruct.pos(ii,:) = [gb(1,:),gb(end,:)];
    else
        gbStruct.pos(ii,:) = [gb(end,:),gb(1,:)];
    end
    % gb direction = [dx,dy] = [pos3-pos1, pos4-pos2], always pointing to the right half. dx>0. If dx=0, then dy>0.
    gbStruct.dir(ii,:) = [gbStruct.pos(ii,3)-gbStruct.pos(ii,1), gbStruct.pos(ii,4)-gbStruct.pos(ii,2)];
    
    %     gbStruct.pos(ii,:) = [gb(1,:),gb(end,:)];   % In this way, for both g1-g2 and g2-g1, the sequence of the two points defining the gb should be almost the same.  i.e., if x_range is bigger, then gb = (x_small, y1, x_big, y2)
    gbStruct.length(ii) = sqrt( (gbStruct.pos(ii,3)-gbStruct.pos(ii,1))^2 + (gbStruct.pos(ii,4)-gbStruct.pos(ii,2))^2);
    % Direction vector = [dx,dy] = [pos3-pos1, pos4-pos2]
    % Therefore, normal vector = [xn, yn] = [-dy,dx].
    gbStruct.normal(ii,:) = [gbStruct.pos(ii,2)-gbStruct.pos(ii,4),gbStruct.pos(ii,3)-gbStruct.pos(ii,1)];
    
    % For grain boundary normal, make yn=1. If yn=0, then make xn=1.
    if gbStruct.normal(ii,2)~=0
        gbStruct.normal(ii,:) = gbStruct.normal(ii,:)/gbStruct.normal(ii,2);
    else
        gbStruct.normal(ii,:) = gbStruct.normal(ii,:)/gbStruct.normal(ii,1);
    end
    
    id = gbStruct.g1(ii);
    ind = find(gbStruct.g1(:)==id,2);   % if this is the 2nd time, then it's already calculated.
    if length(ind)==2
        ind = ind(1);
        g_center_x = gbStruct.g1_center(ind,1);
        g_center_y = gbStruct.g1_center(ind,2);
    else
        ind = find(ID_==id);
        g_center_x = mean(X(ind));
        g_center_y = mean(Y(ind));
    end
    gbStruct.g1_center(ii,:) = [g_center_x, g_center_y];
    gb_center_x = 0.5*(gbStruct.pos(ii,1)+gbStruct.pos(ii,3));
    gb_center_y = 0.5*(gbStruct.pos(ii,2)+gbStruct.pos(ii,4));
    vec = [g_center_x - gb_center_x, g_center_y-gb_center_y];
    % Make for gb_normal_into_grain, make it pointing into g1.
    gbStruct.normal_into_grain(ii,:) = sign(dot(gbStruct.normal(ii,:),vec)) * gbStruct.normal(ii,:);
    
end
gbStruct.dir(:,3) = 0;
gbStruct.normal(:,3) = 0;
gbStruct.normal_into_grain(:,3) = 0;
gbStruct.g1 = gbStruct.g1';
gbStruct.g2 = gbStruct.g2';
gbStruct.gbId = gbStruct.g1*1000+gbStruct.g2;
gbStruct.length = gbStruct.length';
