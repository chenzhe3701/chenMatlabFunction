% Chenzhe, 2016_08_13
% input two maps, and their x, y matrices.  Find the common region.

function [newMap1,newMap2,newX,newY,indR1_m,indR1_M,indC1_m,indC1_M,indR2_m,indR2_M,indC2_m,indC2_M] = find_common_map_area(map1,x1,y1,map2,x2,y2)

x_common = intersect(x1(:),x2(:));
y_common = intersect(y1(:),y2(:));

indR1_m = find(y1(:,1)==min(y_common(:)));
indR1_M = find(y1(:,1)==max(y_common(:)));
indC1_m = find(x1(1,:)==min(x_common(:)));
indC1_M = find(x1(1,:)==max(x_common(:)));

indR2_m = find(y2(:,1)==min(y_common(:)));
indR2_M = find(y2(:,1)==max(y_common(:)));
indC2_m = find(x2(1,:)==min(x_common(:)));
indC2_M = find(x2(1,:)==max(x_common(:)));

newMap1 = map1(indR1_m:indR1_M, indC1_m:indC1_M);
newMap2 = map2(indR2_m:indR2_M, indC2_m:indC2_M);

% check step size
stepSize1 = unique(x1(:)); stepSize1 = stepSize1(2)-stepSize1(1);
stepSize2 = unique(x2(:)); stepSize2 = stepSize2(2)-stepSize2(1);
if stepSize1 < stepSize2
    display('warning: step size 1 in x is smaller !');
    newX = x1(indR1_m:indR1_M, indC1_m:indC1_M);
else
    newX = x2(indR2_m:indR2_M, indC2_m:indC2_M);
    if stepSize1 > stepSize2
        display('warning: step size 2 in x is smaller !');
    end
end
stepSize1 = unique(y1(:)); stepSize1 = stepSize1(2)-stepSize1(1);
stepSize2 = unique(y2(:)); stepSize2 = stepSize2(2)-stepSize2(1);
if stepSize1 < stepSize2
    display('warning: step size 1 in y is smaller !');
    newY = y1(indR1_m:indR1_M, indC1_m:indC1_M);
else
    newY = y2(indR2_m:indR2_M, indC2_m:indC2_M);
    if stepSize1 > stepSize2
        display('warning: step size 2 in y is smaller !');
    end
end