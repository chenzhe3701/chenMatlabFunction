% remove some fields from a .mat file
% chenzhe, 2017-05-31
%
% rm_field_from_file(pf, varargin), where varargin are the names of theJ
% fields to remove.
% chenzhe, note added 2018-05-14

function rm_field_from_file(pf, varargin)

d = load(pf);
if ~isempty(varargin)
    for ii = 1:length(varargin)
        d = rmfield(d,varargin{ii});
    end
    
end

names = fieldnames(d);
if ~isempty(names)
    
    for ii = 1:length(names)
       eval([names{ii},'=d.',(names{ii}),';']); 
    end
    
    save(pf,names{1});
    for ii = 2:length(names)
        save(pf,names{ii},'-append');
    end
end
end