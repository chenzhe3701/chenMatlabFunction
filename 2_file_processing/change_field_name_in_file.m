% change the field name in a .mat file
%
% chenzhe, 2017-05-31
function change_field_name_in_file(pf, oldName, newName)

d = load(pf);

d.(newName) = d.(oldName);
d = rmfield(d,oldName);

names = fieldnames(d);
    
for ii = 1:length(names)
    eval([names{ii},'=d.',(names{ii}),';']);
end

save(pf,names{1});
for ii = 2:length(names)
    save(pf,names{ii},'-append');
end

end