% [gSFBa3D,gSFPr3D,gSFPy3D,gSFPyCA3D,gSFTT3D,gSFBaNum3D,gSFPrNum3D,gSFPyNum3D,gSFPyCANum3D,gSFTTNum3D]...
%    = find_unique_SF_for_grains(gID,gID3D,gSFBa,gSFPr,gSFPy,gSFPyCA,gSFTT,gSFBaNum,gSFPrNum,gSFPyNum,gSFPyCANum,gSFTTNum)
%
% Provide SchmidFactor and slipSystemNum info.  These are for all layers
% The result are for grains in 3D, and the values are taken as average form all layers.  The slipSystemNumber is the most frequent one.

% Zhe Chen, 2015-08-10 revised.

function [gSFBa3D,gSFPr3D,gSFPy3D,gSFPyCA3D,gSFTT3D,gSFBaNum3D,gSFPrNum3D,gSFPyNum3D,gSFPyCANum3D,gSFTTNum3D]...
    = find_unique_SF_for_grains(gID,gID3D,gSFBa,gSFPr,gSFPy,gSFPyCA,gSFTT,gSFBaNum,gSFPrNum,gSFPyNum,gSFPyCANum,gSFTTNum)
nEBSDfiles = length(gSFBa);
gSFBa3D = zeros(length(gID3D),nEBSDfiles)*nan;  
gSFPr3D = zeros(length(gID3D),nEBSDfiles)*nan; 
gSFPy3D = zeros(length(gID3D),nEBSDfiles)*nan;
gSFPyCA3D = zeros(length(gID3D),nEBSDfiles)*nan;
gSFTT3D = zeros(length(gID3D),nEBSDfiles)*nan;
gSFBaNum3D = zeros(length(gID3D),nEBSDfiles)*nan;  
gSFPrNum3D = zeros(length(gID3D),nEBSDfiles)*nan; 
gSFPyNum3D = zeros(length(gID3D),nEBSDfiles)*nan;
gSFPyCANum3D = zeros(length(gID3D),nEBSDfiles)*nan;
gSFTTNum3D = zeros(length(gID3D),nEBSDfiles)*nan;
for iEBSDfiles = 1:nEBSDfiles
    for iGrain = 1:length(gID3D)
        rowIndex = gID{iEBSDfiles}==gID3D(iGrain);
        if sum(rowIndex)    % if this grain exist in this layer
            gSFBa3D(iGrain,iEBSDfiles) = gSFBa{iEBSDfiles}(rowIndex);   % record all the grain SF's in all layers to this grain
            gSFPr3D(iGrain,iEBSDfiles) = gSFPr{iEBSDfiles}(rowIndex);
            gSFPy3D(iGrain,iEBSDfiles) = gSFPy{iEBSDfiles}(rowIndex);
            gSFPyCA3D(iGrain,iEBSDfiles) = gSFPyCA{iEBSDfiles}(rowIndex);
            gSFTT3D(iGrain,iEBSDfiles) = gSFTT{iEBSDfiles}(rowIndex);
            gSFBaNum3D(iGrain,iEBSDfiles) = gSFBaNum{iEBSDfiles}(rowIndex);   % record all the grain SF's in all layers to this grain
            gSFPrNum3D(iGrain,iEBSDfiles) = gSFPrNum{iEBSDfiles}(rowIndex);
            gSFPyNum3D(iGrain,iEBSDfiles) = gSFPyNum{iEBSDfiles}(rowIndex);
            gSFPyCANum3D(iGrain,iEBSDfiles) = gSFPyCANum{iEBSDfiles}(rowIndex);
            gSFTTNum3D(iGrain,iEBSDfiles) = gSFTTNum{iEBSDfiles}(rowIndex);
        end
    end
end
gSFBa3D = nanmean(gSFBa3D,2);   % take the average SF from all layers
gSFPr3D = nanmean(gSFPr3D,2);
gSFPy3D = nanmean(gSFPy3D,2);
gSFPyCA3D = nanmean(gSFPyCA3D,2);
gSFTT3D = nanmean(gSFTT3D,2);
gSFBaNum3D = mode(gSFBaNum3D,2);   % take the most frequently observed
gSFPrNum3D = mode(gSFPrNum3D,2);
gSFPyNum3D = mode(gSFPyNum3D,2);
gSFPyCANum3D = mode(gSFPyCANum3D,2);
gSFTTNum3D = mode(gSFTTNum3D,2);