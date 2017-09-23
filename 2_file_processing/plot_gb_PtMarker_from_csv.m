% function [] = plot_gb_from_csv(mx2_matrix)
% input is the coord of the pt-markers
% then select csv EBSD file
% output are two gb maps
%
% Zhe Chen, 2015-09-07

function [] = plot_gb_PtMarker_from_csv(varargin)
if isempty(varargin)
    marker=[];
else
    marker=varargin{1};
end
[EBSDfileName, EBSDfilePath] = uigetfile('.csv','choose the EBSD file (csv format)');
EBSDdata = csvread([EBSDfilePath, EBSDfileName],1,0);
columnIndex =  find_variable_column_from_CSV_grain_file(EBSDfilePath, EBSDfileName, {'grain-ID','x-um','y-um'});
x = EBSDdata(:,columnIndex(2));
y = EBSDdata(:,columnIndex(3));
ebsdStepSize = max(x(2)-x(1), y(2)-y(1));
mResize = (max(x(:)) - min(x(:)))/ebsdStepSize + 1;
nResize = (max(y(:)) - min(y(:)))/ebsdStepSize + 1;

x = reshape(EBSDdata(:,columnIndex(2)),mResize,nResize)';
y = reshape(EBSDdata(:,columnIndex(3)),mResize,nResize)';
ID = reshape(EBSDdata(:,columnIndex(1)),mResize,nResize)';
boundaryTF = find_boundary_from_ID_matrix(ID);
boundaryTF(boundaryTF==0)=NaN;
fH1 = figure;
set(fH1,'position',[50,50,size(ID,2),size(ID,1)]);
aH = gca;
surf(aH,boundaryTF);
set(aH,'position',[0,0,1,1],'ydir','reverse','xtick',[],'ytick',[],'xgrid','off','ygrid','off','xlim',[1,size(ID,2)],'ylim',[1,size(ID,1)]);axis equal;
view(0,90);

fH2 = figure;
set(fH2,'position',[50,50,size(ID,2),size(ID,1)]);
aH = gca;
surf(aH,boundaryTF);
if ~isempty(marker)
    hold on;
    plot(marker(:,1),marker(:,2),'o');
    hold off;
end
set(aH,'position',[0,0,1,1],'ydir','reverse','xtick',[],'ytick',[],'xgrid','off','ygrid','off','xlim',[1,size(ID,2)],'ylim',[1,size(ID,1)]);axis equal;
view(0,90);

end

function columnIndex = find_variable_column_from_CSV_grain_file(EBSDfilePath, EBSDfileName, varList)

nVariable = size(varList,2);

fid = fopen([EBSDfilePath, EBSDfileName],'r');
c=textscan(fid,'%s',30,'delimiter',',');
columnNames=c{1,1};
fclose(fid);
columnIndex = zeros(nVariable,1);

for iVariable=1:nVariable
    columnIndex(iVariable) = find(strcmpi(columnNames,varList{iVariable}));
end

end

% Zhe Chen, 2015-08-07 revised.
function boundaryTF = find_boundary_from_ID_matrix(ID)

boundaryTF = zeros(size(ID,1),size(ID,2));      % if pixel is on grain boundary, then this value will be 1

a = repmat(ID,1,1,9);           % shift ID matrix to find G.B/T.P
a(:,1:end-1,2) = a(:,2:end,2);  % shift left
a(:,2:end,3) = a(:,1:end-1,3);  % shift right
a(1:end-1,:,4) = a(2:end,:,4);  % shift up
a(2:end,:,5) = a(1:end-1,:,5);  % shift down
a(1:end-1,1:end-1,6) = a(2:end,2:end,6);    % shift up-left
a(2:end,2:end,7) = a(1:end-1,1:end-1,7);    % shift down-right
a(1:end-1,2:end,8) = a(2:end,1:end-1,8);    % shift up-right
a(2:end,1:end-1,9) = a(1:end-1,2:end,9);    % shift down-left

for ii=2:9
    shiftedA = a(:,:,ii);
    
    thisBoundaryTF = (ID~=shiftedA)&(~isnan(ID))&(~isnan(shiftedA));    % it is a boundary based on info from this layer.  Have to be a number to be considered as g.b.
    boundaryTF = boundaryTF | thisBoundaryTF;   % update boundaryTF using OR relationship
 
end

boundaryTF = double(boundaryTF);

end