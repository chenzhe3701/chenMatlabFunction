% align_IDs(struct_from, struct_to, cpStructure (optional), 'euler-2 setting-2' (optional))
% for debug: load('d:\p\m\temp_ws.mat');
function [myList, ft_struct] = align_IDs(struct_from, struct_to, varargin)

CHECK_TRIPPLE_ALIGNMENT = 1;
CHECK_GRAIN_ALIGNMENT = 1;
myList = 1;
% extract useful information: ID, gID
ID_1 = struct_from.ID;
ID_2 = struct_to.ID;

[boundaryTF1,boundaryID1,neighborID1,tripleTF1,tripleID1] = find_boundary_from_ID_matrix(struct_from.ID);
[boundaryTF2,boundaryID2,neighborID2,tripleTF2,tripleID2] = find_boundary_from_ID_matrix(struct_to.ID);

% simple method to determine if grain is on edge
edgeID_1 = unique([ID_1(1,:),ID_1(end,:),(ID_1(:,1))',(ID_1(:,end))']);
edgeID_2 = unique([ID_2(1,:),ID_2(end,:),(ID_2(:,1))',(ID_2(:,end))']);

% Figure out projection and output.  If already exist, use as default.  
if ~isempty(varargin) && ~isempty(varargin{1})
    ft_struct = varargin{1};
    [mp, fp] = cpselect(boundaryTF1, boundaryTF2, ft_struct.mp, ft_struct.fp, 'wait', true);
else
    [mp, fp] = cpselect(boundaryTF1, boundaryTF2, 'wait', true);
end
ft_struct.mp = mp;
ft_struct.fp = fp;
tform = maketform('projective',mp,fp);      % tform defined by [x,y], i.e. [col, row] !!!

haveEuler = 0;  % have VS not have euler angle field in the input structure
% calculate grainArea, grainCenter, grainIdList, grainEuler (default=0,0,0)
[gA_1, gC_ind_1, gID_1] = find_numCell_centroidInd_from_ID(ID_1);
gEuler_1 = zeros(size(gID_1,1),3);  % initialize as zero
if isfield(struct_from, 'gEuler')
    haveEuler = 1;
    t_gID = struct_from.gID;    % temp var, from input
    t_gEu = struct_from.gEuler;
    for ii = 1:size(gEuler_1,1)
        t_ind = find(gID_1(ii) == t_gID);
        if ~isempty(t_ind)
            gEuler_1(ii,:) = t_gEu(t_ind,:);
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
        t_ind = find(gID_2(ii) == t_gID);
        if ~isempty(t_ind)
            gEuler_2(ii,:) = t_gEu(t_ind,:);
        end
    end
end
clear t_gID t_gEu t_ind;    % clear temp variables

% Commented the following 3 lines.  Could use index rather than poisition. Depending preference.
% [gC_ind_1(:,2),gC_ind_1(:,1)] = round(tformfwd(tform,gC_ind_1(:,2),gC_ind_1(:,1)));
% py = [min(gC_ind_1(:,1)); max(gC_ind_1(:,1))];
% px = [min(gC_ind_1(:,2)); max(gC_ind_1(:,2))];
gC_linear_ind_1 = sub2ind(size(ID_1),gC_ind_1(:,1),gC_ind_1(:,2));      % linear index of grain center on mapA
gC_linear_ind_2 = sub2ind(size(ID_2),gC_ind_2(:,1),gC_ind_2(:,2));

% just make a position matrix, instead of index row, col. For convenience.
[x1_0,y1_0] = meshgrid(1:size(ID_1,2), 1:size(ID_1,1));
[x2,y2] = meshgrid(1:size(ID_2,2), 1:size(ID_2,1));
[x1,y1] = tformfwd(tform, x1_0, y1_0);          % [x1,y1] x,y of 'from' projected onto 'to'

% Project dataset_A to dataset_B
gC2 = [gC_ind_2(:,2),gC_ind_2(:,1)];    % this is in [x,y] format
gC1 = tformfwd(tform,gC_ind_1(:,2),gC_ind_1(:,1));      % gC1 projected onto 'to'
ID_1to2 = interp_data(x1_0,y1_0,ID_1,x2,y2,tform,'interp','nearest');
idPair = [ID_1to2(:),ID_2(:)];
idPair = unique(idPair,'rows');     % These are the grainPairs with overlap 

% (A) find grain pair match by (1) overlap and (2) misorientation
if length(varargin)==2
    extra = varargin{2};
else
    extra = [];
end
grainMatch = [];
for ii = 1:size(idPair,1)
    id_1 = idPair(ii,1);
    ind_1 = (gID_1 == id_1);
    euler_1 = gEuler_1(ind_1,:);
    
    id_2 = idPair(ii,2);
    ind_2 = (gID_2 == id_2);
    euler_2 = gEuler_2(ind_2,:);
    
    numerator = (ID_1to2==id_1)&(ID_2==id_2);
    denominator = [(ID_1to2==id_1),(ID_2==id_2)];
    overlap = 2 * sum(numerator(:))/sum(denominator(:));
    if haveEuler
        miso = calculate_misorientation_hcp(euler_1,euler_2,extra);
    else
        miso = 0;
    end
    grainMatch = [grainMatch; id_1, id_2, overlap, miso];    
end
grainMatch = sortrows(grainMatch,-3);

% perform a rough grain match, and regenerate a renumbered map (miso not accurate to be usable, don't know why yet)
gCLink = [];
gLink = [];
gAtoB = zeros(size(gID_1,1),1);
gBtoA = zeros(size(gID_2,1),1);
mapAtoB = zeros(size(ID_1));
mapBtoA = zeros(size(ID_2));
ii = 1;
while grainMatch(ii,3) > 0.66                                % Criterion: grain overlap.  -----------------------------------------------------------------------------------------
    if logical(sum(gAtoB(:)==0)+sum(gBtoA(:)==0))
        currentPair = grainMatch(ii,1:2);
        if (gAtoB(gID_1 == currentPair(1))==0) && (gBtoA(gID_2 == currentPair(2))==0)   % grain match not assigned yet
            gAtoB(gID_1 == currentPair(1)) = currentPair(2);
            gBtoA(gID_2 == currentPair(2)) = currentPair(1);
            gLink = [gLink;currentPair];
            % if grain is not on edge of map, link the centroid positions [ind1,x1to2,y1to2,ind2,x2,y2] 
            if isempty(intersect(edgeID_1,currentPair(1))) && isempty(intersect(edgeID_2,currentPair(2)))
                gCLink = [gCLink; gC_linear_ind_1(gID_1 == currentPair(1)), x1(gID_1 == currentPair(1)), y1(gID_1 == currentPair(1)),...
                    gC_linear_ind_2(gID_2 == currentPair(2)), x2(gID_2 == currentPair(2)), y2(gID_2 == currentPair(2))];
            end
            mapAtoB(ID_1 == currentPair(1)) = currentPair(2);
            mapBtoA(ID_2 == currentPair(2)) = currentPair(1);
        end
    else
        break;
    end
    ii = ii + 1;
end

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


% For each matched grain, find it's triple points, compare the triple
% points' (1) location, (2) neighbors, (3) angle from grain center, to
% match triple point.
%

tMatch = [];
for ii = 1:size(gLink,1)
    clear tListA;
    clear tListB;
    grainAinA = gLink(ii,1);    % grainA's ID on Map_A
    inds = find(tripleID1==grainAinA);   % find grainA's triple points
    grainCenter = gC1(find(gID_1==grainAinA),:);
    % function sort_grain_triple_point
    for jj = 1:length(inds)
        indA = inds(jj);
        tListA(jj).ind = indA;
        tListA(jj).pos = [x1(indA),y1(indA)];
        vec = [x1(indA),y1(indA)] - grainCenter;
        tListA(jj).angle = acosd(dot(vec/norm(vec), [1,0])) * sign(vec(2));
        nb = find_local_ids(mapAtoB,indA,1);
        nb(nb==0) = [];
        tListA(jj).nb = nb;
    end
    
    grainBinB = gLink(ii,2);    % grainB's ID on Map_B
    inds = find(tripleID2==grainBinB);   % find grainA's triple points
    grainCenter = gC2(find(gID_2==grainBinB),:);
    % function sort_grain_triple_point
    for jj = 1:length(inds)
        indA = inds(jj);
        tListB(jj).ind = indA;
        tListB(jj).pos = [x2(indA),y2(indA)];
        vec = [x2(indA),y2(indA)] - grainCenter;
        tListB(jj).angle = acosd(dot(vec/norm(vec), [1,0])) * sign(vec(2));
        nb =  find_local_ids(ID_2,indA,1);
        nb(nb==0) = [];
        tListB(jj).nb = nb;
    end
    
    % compare grainA and grainB 's triple points to match
    tMatch_local = [];
    for jj = 1:length(tListA)
        for kk = 1:length(tListB)
            t_dist = norm(tListA(jj).pos - tListB(kk).pos);
            d_angle = mod(tListA(jj).angle - tListB(kk).angle, 360);
            c_nb = length(intersect(tListA(jj).nb, tListB(kk).nb));
            tMatch_local = [tMatch_local; tListA(jj).ind, tListB(kk).ind, t_dist, d_angle, c_nb];
        end
    end
    tMatch_local = sortrows(tMatch_local,[-5,4,3]);
    tMatch_local = tMatch_local( (tMatch_local(:,4)<30)&(tMatch_local(:,5)>=2)&(tMatch_local(:,3)<10) ,:);   % criterion: angleDiff<30, commonNeighbor>=3, distDiff<30  ------------------------
    [~,IA,~] = unique(tMatch_local(:,1),'rows');
    tMatch_local = tMatch_local(IA,:);
    [~,IA,~] = unique(tMatch_local(:,2),'rows');
    tMatch_local = tMatch_local(IA,:);
    tMatch = [tMatch;tMatch_local];
end

% triple point map
maptAtoB = zeros(size(ID_1));
maptBtoA = zeros(size(ID_2));
tLink_0 = [];
tripleInd_1 = find(tripleTF1(:)>0);
tripleInd_2 = find(tripleTF2(:)>0);
tAtoB = zeros(length(tripleInd_1),1);
tBtoA = zeros(length(tripleInd_2),1);

ii = 1;
while ii<=size(tMatch,1)
    if logical(sum(tAtoB(:)==0)+sum(tBtoA(:)==0))
        currentPair = tMatch(ii,1:2);
        if (tAtoB(tripleInd_1 == currentPair(1))==0) && (tBtoA(tripleInd_2 == currentPair(2))==0)
            tAtoB(tripleInd_1 == currentPair(1)) = currentPair(2);
            tBtoA(tripleInd_2 == currentPair(2)) = currentPair(1);
            tLink_0 = [tLink_0;currentPair];
            maptAtoB(currentPair(1)) = ii;
            maptBtoA(currentPair(2)) = ii;
        end
    else
        break;
    end
    ii = ii + 1;
end

if CHECK_TRIPPLE_ALIGNMENT == 1    % check grain alignment
    check_alignment(maptAtoB,maptBtoA,boundaryTF1,boundaryTF2,x1,y1,x2,y2);
end

% Need to reduce matched triple points (some are too close.  If so, choose only one)
% using their position on mapA.  If diff(subX + subY)<=8, i.e., within a 5x5 window, consider as one point
% dynamically reduce 'tLink'
ii = 0;
targetIndDiff = [[-2,-1,0,1,2], size(ID_1,1)+[-2,-1,0,1,2], 2*size(ID_1,1)+[-2,-1,0,1,2], -size(ID_1,1)+[-2,-1,0,1,2], -2*size(ID_1,1)+[-2,-1,0,1,2]];
while (ii<size(tLink_0,1))
    ii = ii + 1;
    currentInd = tLink_0(ii,1);
    indToRemove = [];
    for jj = ii+1 : size(tLink_0,1)
        if intersect(currentInd - tLink_0(jj,1), targetIndDiff)
            indToRemove = [indToRemove,jj];
        end
    end
    tLink_0(indToRemove,:) = [];
end
% do it again using position on mapB
tLink = tLink_0;
ii = 0;
targetIndDiff = [[-2,-1,0,1,2], size(ID_2,1)+[-2,-1,0,1,2], 2*size(ID_2,1)+[-2,-1,0,1,2], -size(ID_2,1)+[-2,-1,0,1,2], -2*size(ID_2,1)+[-2,-1,0,1,2]];
while (ii<size(tLink,1))
    ii = ii + 1;
    currentInd = tLink(ii,2);
    indToRemove = [];
    for jj = ii+1 : size(tLink,1)
        if intersect(currentInd - tLink(jj,2), targetIndDiff)
            indToRemove = [indToRemove,jj];
        end
    end
    tLink(indToRemove,:) = [];
end

% create map again, after removing redundant triple points
maptAtoB = zeros(size(ID_1));
maptBtoA = zeros(size(ID_2));
ii = 1;
while ii<=size(tLink,1)
    currentPair = tLink(ii,1:2);
    maptAtoB(currentPair(1)) = ii;
    maptBtoA(currentPair(2)) = ii;
    ii = ii + 1;
end

if CHECK_TRIPPLE_ALIGNMENT == 1    % check grain alignment
    check_alignment(maptAtoB,maptBtoA,boundaryTF1,boundaryTF2,x1,y1,x2,y2);
end


% Then for each grain boundary, find it's two end points, then rank
% boundary points, asign point pairs based on distance
pLink = tLink;
for ii = 1:size(gCLink,1)
    pLink = [pLink; gCLink(ii,1), gCLink(ii,4)];
end
% create map again, after removing redundant triple points
maptAtoB = zeros(size(ID_1));
maptBtoA = zeros(size(ID_2));

ii = 1;
while ii<=size(pLink,1)
    currentPair = pLink(ii,1:2);
    maptAtoB(currentPair(1)) = ii;
    maptBtoA(currentPair(2)) = ii;
    ii = ii + 1;
end

if CHECK_TRIPPLE_ALIGNMENT == 1    % check grain alignment
    check_alignment(maptAtoB,maptBtoA,boundaryTF1,boundaryTF2,x1,y1,x2,y2);
end


% Possible solution (1): Then these triple points, gb points are control points for SOM-type
% growth.
% Or, Possible solution (2): use local geometric transformation. based on pLink.

% select 16 additional control points along the edge of the smaller image
if x1(1) < x2(1)
    % select points on mapB border
    [nR,nC] = size(x2);
    subR2 = round([1,1,1,1,1, nR*0.25,nR*0.25, nR*0.5,nR*0.5, nR*0.75,nR*0.75, nR,nR,nR,nR,nR]);
    subC2 = round([1,nC*0.25,nC*0.5,nC*0.75,nC, 1,nC, 1,nC, 1,nC, 1,nC*0.25,nC*0.5,nC*0.75,nC]);
    ind2 = sub2ind(size(x2),subR2,subC2);
    
    [subC1, subR1] = tforminv(tform, subC2, subR2);
    subC1 = round(subC1);
    subR1 = round(subR1);
    ind1 = sub2ind(size(x1),subR1,subC1);
    
else
    % select points on mapA border
    [nR,nC] = size(x1);
    subR1 = round([1,1,1,1,1, nR*0.25,nR*0.25, nR*0.5,nR*0.5, nR*0.75,nR*0.75, nR,nR,nR,nR,nR]);
    subC1 = round([1,nC*0.25,nC*0.5,nC*0.75,nC, 1,nC, 1,nC, 1,nC, 1,nC*0.25,nC*0.5,nC*0.75,nC]);
    ind1 = sub2ind(size(x1),subR1,subC1);
    
    [subC2, subR2] = tformfwd(tform, subC1, subR1);
    subC2 = round(subC2);
    subR2 = round(subR2);
    ind2 = sub2ind(size(x2),subR2,subC2);
end
pLink = [pLink;ind1(:),ind2(:)];

maptAtoB = zeros(size(ID_1));
maptBtoA = zeros(size(ID_2));

ii = 1;
while ii<=size(pLink,1)
    currentPair = pLink(ii,1:2);
    maptAtoB(currentPair(1)) = ii;
    maptBtoA(currentPair(2)) = ii;
    ii = ii + 1;
end

if CHECK_TRIPPLE_ALIGNMENT == 1    % check grain alignment
    check_alignment(maptAtoB,maptBtoA,boundaryTF1,boundaryTF2,x1,y1,x2,y2);
end


% Do triangulation in the index space
[R1,C1] = ind2sub(size(x1),pLink(:,1));
[R2,C2] = ind2sub(size(x2),pLink(:,2));
TRI = delaunay(C1,R1);                  
figure;triplot(TRI,C1,R1);set(gca,'ydir','reverse');
hold on;
for ii=1:length(C1)
   text(C1(ii),R1(ii),num2str(ii)); 
end
% TRI2 = delaunay(C2,R2);
figure;triplot(TRI,C2,R2);set(gca,'ydir','reverse');
hold on;
for ii=1:length(C2)
   text(C2(ii),R2(ii),num2str(ii)); 
end


% for each triangle, do affine transformation
[cMat1,rMat1] = meshgrid(1:size(x1,2),1:size(x1,1));
indMat1 = reshape(1:length(x1(:)),size(x1));
[cMat2,rMat2] = meshgrid(1:size(x2,2),1:size(x2,1));
indMat2 = reshape(1:length(x2(:)),size(x2));

indMatch = [];
for ii = 1:length(TRI)
    
    cpFrom = [C1(TRI(ii,:),1),R1(TRI(ii,:),1)];
    cpTo = [C2(TRI(ii,:),1),R2(TRI(ii,:),1)];
    try
        tfm = maketform('affine',cpFrom,cpTo);  
    catch
        tfm = [];
    end
    % find [r,c] inside triangle cpFrom
    indA = find(isPointInTriangle([cMat1(:),rMat1(:)],cpFrom(1,:),cpFrom(2,:),cpFrom(3,:)));
    [c_B, r_B] = tformfwd(tfm, cMat1(indA), rMat1(indA));
    c_B = round(c_B);
    r_B = round(r_B);
    
    ind = find((c_B<1)|(c_B)>size(x2,2)|(r_B<1)|(r_B>size(x2,1)));
    indA(ind) = [];
    c_B(ind) = [];
    r_B(ind) = [];
    
    indB = sub2ind(size(x2), r_B, c_B);
    indMatch = [indMatch; indA,indB];
end
ID_AtoB = ID_2;
ID_BtoA = ID_1;
ID_AtoB(indMatch(:,2)) = ID_1(indMatch(:,1));
ID_BtoA(indMatch(:,1)) = ID_2(indMatch(:,2));
myplot(ID_AtoB);
myplot(ID_BtoA);

% plot ID_1 using the projected position
figure;
scatter3(x2(indMatch(:,2)),y2(indMatch(:,2)),ID_1(indMatch(:,1)),6,ID_1(indMatch(:,1)));
view(0,90);axis equal;
set(gca,'ydir','reverse');

% some grain boundary related code
% t_num = 0;
% for ii = 1:length(boundaryTF1(:))
%     if boundaryTF1(ii)
%         [indR, indC] = ind2sub(size(boundaryTF1),ii);
%         t_num = t_num + 1;
%         nb = neighborID1(ii);     % neighbor grains
%         gbPtStructure_1(t_num) = struct('num',t_num, 'ind',ii, 'indR',indR, 'indC',indC, 'x',x1(ii), 'y',y1(ii), 'id',ID_1(ii), 'nb',nb);
%     end
% end

if CHECK_TRIPPLE_ALIGNMENT
    
else
    close all;
    save('temp_ws');
end

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

function [] = check_alignment(maptAtoB,maptBtoA,boundaryTF1,boundaryTF2,x1,y1,x2,y2)

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