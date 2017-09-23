% matlabpool('open','2');

directory = uigetdir('','Calibration Drift Directory');

VIC2Dcsvs = dir([directory,'\*.mat']);
VIC2Dcsvs = struct2cell(VIC2Dcsvs);
VIC2Dcsvs = VIC2Dcsvs(1,:)';

m = size(VIC2Dcsvs,1);
for ii = 1:m
    calculate_strain([directory,'\',strtok(VIC2Dcsvs{ii},'.'),'.mat'], 2, 2);
    display(ii);
end

%matlabpool('close');
