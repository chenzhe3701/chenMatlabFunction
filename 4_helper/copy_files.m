% method - 0
dir_source = 'D:\Ti7Al#B2 Trace plots\Ti7Al_#B2_traceAnaly_stop_010'
dir_target = 'D:\Ti7Al#B2 Trace plots\Ti7Al_#B2_all_trace_plot_tif';
fileList = dir([dir_source,'/*.tif']);
for ii=1:length(fileList)
    copyfile([dir_source,'/',fileList(ii).name],dir_target);
end

%% method -1
dir_source = uigetdir();
dir_target = uigetdir();
%%
fileList = dir([dir_source,'/*.mat']);

% IDs = [73,89,110,118,122,129,135,148,158,163,176,179,182,191,201,204,210,220,242,243,252,272,276,281,296,298,305,307,311,314,319,323,326,327,332,339,344,345,346,347,348,349,360,364,391,394,401,422,475,479,482,491,496,523,526,534,570,597,603];
IDs = [89,129,135,191,201,210,327,401,422,553];
for ii = 1:length(fileList);
   fileName = fileList(ii).name;
   ID = (fileList(ii).name(13:15));
   if strcmpi(ID(3),'_')
       ID = ID(1:2);
   end
   ID = str2num(ID);
   if ismember(ID,IDs)
       copyfile([dir_source,'/',fileName],dir_target);
   end
end


