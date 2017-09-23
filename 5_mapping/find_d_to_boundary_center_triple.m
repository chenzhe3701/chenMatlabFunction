% [dToBoundary,dToCenter,dToTriple, rToBoundary,rToCenter,rToTriple, fullNeighborID]...
%     = find_d_to_boundary_center_triple(x,y,ID,boundaryID,tripleID,neighborID,gID,gCenterX,gCenterY,gDiameter)
% 
% The neighborID is 'sparse', because it is generated by find_boundary_from_ID_matrix
% 
% The fullNeighborID is 'full' and it contains ID of the closest neighbor grain, for each pixel

% Note that ID may contain nan's.  May have to modify code later to take care of this.
% Zhe Chen, revised 2015-08-07

function [dToBoundary,dToCenter,dToTriple, rToBoundary,rToCenter,rToTriple, neighborID]...
     = find_d_to_boundary_center_triple(x,y,ID,boundaryID,tripleID,neighborIDonGB,gID,gCenterX,gCenterY,gDiameter)

[nRow,nColumn]=size(boundaryID);
dToBoundary = ones(nRow,nColumn)*inf;
dToCenter = zeros(nRow,nColumn)*nan;
dToTriple = ones(nRow,nColumn)*inf;
rToBoundary = ones(nRow,nColumn)*nan;
rToCenter = ones(nRow,nColumn)*nan;
rToTriple = ones(nRow,nColumn)*nan;

boundaryTF = double(logical(boundaryID));
dToBoundary(boundaryTF==1)=0;
boundaryX = x.*boundaryTF;
boundaryY = y.*boundaryTF;

tripleTF = logical(tripleID);
dToTriple(tripleTF)=0;
tripleX = x.*tripleTF;
tripleY = y.*tripleTF;

f1 = [0 0 0; 1 0 0; 0 0 0];     % filters, each corresponds to one adjacent point
f2 = [0 1 0; 0 0 0; 0 0 0];     
f3 = [0 0 0; 0 0 1; 0 0 0];
f4 = [0 0 0; 0 0 0; 0 1 0];
ff = [0 1 0; 1 0 1; 0 1 0];
diff = 1;
% distance to grain boundary
iLoop = 1;
while (iLoop<50)||(diff>10^(-2))
    boundaryXtoAdd = zeros(size(dToBoundary));  % temporarily store info
    boundaryYtoAdd = zeros(size(dToBoundary));
    tempDtoBoundary = dToBoundary;
    
    sampleInd = randperm(4);    % randomly change sequence of the four filters in f
    f = zeros([size(f1),4]);
    f(:,:,sampleInd(1))=f1;f(:,:,sampleInd(2))=f2;f(:,:,sampleInd(3))=f3;f(:,:,sampleInd(4))=f4;
    
    for ii=1:4
        convX = conv2(boundaryX,f(:,:,ii),'same');      % check neighbor's nearest g.b points
        convY = conv2(boundaryY,f(:,:,ii),'same');
        xDiff = abs(x-convX);
        yDiff = abs(y-convY);
        manhDistB = xDiff + yDiff;
        eucDistB = sqrt(xDiff.^2 + yDiff.^2);
        % label all points, if new boundaryX,Y assigned, then dToBoundary decrease
        tB = (eucDistB<tempDtoBoundary)&(convX~=0)&(convY~=0);   % if a new boundaryX/Y is convolvable, and result dist < old distance
        % update
        boundaryXtoAdd(tB) = convX(tB);
        boundaryYtoAdd(tB) = convY(tB);
        tempDtoBoundary(tB) = eucDistB(tB);
    end
    
    boundaryX(logical(boundaryXtoAdd)) = boundaryXtoAdd(logical(boundaryXtoAdd));
    boundaryY(logical(boundaryYtoAdd)) = boundaryYtoAdd(logical(boundaryYtoAdd));
    dToAdd = sqrt((x-boundaryXtoAdd).^2 + (y-boundaryYtoAdd).^2);
    old_d_to_boundary = dToBoundary;
    
    dToBoundary(logical(boundaryXtoAdd)) = dToAdd(logical(boundaryXtoAdd));
    
    diff = abs(old_d_to_boundary - dToBoundary);
    diff = nansum(diff(:));
    iLoop = iLoop+1;
end
disp(['grown dist from g.b for   ',num2str(iLoop),'   loops']);
disp(['last iteration dToBoundary change =   ',num2str(diff)]);

% distance to triple point
iLoop=1;
while (iLoop<50)||(diff>10^(-2))
    tripleXtoAdd = zeros(size(dToTriple));  % temporarily store info
    tripleYtoAdd = zeros(size(dToTriple));
    tempDtoTriple = dToTriple;
    
    sampleInd = randperm(4);    % randomly change sequence of the four filters in f
    f = zeros([size(f1),4]);
    f(:,:,sampleInd(1))=f1;f(:,:,sampleInd(2))=f2;f(:,:,sampleInd(3))=f3;f(:,:,sampleInd(4))=f4;
    
    for ii=1:4
        convX = conv2(tripleX,f(:,:,ii),'same');      % check neighbor's nearest g.b points
        convY = conv2(tripleY,f(:,:,ii),'same');
        xDiff = abs(x-convX);
        yDiff = abs(y-convY);
        manhDistT = xDiff + yDiff;
        eucDistT = sqrt(xDiff.^2 + yDiff.^2);
        % label all points, if new boundaryX,Y assigned, then dToBoundary decrease
        tT = (eucDistT<tempDtoTriple)&(convX~=0)&(convY~=0);   % if a new boundaryX/Y is convolvable, and result dist < old distance
        % update
        tripleXtoAdd(tT) = convX(tT);
        tripleYtoAdd(tT) = convY(tT);
        tempDtoTriple(tT) = eucDistT(tT);
    end
    
    tripleX(logical(tripleXtoAdd)) = tripleXtoAdd(logical(tripleXtoAdd));
    tripleY(logical(tripleYtoAdd)) = tripleYtoAdd(logical(tripleYtoAdd));
    dTripleToAdd = sqrt((x-tripleXtoAdd).^2 + (y-tripleYtoAdd).^2);
    old_d_to_triple = dToTriple;
    
    dToTriple(logical(tripleXtoAdd)) = dTripleToAdd(logical(tripleXtoAdd));
    
    diff = abs(old_d_to_triple - dToTriple);
    diff = nansum(diff(:));
    iLoop = iLoop+1;
end
disp(['grown dist from triple point for   ',num2str(iLoop),'   loops']);
disp(['last iteration dToTriple change =   ',num2str(diff)]);

% distance to grain center
centerX = assign_field_to_cell(ID,gID,gCenterX);
centerY = assign_field_to_cell(ID,gID,gCenterY);
dToCenter = sqrt((x-centerX).^2+(y-centerY).^2);

% ratio of dToXXX over grain diameter
diameter = assign_field_to_cell(ID,gID,gDiameter);
rToBoundary = dToBoundary./diameter;
rToTriple = dToTriple./diameter;
rToCenter = dToCenter./diameter;

% full neighborID
% convert position to index.  Then convert sub_index to linear_index.  
step_column = x(1,2)-x(1,1);
step_row = y(2,1)-y(1,1);
boundary_column = (boundaryX-x(1))./step_column+1;
boundary_row = (boundaryY-y(1))./step_row+1;
boundary_linear = sub2ind(size(ID),boundary_row,boundary_column);

fullNeighborID_1 = neighborIDonGB(boundary_linear);     % if point to the g.b of its grain, then this g.b point should store this g.b. point's neighborID
fullNeighborID_2 = ID(boundary_linear);             % if it points directly to the g.b at adjacent grain

notConsist = (fullNeighborID_1 == ID);
neighborID = fullNeighborID_1;
neighborID(notConsist) = fullNeighborID_2(notConsist);

display('Found distances to boundary, center, triple points, and their ratios-over-grain diameter');
display(datestr(now));
end

