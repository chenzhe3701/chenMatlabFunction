% chenzhe, 2016-4-4
%
% hf(handle of figure) = label_map_with_ID(X,Y,ID,hf)
% X, Y, ID are matrice of the same size: coordinates and ID_map.
% hf is the handle_of_figure

function hf = label_map_with_ID_and_activeSS(X,Y,ID,hf)

[traceStructFile, traceStructPath] = uigetfile('','select traceStructure');
traceStruct = load([traceStructPath,'\',traceStructFile]);
traceStruct = traceStruct.traceStruct;

set(0,'currentfigure',hf);

hold on;

uniqueID = unique(ID(:));
uniqueID = uniqueID(uniqueID~=0);
ID_reduced = ID(1:20:end,1:20:end);
X_reduced = X(1:20:end,1:20:end);
Y_reduced = Y(1:20:end,1:20:end);

for ii = 1:length(uniqueID)
    
    id = uniqueID(ii);
    ind = (ID_reduced==id);
    x = mean(X_reduced(ind));
    y = mean(Y_reduced(ind));
    text(x,y,50,num2str(id));    % label grain id
    
    indThis = find(cell2mat(arrayfun(@(x) (x.ID==id), traceStruct, 'uniformoutput',false)));    % find this grain in trace structure
    if ~isempty(indThis)
        for iTrace = 1:traceStruct(indThis).nTraces
            x1 = traceStruct(indThis).tracePos{iTrace}(1);
            y1 = traceStruct(indThis).tracePos{iTrace}(3);
            x2 = traceStruct(indThis).tracePos{iTrace}(2);
            y2 = traceStruct(indThis).tracePos{iTrace}(4);
            %             plot3([x1,x2],[y1,y2],[20,20],'linewidth',2,'color','r');
            identifiedSS = find(traceStruct(indThis).ssActivated == iTrace);
            %             text((x1+x2)/2,(y1+y2)/2,100,['Tr',num2str(iTrace),', ss',num2str(identifiedSS)],'color','r');
            if ~isempty(identifiedSS)
                text((x1+x2)/2,(y1+y2)/2,100,['#',num2str(identifiedSS)],'color','r');
                plot3([x1,x2],[y1,y2],[20,20],'linewidth',2,'color','c');
            end
        end
    end
    
end

hold off;

end