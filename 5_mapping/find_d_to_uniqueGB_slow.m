% Zhe Chen, 2016-3-29
% This is so slow!!!
%
% A simple version to find distance_to_gb from ID matrix

function [dToBoundary, myUniqueGBID] = find_d_to_uniqueGB_slow(x,y,ID)

uniqueGB = construct_unique_boundary_ID(ID);
[nRow,nColumn]=size(ID);
dToBoundary = ones(nRow,nColumn)*inf;

boundaryTF = double(logical(uniqueGB));
dToBoundary(boundaryTF==1)=0;
boundaryX = x.*boundaryTF;
boundaryY = y.*boundaryTF;

f1 = [0 0 0; 1 0 0; 0 0 0];     % filters, each corresponds to one adjacent point
f2 = [0 1 0; 0 0 0; 0 0 0];     
f3 = [0 0 0; 0 0 1; 0 0 0];
f4 = [0 0 0; 0 0 0; 0 1 0];

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

% full neighborID
% convert position to index.  Then convert sub_index to linear_index.  
step_column = x(1,2)-x(1,1);
step_row = y(2,1)-y(1,1);
boundary_column = (boundaryX-x(1))./step_column+1;
boundary_row = (boundaryY-y(1))./step_row+1;
boundary_linear = sub2ind(size(ID),boundary_row,boundary_column);

myUniqueGBID = uniqueGB(boundary_linear);     % the current pixel's nearest gb-point's uniqueGBid
gbID_prefix = floor(myUniqueGBID/1000);
notConsist = (gbID_prefix ~= ID)&(gbID_prefix>0);

gbID_reverse = gbID_prefix + 1000 * rem(myUniqueGBID,1000);
myUniqueGBID(notConsist) = gbID_reverse(notConsist);

display('Found distances to boundary, center, triple points, and their ratios-over-grain diameter');
display(datestr(now));
end

