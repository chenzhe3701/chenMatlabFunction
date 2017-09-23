% align_IDs(struct_from, struct_to, cpStructure (optional), 'euler-2 setting-2' (optional))
% for debug: load('d:\p\m\temp_ws.mat');
function [myList, tf_struct] = align_IDs(struct_from, struct_to, varargin)

myList = 1;

[boundaryTF1,boundaryID1,neighborID1,tripleTF1,tripleID1] = find_boundary_from_ID_matrix(struct_from.ID);
[boundaryTF2,boundaryID2,neighborID2,tripleTF2,tripleID2] = find_boundary_from_ID_matrix(struct_to.ID);

% figure out projection.
if ~isempty(varargin)
    tf_struct = varargin{1};
    [mp, fp] = cpselect(boundaryTF1, boundaryTF2, tf_struct.mp, tf_struct.fp, 'wait', true);
else
    [mp, fp] = cpselect(boundaryTF1, boundaryTF2, 'wait', true);
end
tf_struct.mp = mp;
tf_struct.fp = fp;
tform = maketform('projective',mp,fp);      % tform defined by [x,y], i.e. [col, row] !!!

% extract useful information: ID, gID
ID_1 = struct_from.ID;
ID_2 = struct_to.ID;

haveEuler = 0;  % have VS not have euler angle field in the input structure

% calculate grainArea, grainCenter, grainIdList, grainEuler (default=0,0,0)  
[gA_1, gC_ind_1, gID_1] = find_numCell_centroidInd_from_ID(ID_1);
gEuler_1 = zeros(size(gID_1,1),3);
if isfield(struct_from, 'gEuler')
    haveEuler = 1;
    t_gID = struct_from.gID;    % temp var, from input
    t_gEu = struct_from.gEuler;
    for ii = 1:size(gEuler_1,1)
        ind_l = find(gID_1(ii) == t_gID);
        if ~isempty(ind_l)
            gEuler_1(ii,:) = t_gEu(ind_l,:);
        end
    end
end

[gA_2, gC_ind_2, gID_2] = find_numCell_centroidInd_from_ID(ID_2);
gEuler_2 = zeros(size(gID_2,1),3);
if isfield(struct_to, 'gEuler')
    haveEuler = 1 && haveEuler;
    t_gID = struct_to.gID;      % temp var, from input
    t_gEu = struct_to.gEuler;
    for ii = 1:size(gEuler_2,1)
        ind_l = find(gID_2(ii) == t_gID);
        if ~isempty(ind_l)
            gEuler_2(ii,:) = t_gEu(ind_l,:);
        end
    end
end

% just make a position matrix, instead of index row, col. For convenience.
[x1,y1] = meshgrid(1:size(ID_1,2), 1:size(ID_1,1));
[x2,y2] = meshgrid(1:size(ID_2,2), 1:size(ID_2,1));
[x1,y1] = tformfwd(tform, x1, y1);

% Project dataset_A to dataset_B
% Commented the following 3 lines.  Could use index rather than poisition. Depending preference.
% [gC_ind_1(:,2),gC_ind_1(:,1)] = tformfwd(tform,gC_ind_1(:,2),gC_ind_1(:,1));
% py = [min(gC_ind_1(:,1)); max(gC_ind_1(:,1))];
% px = [min(gC_ind_1(:,2)); max(gC_ind_1(:,2))];
gC2 = [gC_ind_2(:,2),gC_ind_2(:,1)];    % this is in [x,y] format
gC1 = tformfwd(tform,gC_ind_1(:,2),gC_ind_1(:,1));
t_px = [min(gC1(:,1)); max(gC1(:,1))];  % temporary var.
t_py = [min(gC1(:,2)); max(gC1(:,2))];
[t_px2,t_py2] = tformfwd(tform,t_px,t_py);
t_ratio = (norm([t_px2(2)-t_px2(1), t_py2(2)-t_py2(1)])/norm([t_px(2)-t_px(1),t_py(2)-t_py(1)]))^2;
gA_1 = gA_1 * t_ratio;


% (A) find grain pair match by (1) overlap and (2) misorientation
grainMatch = [];
if length(varargin)==2
    extra = varargin{2};
else
    extra = [];
end
for ii = 1:length(gID_1)
    id_1 = gID_1(ii);
    ind_1 = find(gID_1 == id_1);
    pos_1 = gC1(ind_1,:);
    euler_1 = gEuler_1(ind_1,:);
    for jj = 1:length(gID_2)
        id_2 = gID_2(jj);
        ind_2 = find(gID_2 == id_2);
        pos_2 = gC2(ind_2,:);
        euler_2 = gEuler_2(ind_2,:);
        % When distance_centroid=0 --> 100% overlap.  When distance_centroid = sqrt(Area_A) + sqrt(Area_B) --> 0% overlap.
        % also modify to compare the size difference
        % So, pct overlap ~ 1-dist/(sqrt(A)+sqrt(B))
        overlap = 1-norm(pos_1 - pos_2)/(sqrt(gA_1(ind_1))+sqrt(gA_2(ind_2)));
        overlap = overlap * min(gA_1(ind_1),gA_2(ind_2))/max(gA_1(ind_1),gA_2(ind_2));
        if haveEuler
            miso = calculate_misorientation_hcp(euler_1,euler_2,extra);
        else
            miso = 0;
        end
        grainMatch = [grainMatch; id_1, id_2, overlap, miso];
    end
end
grainMatch = sortrows(grainMatch,-3);
% perform a rough grain match, and regenerate a renumbered map (miso not accurate to be usable, don't know why yet)
gLink = [];
gAtoB = zeros(size(gID_1,1),1);
gBtoA = zeros(size(gID_2,1),1);
mapAtoB = zeros(size(ID_1));
mapBtoA = zeros(size(ID_2));
ii = 1;
while grainMatch(ii,3)>0
    if logical(sum(gAtoB(:)==0)+sum(gBtoA(:)==0))
        currentPair = grainMatch(ii,1:2);
        if (gAtoB(gID_1 == currentPair(1))==0) && (gBtoA(gID_2 == currentPair(2))==0)
            gAtoB(gID_1 == currentPair(1)) = currentPair(2);
            gBtoA(gID_2 == currentPair(2)) = currentPair(1);
            gLink = [gLink;currentPair];
            mapAtoB(ID_1 == currentPair(1)) = currentPair(2);
            mapBtoA(ID_2 == currentPair(2)) = currentPair(1);
        end
    else
        break;
    end
    ii = ii + 1;
end
CHECK_GRAIN_ALIGNMENT = 0;
if CHECK_GRAIN_ALIGNMENT == 1    % check grain alignment
    h=myplot(x1,y1,ID_1);
    label_map_with_ID(x1,y1,ID_1,h);
    h=myplot(x2,y2,ID_2,boundaryTF2);
    label_map_with_ID(x2,y2,ID_2,h);
    h=myplot(x1,y1,mapAtoB,boundaryTF1);
    label_map_with_ID(x1,y1,mapAtoB,h);
    h=myplot(x2,y2,mapBtoA,boundaryTF2);
    label_map_with_ID(x2,y2,mapBtoA,h);
end

% -- find triple point from ID_matrix. tripple#, pos, nearby grainIds
% -- find gb points. collect pt#, position, 2 neighbor grainIds
% -- find gbFeature. collect gb#, points.
% -- a 'ptList' would be easy to make: id(ind), pos_x, pos_y, is_gb

% tripleStructure: [num, ind, indR, indC, x, y, id, ngs]
t_num = 0;
for ii = 1:length(tripleTF1(:))
    if tripleTF1(ii)
        [indR, indC] = ind2sub(size(tripleTF1),ii);
        t_num = t_num + 1;
        local_ids = find_local_ids(ID_1,ii,1);      % find local ids within 5x5 window 5 = 1+2x2
        ngs = local_ids(local_ids ~= ID_1(ii));     % neighbor grains
        tripleStructure_1(t_num) = struct('num',t_num, 'ind',ii, 'indR',indR, 'indC',indC, 'x',x1(ii), 'y',y1(ii), 'id',ID_1(ii), 'ngs',ngs);
    end
end
t_num = 0;
for ii = 1:length(tripleTF2(:))
    if tripleTF2(ii)
        [indR, indC] = ind2sub(size(tripleTF2),ii);
        t_num = t_num + 1;
        local_ids = find_local_ids(ID_2,ii,2);      % find local ids within 5x5 window 5 = 1+2x2
        ngs = local_ids(local_ids ~= ID_2(ii));     % neighbor grains
        tripleStructure_2(t_num) = struct('num',t_num, 'ind',ii, 'indR',indR, 'indC',indC, 'x',x2(ii), 'y',y2(ii), 'id',ID_2(ii), 'ngs',ngs);
    end
end

% (B) find triple point match
tripleMatch = [];
% for each triple point in mapA, (1) find its index in mapA, (2) find the
% grain neighbor it belongs to in mapA and mapB
% (3) for each of the grain in the grain neighbor, find their triple points
% (4) for each of these triple points find distance, and (5)grain intersection
for ii = 1:length(tripleStructure_1)
    if tripleStructure_1(ii).id ~= 0
        ind_a = tripleStructure_1(ii).ind;  % (1) find its index in mapA
        id_a = tripleStructure_1(ii).id;
        pos_a = [tripleStructure_1(ii).x,tripleStructure_1(ii).y];
        
        nbs_a = [tripleStructure_1(ii).id; tripleStructure_1(ii).ngs];  % (2) find the grain neighbor it belongs to in mapA
        
        nbs_AtoB = [];
        for jj = 1:length(nbs_a)
            nb_AtoB = gAtoB(find(gID_1==nbs_a(jj)));
            nbs_AtoB = [nbs_AtoB,nb_AtoB];
        end
        
        for jj = 1:length(nbs_a)
            nb_a = nbs_a(jj);   % for each of the triple point's neighbor in mapA
            if nb_a ~= 0
                nb_b = gAtoB(gID_1 == nb_a);    % the corresponding grain ID in mapB
                if nb_b ~= 0
                    index1 =  find(arrayfun(@(x) x.id == nb_b, tripleStructure_2));     % find all triple points associated with this grain
                    index2 =  find(arrayfun(@(x) sum(x.ngs == nb_b)>0, tripleStructure_2));
                    index = [index1(:);index2(:)];   % (3) find nb_b's triple points' index in tripleStructure_2
                    
                    % (4) for each of these triple points in mapB, form tripleMatch structure
                    for kkk = 1:length(index)
                        kk = index(kkk);
                        ind_b = tripleStructure_2(kk).ind;
                        if tripleID2(ind_b)~=0
                            id_b = tripleStructure_2(kk).id;
                            pos_b = [tripleStructure_2(kk).x,tripleStructure_2(kk).y];
                            triple_distance = sqrt((tripleStructure_1(ii).x-tripleStructure_2(kk).x)^2 + (tripleStructure_1(ii).y-tripleStructure_2(kk).y)^2);
                            nbs_b = [tripleStructure_2(kk).id;tripleStructure_2(kk).ngs];    % the triple points' all neighbor grain in mapB
                            n_gIntersection = intersect(nbs_AtoB,nbs_b);
                            n_gIntersection = length(unique(n_gIntersection));
                            
                            t_ind = find(gLink(:,1)==id_a);
                            if ~isempty(t_ind)
                                id_b_matched = gLink(t_ind,2);
                                if id_b_matched == id_b
                                    tripleMatch = [tripleMatch; ind_a, ind_b, triple_distance, n_gIntersection, pos_a, pos_b, id_a, id_b, 1];
                                else
                                    tripleMatch = [tripleMatch; ind_a, ind_b, triple_distance, n_gIntersection, pos_a, pos_b, id_a, id_b, 0];
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
ind_t = (tripleMatch(:,4)>2)&(tripleMatch(:,11)==1);    % nb grains > 2, ID must be the same
tripleMatch = tripleMatch(ind_t,:);
[~,ia,~] = unique(tripleMatch(:,[1,2]),'rows');
tripleMatch = tripleMatch(ia,:);
tripleMatch = sortrows(tripleMatch, [3, -4]);

maptAtoB = zeros(size(ID_1));
maptBtoA = zeros(size(ID_2));

% perform a rough triple match, and regenerate a renumbered map (miso not accurate to be usable, don't know why yet)
tLink = [];
tripleInd_1 = find(tripleTF1(:)>0);
tripleInd_2 = find(tripleTF2(:)>0);
tAtoB = zeros(length(tripleInd_1),1);
tBtoA = zeros(length(tripleInd_2),1);

ii = 1;
while tripleMatch(ii,3)< 20
    if logical(sum(tAtoB(:)==0)+sum(tBtoA(:)==0))
        currentPair = tripleMatch(ii,1:2);
        if (tAtoB(tripleInd_1 == currentPair(1))==0) && (tBtoA(tripleInd_2 == currentPair(2))==0)
            tAtoB(tripleInd_1 == currentPair(1)) = currentPair(2);
            tBtoA(tripleInd_2 == currentPair(2)) = currentPair(1);
            tLink = [tLink;currentPair];
            maptAtoB(currentPair(1)) = ii;
            maptBtoA(currentPair(2)) = ii;
        end
    else
        break;
    end
    ii = ii + 1;
end
CHECK_TRIPPLE_ALIGNMENT = 1;
if CHECK_TRIPPLE_ALIGNMENT == 1    % check grain alignment
    tt = boundaryTF1*(-1);
    tt(tt==0) = nan;
    myplot(x1,y1,tt);
    hold;
    for ii=1:length(maptAtoB(:))
        if maptAtoB(ii)>0
            scatter(x1(ii),y1(ii));
            text(x1(ii),y1(ii),num2str(maptAtoB(ii)));
        end
    end
    tt = boundaryTF2*(-1);
    tt(tt==0) = nan;
    myplot(x2,y2,tt);
    hold;
    for ii=1:length(maptBtoA(:))
        if maptBtoA(ii)>0
            scatter(x2(ii),y2(ii));
            text(x2(ii),y2(ii),num2str(maptBtoA(ii)));
        end
    end
end
close all;

t_num = 0;
for ii = 1:length(boundaryTF1(:))
    if boundaryTF1(ii)
        [indR, indC] = ind2sub(size(boundaryTF1),ii);
        t_num = t_num + 1;
        nb = neighborID1(ii);     % neighbor grains
        gbPtStructure_1(t_num) = struct('num',t_num, 'ind',ii, 'indR',indR, 'indC',indC, 'x',x1(ii), 'y',y1(ii), 'id',ID_1(ii), 'nb',nb);
    end
end


save('temp_ws')

end

% find local grain IDs based on input ID_matrix, target index, half_window_size
function local_ids = find_local_ids(ID,ind,hws)     % hws = half_window_size
[nR,nC] = size(ID);
[iR,iC] = ind2sub([nR,nC],ind);
cols = (-hws:hws) + iC;
cols = cols((cols>=1)&(cols<=nC));
rows = (-hws:hws) + iR;
rows = rows((rows>=1)&(rows<=nR));
local_ids = ID(rows,cols);
local_ids = unique(local_ids(:));
end

