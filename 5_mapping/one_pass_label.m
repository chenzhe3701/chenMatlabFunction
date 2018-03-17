% chenzhe, 2018-02-17
% add note: this code can generate a unique 'grain ID' to continues areas
% on a map 'PM' that has a number of continuous regions, and each region
% has a unique value in the 'PM' matrix.

function labels = one_pass_label(PM)
PM = PM';
labeled = zeros(size(PM));
labels = zeros(size(PM));
ind = 1;
currentLabel = 0;
currentPhase = PM(ind);
ind_max = length(PM(:));
[nR,nC] = size(PM);
myQ = [];

while ind <= ind_max
    currentPhase = PM(ind);
    if (labeled(ind)==0)&&(PM(ind)==currentPhase)
        currentLabel = currentLabel + 1;
        labels(ind) = currentLabel;
        labeled(ind) = 1;
        myQ = [myQ, ind];
        while ~isempty(myQ)
            ind_pop = myQ(1);
            myQ(1) = [];
            % check ind_pop's neighbor
            if (rem(ind_pop,nR)>0)&&(labeled(ind_pop+1)==0)&&(PM(ind_pop+1)==currentPhase)
                myQ = [myQ, ind_pop+1];
                labels(ind_pop+1) = currentLabel;
                labeled(ind_pop+1) = 1;
            end
            if (rem(ind_pop,nR)>1)&&(labeled(ind_pop-1)==0)&&(PM(ind_pop-1)==currentPhase)
                myQ = [myQ, ind_pop-1];
                labels(ind_pop-1) = currentLabel;
                labeled(ind_pop-1) = 1;
            end
            if (floor((ind_pop-1)/nR)>0)&&(labeled(ind_pop-nR)==0)&&(PM(ind_pop-nR)==currentPhase)
                myQ = [myQ, ind_pop-nR];
                labels(ind_pop-nR) = currentLabel;
                labeled(ind_pop-nR) = 1;
            end
            if (floor((ind_pop-1)/nR)<nC-1)&&(labeled(ind_pop+nR)==0)&&(PM(ind_pop+nR)==currentPhase)
                myQ = [myQ, ind_pop+nR];
                labels(ind_pop+nR) = currentLabel;
                labeled(ind_pop+nR) = 1;
            end
%             [length(myQ), currentLabel];
        end
    else
        ind = ind + 1;
    end
end

labels = labels';

