% M = [r_numSamps, c_variables].
% k = knn_number.  Local information is based on k-nearest neighbors.
% optional: 'epsilon' = 10^(-4), convergence criterion
% optional: 'plotTF' = true.

function [clusterNumber, membership] = flame_cluster(M, varargin)

p = inputParser;
p.KeepUnmatched = true;
addOptional(p,'k',20,@isnumeric);
addOptional(p,'epsilon',10^(-4),@isnumeric);
addOptional(p,'plotTF',true,@isnumeric);
parse(p, varargin{:});
k = p.Results.k;
epsilon = p.Results.epsilon;
plotTF = p.Results.plotTF;


% FLAME algorithm
close all;
% k= knn number.  Local information is based on k-nearest neighbors.
% e.g., 10^-4, convergence criterion for iterative membership assignment


[ind,dist] = knnsearch(M, M,'K',k+1,'distance','mahalanobis');   % for each data vector/row vector, search (K+1)-nearest neighbor (including itself)
ind = ind(:,2:end);                     % eliminate itself, index of KNNs for each data point, one row for one data point
dist = dist(:,2:end);                   % eliminate itself, distance of KNNs to each data point, one row for one data point

distMat = sparse(repmat([1:size(M,1)]',k,1), ind(:), dist(:), size(M,1), size(M,1));    % distance of the knn to each data point, in a sparse matrix. sparse(ind_of_pts, ind_of_its_knns, dist, size, size)
density = 1./sum(distMat,2);                                                            % local density = 1/sum(distances to knn)
knnDensity = (distMat>0).*repmat(density',size(M,1),1);                                 % each data point's KNN's local density, in a sparse matrix
CSO = (density > max(knnDensity,[],2));                                                 % CSO is a data point whose density is larger than all its knn's density
CSO = find(CSO>0);                                                                      % index of the CSO

minThresh = mean(density)-2*std(density);                                               % additional threshold for local minimum
% outlier1 = (density < min(knnDensity,[],2)) & (density > 0);                     % find outlier, criterion need to be discussed. --> Here might be a bug, because min=0 all the time.
outlier2 = (density < minThresh);
outlier = outlier2;
outlier = find(outlier>0);                                                              % index of outlier

distMat_normRow = distMat./repmat(max(distMat,[],2), 1, size(distMat,2));               % normalize each row of the distance matrix
similarity = (1-distMat_normRow).*spones(distMat);                                      % similarity = 1 - normalized distance
weight = similarity./repmat(sum(similarity,2), 1, size(similarity,2));                  % contribution of KNN to each data point's membership
weight(CSO,:) = 0;
weight = weight + sparse(CSO, CSO, ones(length(CSO),1), size(weight,1), size(weight,2));    % For CSO, the weight of itself is 1, the KNN's contribution are all zero.
weight(outlier,:) = 0;
weight = weight + sparse(outlier, outlier, ones(length(outlier),1), size(weight,1), size(weight,2));    % For outlier? the weight of itself is 1, the KNN's contribution are all zero.

membership = ones(size(M,1), length(CSO)+1) * 1/(length(CSO)+1);                            % initialize membership
membership(CSO,:) = 0;                                                                      % CSO has membership = 1 to its own cluster
membership = membership + sparse(CSO, 1:length(CSO), ones(1,length(CSO)), size(M,1), length(CSO)+1);
membership(outlier,:) = 0;                                                                  % all outliers has membership = 1 to outlier cluster
membership = membership + sparse(outlier, ones(1, length(outlier))*(length(CSO)+1), ones(1,length(outlier)), size(M,1), length(CSO)+1);

% update membership iteratively, until the overall change is small
delta = 2*epsilon;
while delta(end) > epsilon
    newMembership = weight * membership;
    d = abs(newMembership - membership);
    delta = [delta; sum(d(:))];
    membership = newMembership;
end
[~,clusterNumber] = max(membership,[],2);

if (plotTF)
    % plot to show how it works
    hold on;        % plot data in 1st two-dimension and plot identified CSO and outliers
    scatter(M(:,1),M(:,2));
    scatter(M(CSO,1),M(CSO,2),'markerfacecolor','r','markeredgecolor','none');
    scatter(M(outlier,1),M(outlier,2),'markerfacecolor','k','markeredgecolor','none');
    hold off;
    figure;         % plot how delta changed, as a criterion for stopping updating membership
    plot(delta);title('change of delta during each iteration of updating membership');
    figure;     % show data points density
    scatter3(M(:,1),M(:,2),density(:),'markerfacecolor','b','markeredgecolor','none');title('knn density');
    figure;     % show data points membership to 1st cluster, to illustrate results
    scatter3(M(:,1),M(:,2),membership(:,1),'markerfacecolor','r','markeredgecolor','none');title('membership to a (e.g., 1st) cluster')
    % calculate what color to represent each data's membership.  Show at most 6 clusters' contribution.
    colorCell{1} = [1 0 0; 0 0 0; 0 0 0]';  % red
    colorCell{2} = [0 0 0; 0 1 0; 0 0 0]';  % green
    colorCell{3} = [0 0 0; 0 0 0; 0 1 0]';  % blue
    colorCell{4} = [1 0 0; 1 0 0; 0 0 0]';  % yellow
    colorCell{5} = [1 0 0; 0 0 0; 1 0 0]';  % magenta
    colorCell{6} = [0 0 0; 1 0 0; 1 0 0]';  % cyan
    membershipColors = zeros(size(M,1),3);
    for ii = 1:min(6,length(CSO))
        membershipColors = membershipColors + repmat(membership(:,ii),1,3) * colorCell{ii};
    end
    figure; hold on;
    for ii=1:size(M,1)
        plot(M(ii,1), M(ii,2), 'marker','o','markersize',10,'markerfacecolor', membershipColors(ii,:), 'markeredgecolor','none');
    end
    hold off;
end