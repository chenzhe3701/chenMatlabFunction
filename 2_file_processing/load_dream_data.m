% varargout = load_dream_data(pf, datasetName, attributeMatrixType,zDim)
% varargout = [component_1(:,:,zDims), component_2(:,:,zDims), ... ]
%
% each component has each output variable (e.g., euler angle has 3 components) 
% all heights (zDim) are in one (e.g., zDim could be 3 or 3:5, ...)
%
% chenzhe 2017-06-01

function varargout = load_dream_data(pf, datasetName, attributeMatrixType, zDim)

% regulate expression, into a number
attributeMatrixType = regulateName(attributeMatrixType);

info = h5info(pf);
[nameToLoad, tDim, cDim] = match_group_info(info, datasetName, attributeMatrixType, [],[],[]);

disp(['Data component dimension: ',num2str(cDim)]);
disp(['Data tuple dimension: ',num2str(tDim)]);

dt = h5read(pf,nameToLoad); % matlab imported data is : [component, x, y, z] -dimension

for ii = 1:cDim
    t = dt(ii,:,:,:);
    t = squeeze(t);
    t = permute(t,[2,1,3]); % make sequence = [y,x,z], i.e. [row, column, page]
    if exist('zDim','var')
        t = t(:,:,zDim);    % take only height = z
    end
    varargout{ii} = double(t);
end

end


function [nameToLoad,tDimToLoad,cDimToLoad] = match_group_info(info, datasetName, attributeMatrixType, nameToLoad, tDimToLoad, cDimToLoad)
% if has not found
if (isempty(nameToLoad))&&(isempty(tDimToLoad))
    for ii = 1:length(info.Groups) % recursively loop through groups
        [nameToLoad,tDimToLoad,cDimToLoad] = match_group_info(info.Groups(ii),datasetName, attributeMatrixType, nameToLoad, tDimToLoad, cDimToLoad);
    end
    % If no subgroups, then it only contains datasets/(or nothing)
    % get the attributes
    if ~isempty(info.Datasets)  % loop through all datasets
        currentAttributeMatrixType = -9999;
        for ii = 1:length(info.Attributes)
            switch info.Attributes(ii).Name
                case {'AttributeMatrixType'}
                    currentAttributeMatrixType = info.Attributes(ii).Value;
            end
        end
        
        % check if this is the attributes you want
        if currentAttributeMatrixType == attributeMatrixType
            groupName = info.Name;
            for ii = 1:length(info.Datasets)
                if strcmpi(info.Datasets(ii).Name,datasetName)
                    % this is the data you want:
                    nameToLoad = [groupName,'/',info.Datasets(ii).Name];
                    for jj = 1:length(info.Datasets(ii).Attributes)
                        % this is the dimension: currentTupleDimension
                        switch info.Datasets(ii).Attributes(jj).Name
                            case {'TupleDimensions'}
                                tDimToLoad = double( reshape(info.Datasets(ii).Attributes(jj).Value,1,[]) );
                            case {'ComponentDimensions'}
                                cDimToLoad = double( info.Datasets(ii).Attributes(jj).Value );
                        end
                    end
                    break;
                end
            end
        end
    end
end
end

function attributeMatrixType = regulateName(attributeMatrixType)
switch attributeMatrixType
    case {'Vertex','vertex','VertexData','vertexdata','vertexData',0}
        attributeMatrixType = 0;
    case {'Edge','edge','EdgeData','edgedata','edgeData',1}
        attributeMatrixType = 1;
    case {'Face','face','FaceData','facedata','faceData',2}
        attributeMatrixType = 2;
    case {'Cell','cell','CellData','celldata','cellData',3}
        attributeMatrixType = 3;
    case {'VertexFeature','vertexFeature','vertexfeature',4}
        attributeMatrixType = 4;
    case {'EdgeFeature','edgeFeature','edgefeature','EdgeFeatureData','edgeFeatureData','edgefeaturedata',5}
        attributeMatrixType = 5;
    case {'FaceFeature','faceFeature','facefeature','FaceFeatureData','faceFeatureData','facefeaturedata',6}
        attributeMatrixType = 6;
    case {'CellFeature','cellFeature','cellfeature','CellFeatureData','cellFeatureData','cellfeaturedata',7}
        attributeMatrixType = 7;
    case {'VertexEnsemble','vertexEnsemble','vertexensemble','VertexEnsembleData','vertexEnsembleData','vertexensembledata',8}
        attributeMatrixType = 8;
    case {'EdgeEnsemble','edgeEnsemble','edgeensemble','EdgeEnsembleData','edgeEnsembleData','edgeensembledata',9}
        attributeMatrixType = 9;
    case {'FaceEnsemble','faceEnsemble','faceensemble','FaceEnsembleData','faceEnsembleData','faceensembledata',10}
        attributeMatrixType = 10;
    case {'CellEnsemble','cellEnsemble','cellensemble','CellEnsembleData','cellEnsembleData','cellensembledata',11}
        attributeMatrixType = 11;
    case {'MetaData','metaData','metadata',12}
        attributeMatrixType = 12;
    case {'Generic','generic',13}
        attributeMatrixType = 13;
    case {'Unknown','unknown',999}
        attributeMatrixType = 999;
end
end
