% function ID_new = hungarian_assign_ID_map(ID, ID_template, max_previous_ID)
%
% depending on the overlap area, change the id# in [ID] to that in
% [ID_template], and return it as [ID_new]
%
% chenzhe, 2018-05-15
%
% chenzhe, 2018-05-18, fix bug to check both worker and job having match. 
% chenzhe, 2018-06-14, modify to make it faster, using accumarray
% chenzhe, 2018-06-27, add output, ID_new_unbalance can try to assign as
% many as possible. (ID_new is one-to-one match).
% So, if clean EBSD, ID_new_unbalance can be used to assign euler angle.
% And ID_new can be used to assign ID.
% 
% chenzhe, 2018-07-28, add additional input 'max_previous_ID'.
% If do not give previous maximum ID, assume it is the max of input ID map.
% The reason is, DIC area might be smaller than EBSD area, so ID_target may
% actually have less grains than actually scanned during EBSD.
%
% chenzhe, 2020-11-06 note:
% (1) This code uses hungarian_assign, but it is actually slight different
% from that situation. For example, if we want to match ID [1,1,2,3,3] with
% [10,10,10,12,13], Hugarian solution will give new ID = [10,10,12,13,13],
% i.e., let worker 2 to job 12, to better satisfy one-to-one match
% priority. However, there is zero match between '2', and '12'. On the
% other hand, if we don't obey the one-to-one priority algorithm, there
% might be more bugs in the realization of the code. 
% So, if there are 0-overlaps, we rcord them separately, and assign the id
% with '0' values.
% (2) If  ID_input has nans, they will be numbered as 0 first.
% (3) ID_target/template should not have NaN values, otherwise if nan
% values are majorities, the matches IDs might be zeros (converted from
% nans)


function [ID_new, id_link_additional, id_link_zero_overlap, id_link] = hungarian_assign_ID_map(ID_temp_input, ID_target, max_previous_ID)

% should ignore ID = 0. First if there are nans, convert to 0
% That's the reason in the code later, there are 'if worker(ii)>0' and 'if job(ii)~=0' 
if sum(isnan(ID_temp_input(:)))>0
    warning('input ID has NaN values, will be converted to 0');
end
if sum(isnan(ID_target(:)))>0
    warning('target ID has NaN values, will be converted to 0, but should go back and check');
end
ID_temp_input(isnan(ID_temp_input)) = 0;
ID_target(isnan(ID_target)) = 0;

[uniqueID_temp_input,~,m1]=unique(ID_temp_input);
[uniqueID_target,~,m2]=unique(ID_target);

overlap = accumarray([m1,m2],1);

if ~exist('max_previous_ID','var')
    max_previous_ID = max(uniqueID_target);
end

% % This is easy to understand, but very slow.
% % It is even slower if do not find all the pairs first.
% 
% uniqueID_temp_input = unique(ID_temp_input(:));
% uniqueID_target = unique(ID_target(:));
% 
% pair = unique([ID_temp_input(:),ID_target(:)],'rows');
% pair(isnan(sum(pair,2)),:) = [];
% 
% overlap = zeros(length(uniqueID_temp_input),length(uniqueID_target));
% 
% for ii = 1:length(uniqueID_temp_input)
%    for jj = 1:length(uniqueID_target)
%        if ismember([uniqueID_temp_input(ii),uniqueID_target(jj)],pair,'rows')
%         overlap(ii,jj) = sum( (ID_temp_input(:)==uniqueID_temp_input(ii))&(ID_target(:)==uniqueID_target(jj)));
%        end
%    end
% end

[worker, job, worker_full, job_full] = hungarian_assign(max(overlap(:))-overlap);
% save('worker_job.mat','worker', 'job', 'worker_full', 'job_full');

% Find out the unbalanced, additional match. i.e., after one-to-one match,
% assign as many matches as possible
ind_additional_match = ~ismember(worker_full,worker);
worker_a = worker_full(ind_additional_match);
job_a = job_full(ind_additional_match);


% worker = 1:size(overlap,1);
% job = munkres(max(overlap(:))-overlap);

% (1) one-to-one match
id_link_zero_overlap = [];  % record the links with zero overlap
id_link = [];   % map from inputID to targetID
ID_new = ID_temp_input;
for ii = 1:length(worker)
    % if this one has a match
    if worker(ii)>0
        id_in_temp = uniqueID_temp_input(worker(ii));
        % if there is a match, reassign
        if job(ii)~=0
            id_in_target = uniqueID_target(job(ii));
            if overlap(worker(ii),job(ii))>0
                ID_new(ID_temp_input==id_in_temp) = id_in_target;
                id_link = [id_link; id_in_temp, id_in_target];
            else
                ID_new(ID_temp_input==id_in_temp) = 0;
                id_link_zero_overlap = [id_link_zero_overlap; id_in_temp, id_in_target];
            end
        end
    end
end


% (2) after one-to-one match, assign additional matches
id_additional = max_previous_ID + 1;
id_link_additional = [];

for ii = 1:length(worker_a)
    % if this one has a match
    if worker_a(ii)>0
        id_in_temp = uniqueID_temp_input(worker_a(ii));
        % if there is a match, reassign
        if job_a(ii)~=0
            id_in_target = uniqueID_target(job_a(ii));
            % Make additional assignment, and record the linkage for additional assignment
            ID_new(ID_temp_input==id_in_temp) = id_additional;
            id_link_additional = [id_link_additional; id_additional, id_in_target];
            % after using, increment id_additional for the next assignment
            id_additional = id_additional + 1;
            
            % method-2, directly find the max in overlap matrix. This just confirms that it is the result we want. 
            % [val,ind] = max(overlap(worker_a(ii),:));
            % disp([ind,job_a(ii),ind-job_a(ii),val]);
        end
    end
end


% % (3) all matched. This is old code.
% ID_new_unbalance = ID_temp_input;
% for ii = 1:length(worker_full)
%     % if this one has a match
%     if worker_full(ii)>0
%         id_in_temp = uniqueID_temp_input(worker_full(ii));
%         % if there is a match, reassign
%         if job_full(ii)~=0
%             id_in_target = uniqueID_target(job_full(ii));
%             ID_new_unbalance(ID_temp_input==id_in_temp) = id_in_target;
%         end
%     end
% end

    
disp('');
