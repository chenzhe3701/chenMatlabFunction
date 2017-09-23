% align_IDs(struct_from, struct_to, cpStructure (optional), 'euler-2 setting-2' (optional))
% for debug: load('d:\p\m\temp_ws.mat');
%
% returns the match of the index of two matrices
% chenzhe, 2017-06-02.
function [indMatch, ft_struct] = align_IDs(struct_from, struct_to, varargin)

% % for debug
% load('cpStructures.mat');
% varargin{1}=cpStruct2;
% varargin{2} = 'euler-2 setting-2';
% load('Ti7Al_#B6_WS3.mat','s_dream','s_dic','s_ebsd');
% struct_from = s_dream;
% struct_to = s_dic;
% %

CHECK_GRAIN_ALIGNMENT = 0;
CHECK_TRIPPLE_ALIGNMENT = 0;
CHECK_TRIANGULATION = 0;
CHECK_ALIGNMENT = 1;
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
    mp = ft_struct.mp;
    fp = ft_struct.fp;
    %[mp, fp] = cpselect(boundaryTF1, boundaryTF2, ft_struct.mp, ft_struct.fp, 'wait', true);
else
    [mp, fp] = cpselect(boundaryTF1, boundaryTF2, 'wait', true);
end
ft_struct.mp = mp;
ft_struct.fp = fp;
tform = maketform('projective',mp,fp);      % tform defined by [x,y], i.e. [col, row] !!!
tform_inv = maketform('projective',fp,mp); 

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
[x1,y1] = meshgrid(1:size(ID_1,2), 1:size(ID_1,1));
[x2,y2] = meshgrid(1:size(ID_2,2), 1:size(ID_2,1));
[x1to2,y1to2] = tformfwd(tform, x1, y1);          % [x,y] of 'from' projected onto 'to'
[x2to1,y2to1] = tforminv(tform, x2, y2);          % [x,y] of 'to' projected onto 'from'

% Project dataset_A to dataset_B
gC_2 = [gC_ind_2(:,2),gC_ind_2(:,1)];    % this is in [x,y] format
gC_1to2 = tformfwd(tform,gC_ind_1(:,2),gC_ind_1(:,1));      % gC1 projected onto 'to'
ID_1to2 = interp_data(x1,y1,ID_1,x2,y2,tform,'interp','nearest');
ID_2to1 = interp_data(x2,y2,ID_2,x1,y1,tform_inv,'interp','nearest');   % this is just used for checking alignment
idPair = [ID_1to2(:),ID_2(:)];
idPair = idPair((~isnan(idPair(:,1)))&(~isnan(idPair(:,1)))&(idPair(:,1)~=0)&(idPair(:,2)~=0),:);
idPair = unique(idPair,'rows');     % These are the grainPairs with overlap

% (A) Match grains.  Find grain pair match by (1) overlap and (2) misorientation
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
    if (haveEuler==1) % &&(~isempty(euler_1))&&(~isempty(euler_2))
        miso = calculate_misorientation_hcp(euler_1,euler_2,extra);
    else
        miso = 0;
    end
    grainMatch = [grainMatch; id_1, id_2, overlap, miso];
end
grainMatch = sortrows(grainMatch,-3);

% perform a rough grain match, and regenerate a renumbered map (miso not accurate to be usable, don't know why yet)
gCLink = [];    % matched grainCenter positions [ind_1, gC_1to2(1x2 dim), ind_2, gC_2(1x2 dim)]
gLink = [];     % matched grainIds
gAtoB = zeros(size(gID_1,1),1);
gBtoA = zeros(size(gID_2,1),1);
mapAtoB = zeros(size(ID_1));
mapBtoA = zeros(size(ID_2));
ii = 1;
while (ii<=size(grainMatch,1))&&(grainMatch(ii,3) > 0.2)            % Criterion: grain overlap larger than, e.g., 20%.  -----------------------------------------------------------------------------------------
    if logical(sum(gAtoB(:)==0)+sum(gBtoA(:)==0))
        currentPair = grainMatch(ii,1:2);
        if (gAtoB(gID_1 == currentPair(1))==0) && (gBtoA(gID_2 == currentPair(2))==0)   % grain match not assigned yet
            gAtoB(gID_1 == currentPair(1)) = currentPair(2);
            gBtoA(gID_2 == currentPair(2)) = currentPair(1);
            gLink = [gLink;currentPair];
            % if grain is not on edge of map, link the centroid positions [ind1,x1to2,y1to2,ind2,x2,y2]
            if isempty(intersect(edgeID_1,currentPair(1))) && isempty(intersect(edgeID_2,currentPair(2)))
                gCLink = [gCLink; gC_linear_ind_1(gID_1 == currentPair(1)), gC_1to2(gID_1 == currentPair(1),:),...
                    gC_linear_ind_2(gID_2 == currentPair(2)), gC_2(gID_2 == currentPair(2),:)];
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
    h=myplot(x1to2,y1to2,ID_1);
    label_map_with_ID(x1to2,y1to2,ID_1,h);
    h=myplot(x2,y2,ID_2,boundaryTF2);
    label_map_with_ID(x2,y2,ID_2,h);
    h=myplot(x1to2,y1to2,mapAtoB,boundaryTF1);
    label_map_with_ID(x1to2,y1to2,mapAtoB,h);
    h=myplot(x2,y2,mapBtoA,boundaryTF2);
    label_map_with_ID(x2,y2,mapBtoA,h);
end

% (B) Match triple points:
% For each matched grain, find it's triple points, compare the triple
% points' (1) location, (2) neighbors, (3) angle from grain center, to
% match triple point.
tMatch = [];
for ii = 1:size(gLink,1)
    clear tListA;
    clear tListB;
    grainAinA = gLink(ii,1);    % grainA's ID on Map_A
    inds = find(tripleID1==grainAinA);   % find grainA's triple points
    grainCenter = gC_1to2(find(gID_1==grainAinA),:);
    % function sort_grain_triple_point
    for jj = 1:length(inds)
        indA = inds(jj);
        tListA(jj).ind = indA;
        tListA(jj).pos = [x1to2(indA),y1to2(indA)];
        vec = [x1to2(indA),y1to2(indA)] - grainCenter;
        tListA(jj).angle = acosd(dot(vec/norm(vec), [1,0])) * sign(vec(2));
        nb = find_local_ids(mapAtoB,indA,1);    % find local ids on map 'mapAtoB', centered at index position 'indA', within a half-window-size '1'
        nb(nb==0) = [];
        tListA(jj).nb = nb;
    end
    
    grainBinB = gLink(ii,2);    % grainB's ID on Map_B
    inds = find(tripleID2==grainBinB);   % find grainA's triple points
    grainCenter = gC_2(find(gID_2==grainBinB),:);
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
            t_dist = norm(tListA(jj).pos - tListB(kk).pos);             % triple-point distance
            d_angle = mod(abs(tListA(jj).angle - tListB(kk).angle), 360);    % difference in angle
            n_cnb = length(intersect(tListA(jj).nb, tListB(kk).nb));     % number of common neighbors
            tMatch_local = [tMatch_local; tListA(jj).ind, tListB(kk).ind, t_dist, d_angle, n_cnb];
        end
    end
    tMatch_local = sortrows(tMatch_local,[-5,4,3]);
    tMatch_local = tMatch_local( (tMatch_local(:,4)<30)&(tMatch_local(:,5)>=2)&(tMatch_local(:,3)<10) ,:);   % criterion: angleDiff<30, commonNeighbor>=3, distDiff<10  ------------------------
    [~,IA,~] = unique(tMatch_local(:,1),'rows');
    tMatch_local = tMatch_local(IA,:);
    [~,IA,~] = unique(tMatch_local(:,2),'rows');
    tMatch_local = tMatch_local(IA,:);
    tMatch = [tMatch;tMatch_local];
end
clear grainAinA inds grainCenter indA tListA vec nb grainBinB t_dist d_angle n_cnb tMatch_local IA;

% 'mapAtoB' now holds triple point map.  Initial matching:
tLink = [];
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
            tLink = [tLink;currentPair];
        end
    else
        break;
    end
    ii = ii + 1;
end
% check triple point alignment
check_alignment(tLink,boundaryTF1,boundaryTF2,x1to2,y1to2,x2,y2,CHECK_TRIPPLE_ALIGNMENT,'initial match triple point');
clear tripleInd_1 tripleInd_2;

% Need to reduce matched triple points (some are too close.  If so, choose only one)
% using their position on mapA.  If diff(subX + subY)<=8, i.e., within a 5x5 window, consider as one point dynamically reduce 'tLink'
ii = 0;
targetIndDiff = [[-2,-1,0,1,2], size(ID_1,1)+[-2,-1,0,1,2], 2*size(ID_1,1)+[-2,-1,0,1,2], -size(ID_1,1)+[-2,-1,0,1,2], -2*size(ID_1,1)+[-2,-1,0,1,2]];
while (ii<size(tLink,1))
    ii = ii + 1;
    currentInd = tLink(ii,1);
    indToRemove = [];
    for jj = ii+1 : size(tLink,1)
        if intersect(currentInd - tLink(jj,1), targetIndDiff)
            indToRemove = [indToRemove,jj];
        end
    end
    tLink(indToRemove,:) = [];
end
% do it again using position on mapB
tLink = tLink;
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
% check again, after removing redundant triple points
check_alignment(tLink,boundaryTF1,boundaryTF2,x1to2,y1to2,x2,y2,CHECK_TRIPPLE_ALIGNMENT,'after removing redundant points');
clear targetIndDiff currentInd indToRemove;

% (C) Select control points on grainCenter, triplePoints, edgeOfMap, preparing to to a finer alignment  
% add gC as more alignment points, check
pLink = tLink;
for ii = 1:size(gCLink,1)
    pLink = [pLink; gCLink(ii,1), gCLink(ii,4)];
end
check_alignment(pLink,boundaryTF1,boundaryTF2,x1to2,y1to2,x2,y2,CHECK_TRIPPLE_ALIGNMENT,'add gC as more align points');

% select 16 additional control points along the edge of the smaller image
indC_i = ceil(max(max(x1to2(:,1)),x2(1,1)));
indC_f = floor(min(min(x1to2(:,end)),x2(1,end)));
indR_i = ceil(max(max(y1to2(1,:)),y2(1,1)));
indR_f = floor(min(min(y1to2(end,:)),y2(end,1)));
[subR2,subC2] = meshgrid(indR_i:(indR_f-indR_i)/3.1:indR_f,indC_i:(indC_f-indC_i)/3.1:indC_f);
subR2 = round(subR2(:));
subC2 = round(subC2(:));
ind2 = sub2ind(size(x2),subR2,subC2);
[subC1, subR1] = tforminv(tform, subC2, subR2);
subC1 = round(subC1);
subR1 = round(subR1);
ind1 = sub2ind(size(x1to2),subR1,subC1);

pLink = [pLink;ind1(:),ind2(:)];
check_alignment(pLink,boundaryTF1,boundaryTF2,x1to2,y1to2,x2,y2,CHECK_TRIPPLE_ALIGNMENT,'add edge control points');
clear nR nC subR2 subC2 ind2 subR1 subC1 ind1;
% Note to keep: Possible solution (1): Then these triple points, gb points are control points for SOM-type growth.
% Or, Possible solution (2): use local geometric transformation. based on pLink.

% (D) Do triangulation in the index space
[R1,C1] = ind2sub(size(x1),pLink(:,1));     % matched points, converted from index to sub.  These are points used for triangulation to divide the map
[R2,C2] = ind2sub(size(x2),pLink(:,2));
TRI = delaunay(C1,R1);
check_triangulation(TRI,C1,R1,CHECK_TRIANGULATION,'triangulation on map 1')
check_triangulation(TRI,C2,R2,CHECK_TRIANGULATION,'triangulation on map 2')


% for each triangle, do affine transformation.  Using INDEX !!!!!!!
[cMatA,rMatA] = meshgrid(1:size(x1,2),1:size(x1,1));
indMatA = reshape(1:length(x1(:)),size(x1));
[cMatB,rMatB] = meshgrid(1:size(x2,2),1:size(x2,1));
indMatB = reshape(1:length(x2(:)),size(x2));

indMatch = [];
% match the index in two-directions
for ii = 1:length(TRI)
    cpFrom = [C1(TRI(ii,:),1),R1(TRI(ii,:),1)];     % take the iith triangle to make control points
    cpTo = [C2(TRI(ii,:),1),R2(TRI(ii,:),1)];
    try
        tfm = maketform('affine',cpFrom,cpTo);
    catch
        tfm = [];
    end
    % find [indC,indR] inside triangle cpFrom. Correlate from 'from' to 'to'
    indA = find(isPointInTriangle([cMatA(:),rMatA(:)],cpFrom(1,:),cpFrom(2,:),cpFrom(3,:)));
    [indC_AtoB, indR_AtoB] = tformfwd(tfm, cMatA(indA), rMatA(indA));
    indC_AtoB = round(indC_AtoB);
    indR_AtoB = round(indR_AtoB);
    
    ind = find((indC_AtoB<1)|(indC_AtoB)>size(x2,2)|(indR_AtoB<1)|(indR_AtoB>size(x2,1)));
    indA(ind) = [];
    indC_AtoB(ind) = [];
    indR_AtoB(ind) = [];
    
    indB = sub2ind(size(x2), indR_AtoB, indC_AtoB);
    indMatch = [indMatch; indA,indB];
    
    % find [indC, indR] inside triangle cpTo. Correlate from 'to' to 'from'
    indB = find(isPointInTriangle([cMatB(:),rMatB(:)],cpTo(1,:),cpTo(2,:),cpTo(3,:)));
    [indC_BtoA, indR_BtoA] = tforminv(tfm, cMatB(indB), rMatB(indB));
    indC_BtoA = round(indC_BtoA);
    indR_BtoA = round(indR_BtoA);
    
    ind = find((indC_BtoA<1)|(indC_BtoA)>size(x1,2)|(indR_BtoA<1)|(indR_BtoA>size(x1,1)));
    indB(ind) = [];
    indC_BtoA(ind) = [];
    indR_BtoA(ind) = [];
    
    indA = sub2ind(size(x1), indR_BtoA, indC_BtoA);
    indMatch = [indMatch; indA,indB];    
end
clear cpFrom cpTo tfm ind indA indB;
% then eliminate the redundant indexes. More 'dense' map keep unique values, less 'dense' map can have more elements projected to it.  
if numel(unique(indMatch(:,1))) < numel(unique(indMatch(:,2)))
    disp('map 2 is more dense');
    [~,AI,~] =  unique(indMatch(:,2));
else
    disp('map 1 is more dense');
    [~,AI,~] =  unique(indMatch(:,1));
end
indMatch = indMatch(AI,:);

if CHECK_ALIGNMENT == 1
    ID_AtoB = zeros(size(ID_2))*nan;
    ID_BtoA = zeros(size(ID_1))*nan;
    ID_AtoB(indMatch(:,2)) = ID_1(indMatch(:,1));
    ID_BtoA(indMatch(:,1)) = ID_2(indMatch(:,2));
    myplot(x2,y2,ID_1to2,boundaryTF2);title('rough projection');
    myplot(x2,y2,ID_AtoB,boundaryTF2);title('triangulation projection');
    myplot(x1,y1,ID_2to1,boundaryTF1);title('rough projection');
    myplot(x1,y1,ID_BtoA,boundaryTF1);title('triangulation projection');    
%     myplot(x2,y2,inpaint_nans(ID_1to2),boundaryTF2);title('rough projection, inpaint_nans');
%     myplot(x2,y2,inpaint_nans(ID_AtoB),boundaryTF2);title('triangulation projection, inpaint_nans');
%     myplot(x1,y1,inpaint_nans(ID_2to1),boundaryTF1);title('rough projection, inpaint_nans');
%     myplot(x1,y1,inpaint_nans(ID_BtoA),boundaryTF1);title('triangulation projection, inpaint_nans');
end

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

if (0==CHECK_GRAIN_ALIGNMENT)||(0==CHECK_TRIPPLE_ALIGNMENT)||(0==CHECK_TRIANGULATION)||(0==CHECK_ALIGNMENT)
    save_all_figures([inputname(1),'-',inputname(2)]);
end
close all;
save([inputname(1),'-',inputname(2),'_ws']);


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

function [] = check_alignment(ptLink,boundaryTF1,boundaryTF2,x1,y1,x2,y2,checkTF,str_title)
if checkTF
    maptAtoB = zeros(size(boundaryTF1));
    maptBtoA = zeros(size(boundaryTF2));
    ii = 1;
    while ii<=size(ptLink,1)
        currentPair = ptLink(ii,1:2);
        maptAtoB(currentPair(1)) = ii;
        maptBtoA(currentPair(2)) = ii;
        ii = ii + 1;
    end
    
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
    if exist('str_title','var')
        title(str_title);
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
    if exist('str_title','var')
        title(str_title);
    end
end
end

% check triangluation 'TRI' results, based on position X=C, Y=R
function [] = check_triangulation(TRI,C,R,checkTF,str_title)
if checkTF==1
    figure;triplot(TRI,C,R);set(gca,'ydir','reverse');
    hold on;
    for ii=1:length(C)
        text(C(ii),R(ii),num2str(ii));
    end
    if exist('str_title','var')
        title(str_title);
    end
end
end


%%  here are some codes that can help generate intermediate state data.  Not very organized ...

% [x,y]=meshgrid(0:2:900,0:2:902);
% myplot(x(106:106+315,70:70+315),y(106:106+315,70:70+315),ID_1(106:106+315,70:70+315));  % (1) ID_1 match part
% myplot(ID_1);   % (2) ID_1 whole
% myplot(nan*zeros(size(boundaryTF2)),boundaryTF2);  % (3) GB_2
% 
% surf(x,y,ID_1,'edgecolor','none');
% 
% axis equal;
% a=gca;
% set(a,'Ydir','reverse');
% view(0,90);
% 
% [xx,yy] = meshgrid(140:140+629, 212:212+629);
% hold on;
% % surf(xx,yy,boundaryTF2*1000,'edgecolor','k');
% ind = (boundaryTF2(:)==1);
% plot3(xx(ind),yy(ind),1000*boundaryTF2(ind),'.k','markersize',1);   % (4) Initial overlay
% 
% 
% [xxx,yyy] = tformfwd(tform, x(106:106+315,70:70+315),y(106:106+315,70:70+315));
% myplot(xxx,yyy,ID_1(106:106+315,70:70+315));    % (5) rough_aligned ID_1 partial
% [x4,y4] = tformfwd(tform, x,y);
% myplot(x4,y4,ID_1);                              % (6) rough_aligned ID_1 full
