% los = calculate_los(q0,q1,q2,q3,interactionRadiusInPixel,maxAngle)
%
% local orientation related property.  Only need 2D info from undeformed scan.
% interactionRadius in pixel size unit

% Zhe Chen, 2015-08-28 revised.

function los = calculate_los(q0,q1,q2,q3,interactionRadiusInPixel,maxAngle)

% interactionRadius = 2;
% maxAngle = 5;

% first, fill shape of filter
% interactionRadiusIndex = max(floor(interactionRadius/ebsdStepSize),1);  % convert radius to # of index spanned, this value has to > 0
interactionRadiusIndex = max(interactionRadiusInPixel,1); 
convFilter = zeros(1+2*interactionRadiusIndex);  % initialize convFilter for this layer. size = top layer size, but will add 1's later
[cc,rr] = meshgrid(1:1+2*interactionRadiusIndex,1:1+2*interactionRadiusIndex);
inCircleTR = sqrt((rr-1-interactionRadiusIndex).^2+(cc-1-interactionRadiusIndex).^2) <= interactionRadiusIndex;   % index circular region within interactionRadius in this layer
convFilter(inCircleTR) = 1;     % assign 1's to elements in convFilter{thisLayer}, the elements are within Radius

% second, find avg. orientation in Quaternion, based on filter.  The way to
% do it looks simple -- just convolve to take sum of q's. then mod, divide.
[nRow, nColumn] = size(q0);
oneMap = ones(nRow,nColumn);
q0Conv = conv2(q0,convFilter,'same');   % add up all the 1st element of Quaternions within the filter, vectorized calculation
q1Conv = conv2(q1,convFilter,'same');
q2Conv = conv2(q2,convFilter,'same');
q3Conv = conv2(q3,convFilter,'same');

qConvNorm = reshape(quatmod([q0Conv(:),q1Conv(:),q2Conv(:),q3Conv(:)]),nRow,nColumn);   % Norm of all Quaternions within the filter, vectorized calculation
q0Ref = q0Conv./qConvNorm;
q1Ref = q1Conv./qConvNorm;
q2Ref = q2Conv./qConvNorm;
q3Ref = q3Conv./qConvNorm;

zeroFilter = convFilter*0;
indexOnes = find(convFilter==1);

LOS = zeros(size(q0Ref,1),size(q0Ref,2),length(indexOnes));
for ii = 1:length(indexOnes)                % find the Quaternion in kernel, one by one
    oneFilter = zeroFilter;
    oneFilter(indexOnes(ii)) = 1;
    q0_p = imfilter(q0,oneFilter,'symmetric','same');          % find the q0 of this Quaternion      
    q1_p = imfilter(q1,oneFilter,'symmetric','same');
    q2_p = imfilter(q2,oneFilter,'symmetric','same');
    q3_p = imfilter(q3,oneFilter,'symmetric','same');
        
    tempLOS = reshape(calculate_misorientation_quaternion_hcp_rough([q0Ref(:),q1Ref(:),q2Ref(:),q3Ref(:)], [q0_p(:),q1_p(:),q2_p(:),q3_p(:)]), size(q0Ref));
    tempLOS(tempLOS>maxAngle) = NaN;
    LOS(:,:,ii) = tempLOS;
    disp(['calculated ',num2str(ii),'  maps of misorientation paris']);
end

los = nanmean(LOS,3);
los(isnan(los)) = maxAngle;

display('calculated local orientation spread');
display(datestr(now));

