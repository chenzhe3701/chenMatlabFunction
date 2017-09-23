%% plot, but first set figure visible off, so not interupt
folder_name = uigetdir();
file_data = dir([folder_name '\*.mat']);
file_data = struct2cell(file_data);
file_data = file_data(1,:).';

figH = figure('visible','off');

for ii = 1:length(file_data)
    file_name = strtok(file_data{ii},'.');
    matfile = [folder_name,'\',file_name,'.mat'];
    load(matfile);
    
    U2=U;
    U2(sigma(:)==-1)=NaN;
    %U2(:,1:100)=NaN;
    surf(X,Y,U2,'EdgeColor','none');
    axis([0,2048,0,2048]);
    axis square; colorbar; xlabel('x,pixel'); ylabel('y,pixel');
    set(gca,'YDir','reverse');view(0,90);
    set(figH,'Name',file_name,'NumberTitle','off')
    view(0,90);
    saveas(gcf,[folder_name,'\U_plot_',file_name,],'tif');
    
    
    
    V2=V;
    V2(sigma(:)==-1)=NaN;
    surf(X,Y,V2,'EdgeColor','none');
    axis([0,2048,0,2048]);
    axis square; colorbar; xlabel('x,pixel'); ylabel('y,pixel');
    set(gca,'YDir','reverse');view(0,90);
    set(figH,'Name',file_name,'NumberTitle','off')
    view(0,90);
    saveas(gcf,[folder_name,'\V_plot_',file_name,],'tif');
    
    
    try
        U2=U_r;
        U2(sigma(:)==-1)=NaN;
        %U2(:,1:100)=NaN;
        surf(X,Y,U2,'EdgeColor','none');
        axis([0,2048,0,2048]);
        axis square; colorbar; xlabel('x,pixel'); ylabel('y,pixel');
        set(gca,'YDir','reverse');view(0,90);
        set(figH,'Name',file_name,'NumberTitle','off')
        view(0,90);
        saveas(gcf,[folder_name,'\Ur_plot_',file_name,],'tif');
        
        
        
        V2=V_r;
        V2(sigma(:)==-1)=NaN;
        surf(X,Y,V2,'EdgeColor','none');
        axis([0,2048,0,2048]);
        axis square; colorbar; xlabel('x,pixel'); ylabel('y,pixel');
        set(gca,'YDir','reverse');view(0,90);
        set(figH,'Name',file_name,'NumberTitle','off')
        view(0,90);
        saveas(gcf,[folder_name,'\Vr_plot_',file_name,],'tif');
    catch
    end
    
    try
        U2=U_s;
        U2(sigma(:)==-1)=NaN;
        %U2(:,1:100)=NaN;
        surf(X,Y,U2,'EdgeColor','none');
        axis([0,2048,0,2048]);
        axis square; colorbar; xlabel('x,pixel'); ylabel('y,pixel');
        set(gca,'YDir','reverse');view(0,90);
        set(figH,'Name',file_name,'NumberTitle','off')
        view(0,90);
        saveas(gcf,[folder_name,'\Us_plot_',file_name,],'tif');
        
        
        
        V2=V_s;
        V2(sigma(:)==-1)=NaN;
        surf(X,Y,V2,'EdgeColor','none');
        axis([0,2048,0,2048]);
        axis square; colorbar; xlabel('x,pixel'); ylabel('y,pixel');
        set(gca,'YDir','reverse');view(0,90);
        set(figH,'Name',file_name,'NumberTitle','off')
        view(0,90);
        saveas(gcf,[folder_name,'\Vs_plot_',file_name,],'tif');
    catch
    end
end


