function [] = save_all_figures(prefix)
    if ~exist('prefix','var')
        prefix = 'd:\'
    end
    h = findobj('Type','figure')
    for ii = 1:length(h)
        saveas(h(ii),['fig_',prefix,'_',num2str(ii),'.tif']);
    end
end