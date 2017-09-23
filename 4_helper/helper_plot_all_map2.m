folder = 'c:\users\chenzhe\desktop\Figures_Ti7Al#B6\';

[f,a,c] = myplot(x{1},boundaryTF{1});set(f,'Visible','off');title(a,'x','fontsize',18);title(c,'um','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(y{1},boundaryTF{1});set(f,'Visible','off');title(a,'y','fontsize',18);title(c,'um','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(phi1{1},boundaryTF{1});set(f,'Visible','off');title(a,'phi1','fontsize',18);title(c,'degree','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(phi{1},boundaryTF{1});set(f,'Visible','off');title(a,'phi','fontsize',18);title(c,'degree','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(phi2{1},boundaryTF{1});set(f,'Visible','off');title(a,'phi2','fontsize',18);title(c,'degree','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(phi1New,boundaryTF{1});set(f,'Visible','off');title(a,'phi1New','fontsize',18);title(c,'degree','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(phiNew,boundaryTF{1});set(f,'Visible','off');title(a,'phiNew','fontsize',18);title(c,'degree','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(phi2New,boundaryTF{1});set(f,'Visible','off');title(a,'phi2New','fontsize',18);title(c,'degree','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);

[f,a,c] = myplot(ID{1},boundaryTF{1});set(f,'Visible','off');title(a,'ID','fontsize',18);title(c,'#','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(edge{1},boundaryTF{1});set(f,'Visible','off');title(a,'edge','fontsize',18);title(c,'T/F','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);

[f,a,c] = myplot(boundaryTF{1});set(f,'Visible','off');title(a,'boundaryTF','fontsize',18);title(c,'T/F','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(boundaryID{1});set(f,'Visible','off');title(a,'boundaryID','fontsize',18);title(c,'#','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(neighborID{1},boundaryTF{1});set(f,'Visible','off');title(a,'neighborID','fontsize',18);title(c,'#','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(tripleTF{1});set(f,'Visible','off');title(a,'tripleTF','fontsize',18);title(c,'T/F','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(tripleID{1});set(f,'Visible','off');title(a,'tripleID','fontsize',18);title(c,'#','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);

[f,a,c] = myplot(dToBoundary{1},boundaryTF{1});set(f,'Visible','off');title(a,'dToBoundary','fontsize',18);title(c,'um','fontsize',18);caxis([0,90]); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(dToCenter{1},boundaryTF{1});set(f,'Visible','off');title(a,'dToCenter','fontsize',18);title(c,'um','fontsize',18);caxis([0,120]); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(dToTriple{1},boundaryTF{1});set(f,'Visible','off');title(a,'dToTriple','fontsize',18);title(c,'um','fontsize',18);caxis([0,120]); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(rToBoundary{1},boundaryTF{1});set(f,'Visible','off');title(a,'rToBoundary','fontsize',18);title(c,'1','fontsize',18);caxis([0,0.7]); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(rToCenter{1},boundaryTF{1});set(f,'Visible','off');title(a,'rToCenter','fontsize',18);title(c,'1','fontsize',18);caxis([0,1.3]); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(rToTriple{1},boundaryTF{1});set(f,'Visible','off');title(a,'rToTriple','fontsize',18);title(c,'1','fontsize',18);caxis([0,1]); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(neighborIDonGb{1});set(f,'Visible','off');title(a,'neighborIDonGb','fontsize',18);title(c,'#','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);

[f,a,c] = myplot(sfBa{1},boundaryTF{1});set(f,'Visible','off');title(a,'sfBa','fontsize',18);title(c,'1','fontsize',18);caxis([0,0.5]); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(sfPr{1},boundaryTF{1});set(f,'Visible','off');title(a,'sfPr','fontsize',18);title(c,'1','fontsize',18);caxis([0,0.5]); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(sfPy{1},boundaryTF{1});set(f,'Visible','off');title(a,'sfPy','fontsize',18);title(c,'1','fontsize',18);caxis([0,0.5]); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(sfPyCA{1},boundaryTF{1});set(f,'Visible','off');title(a,'sfPyCA','fontsize',18);title(c,'1','fontsize',18);caxis([0,0.5]); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(sfTT{1},boundaryTF{1});set(f,'Visible','off');title(a,'sfTT','fontsize',18);title(c,'1','fontsize',18);caxis([-0.5,0.5]); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(sfBaNum{1},boundaryTF{1});set(f,'Visible','off');title(a,'sfBaNum','fontsize',18);title(c,'#','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(sfPrNum{1},boundaryTF{1});set(f,'Visible','off');title(a,'sfPrNum','fontsize',18);title(c,'#','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(sfPyNum{1},boundaryTF{1});set(f,'Visible','off');title(a,'sfPyNum','fontsize',18);title(c,'#','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(sfPyCANum{1},boundaryTF{1});set(f,'Visible','off');title(a,'sfPyCANum','fontsize',18);title(c,'#','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(sfTTNum{1},boundaryTF{1});set(f,'Visible','off');title(a,'sfTTNum','fontsize',18);title(c,'#','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
image(IPF{1});title('IPF','fontsize',18);axis equal;title(gca,'IPF','fontsize',18);print([folder,'IPF'],'-dtiff','-r150');close(gcf);

[f,a,c] = myplot(exx,boundaryTF{1});set(f,'Visible','off');title(a,'exx','fontsize',18);title(c,'1','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(exy,boundaryTF{1});set(f,'Visible','off');title(a,'exy','fontsize',18);title(c,'1','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(eyy,boundaryTF{1});set(f,'Visible','off');title(a,'eyy','fontsize',18);title(c,'1','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(e1,boundaryTF{1});set(f,'Visible','off');title(a,'e1','fontsize',18);title(c,'1','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(e2,boundaryTF{1});set(f,'Visible','off');title(a,'e2','fontsize',18);title(c,'1','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(e3,boundaryTF{1});set(f,'Visible','off');title(a,'e3','fontsize',18);title(c,'1','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(sigma,boundaryTF{1});set(f,'Visible','off');title(a,'sigma','fontsize',18);title(c,'1','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);

[f,a,c] = myplot(exxAvg,boundaryTF{1});set(f,'Visible','off');title(a,'exxAvg','fontsize',18);title(c,'1','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(exyAvg,boundaryTF{1});set(f,'Visible','off');title(a,'exyAvg','fontsize',18);title(c,'1','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(eyyAvg,boundaryTF{1});set(f,'Visible','off');title(a,'eyyAvg','fontsize',18);title(c,'1','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(e1Avg,boundaryTF{1});set(f,'Visible','off');title(a,'e1Avg','fontsize',18);title(c,'1','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(e2Avg,boundaryTF{1});set(f,'Visible','off');title(a,'e2Avg','fontsize',18);title(c,'1','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(e3Avg,boundaryTF{1});set(f,'Visible','off');title(a,'e3Avg','fontsize',18);title(c,'1','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(exxStdAvg,boundaryTF{1});set(f,'Visible','off');title(a,'exxStdAvg','fontsize',18);title(c,'1','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(exyStdAvg,boundaryTF{1});set(f,'Visible','off');title(a,'exyStdAvg','fontsize',18);title(c,'1','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(eyyStdAvg,boundaryTF{1});set(f,'Visible','off');title(a,'eyyStdAvg','fontsize',18);title(c,'1','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(e1StdAvg,boundaryTF{1});set(f,'Visible','off');title(a,'e1StdAvg','fontsize',18);title(c,'1','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(e2StdAvg,boundaryTF{1});set(f,'Visible','off');title(a,'e2StdAvg','fontsize',18);title(c,'1','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(e3StdAvg,boundaryTF{1});set(f,'Visible','off');title(a,'e3StdAvg','fontsize',18);title(c,'1','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);

[f,a,c] = myplot(depth3D,boundaryTF{1});set(f,'Visible','off');title(a,'depth3D','fontsize',18);title(c,'um','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(width3D,boundaryTF{1});set(f,'Visible','off');title(a,'width3D','fontsize',18);title(c,'um','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(volume3D,boundaryTF{1});set(f,'Visible','off');title(a,'volume3D','fontsize',18);title(c,'um^3','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(diameter3D,boundaryTF{1});set(f,'Visible','off');title(a,'diameter3D','fontsize',18);title(c,'um','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(aspect3D,boundaryTF{1});set(f,'Visible','off');title(a,'aspect3D','fontsize',18);title(c,'1','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);

[f,a,c] = myplot(sfBa3D,boundaryTF{1});set(f,'Visible','off');title(a,'sfBa3D','fontsize',18);title(c,'1','fontsize',18);caxis([0,0.5]); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(sfPr3D,boundaryTF{1});set(f,'Visible','off');title(a,'sfPr3D','fontsize',18);title(c,'1','fontsize',18);caxis([0,0.5]); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(sfPy3D,boundaryTF{1});set(f,'Visible','off');title(a,'sfPy3D','fontsize',18);title(c,'1','fontsize',18);caxis([0,0.5]); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(sfPyCA3D,boundaryTF{1});set(f,'Visible','off');title(a,'sfPyCA3D','fontsize',18);title(c,'1','fontsize',18);caxis([0,0.5]); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(sfTT3D,boundaryTF{1});set(f,'Visible','off');title(a,'sfTT3D','fontsize',18);title(c,'1','fontsize',18);caxis([0,0.5]); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(sfBaNum3D,boundaryTF{1});set(f,'Visible','off');title(a,'sfBaNum3D','fontsize',18);title(c,'#','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(sfPrNum3D,boundaryTF{1});set(f,'Visible','off');title(a,'sfPrNum3D','fontsize',18);title(c,'#','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(sfPyNum3D,boundaryTF{1});set(f,'Visible','off');title(a,'sfPyNum3D','fontsize',18);title(c,'#','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(sfPyCANum3D,boundaryTF{1});set(f,'Visible','off');title(a,'sfPyCANum3D','fontsize',18);title(c,'#','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(sfTTNum3D,boundaryTF{1});set(f,'Visible','off');title(a,'sfTTNum3D','fontsize',18);title(c,'#','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(sf3D,boundaryTF{1});set(f,'Visible','off');title(a,'sf3D','fontsize',18);title(c,'1','fontsize',18);caxis([0,0.5]); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(sfNum3D,boundaryTF{1});set(f,'Visible','off');title(a,'sfNum3D','fontsize',18);title(c,'#','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);

[f,a,c] = myplot(avgMisoByGb3D,boundaryTF{1});set(f,'Visible','off');title(a,'avgMisoByGb3D','fontsize',18);title(c,'degree','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(avgMisoByVol3D,boundaryTF{1});set(f,'Visible','off');title(a,'avgMisoByVol3D','fontsize',18);title(c,'degree','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(avgNbDiaByGb3D,boundaryTF{1});set(f,'Visible','off');title(a,'avgNbDiaByGb3D','fontsize',18);title(c,'degree','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(avgNbDiaByVol3D,boundaryTF{1});set(f,'Visible','off');title(a,'avgNbDiaByVol3D','fontsize',18);title(c,'degree','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(misoStdByGb3D,boundaryTF{1});set(f,'Visible','off');title(a,'misoStdByGb3D','fontsize',18);title(c,'degree','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(misoStdByVol3D,boundaryTF{1});set(f,'Visible','off');title(a,'misoStdByVol3D','fontsize',18);title(c,'degree','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(nbDiaStdByGb3D,boundaryTF{1});set(f,'Visible','off');title(a,'nbDiaStdByGb3D','fontsize',18);title(c,'degree','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(nbDiaStdByVol3D,boundaryTF{1});set(f,'Visible','off');title(a,'nbDiaStdByVol3D','fontsize',18);title(c,'degree','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);

[f,a,c] = myplot(dToBoundary3D,boundaryTF{1});set(f,'Visible','off');title(a,'dToBoundary3D','fontsize',18);title(c,'um','fontsize',18);caxis([0,90]); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(dToTriple3D,boundaryTF{1});set(f,'Visible','off');title(a,'dToTriple3D','fontsize',18);title(c,'um','fontsize',18);caxis([0,120]); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(neighborID3D,boundaryTF{1});set(f,'Visible','off');title(a,'neighborID3D','fontsize',18);title(c,'#','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);

[f,a,c] = myplot(diaLocal,boundaryTF{1});set(f,'Visible','off');title(a,'diaLocal','fontsize',18);title(c,'um','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(nbDiaLocal,boundaryTF{1});set(f,'Visible','off');title(a,'nbDiaLocal','fontsize',18);title(c,'um','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(nbPlusDiaLocal,boundaryTF{1});set(f,'Visible','off');title(a,'nbPlusDiaLocal','fontsize',18);title(c,'um','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(nbPlusDiaLocal2,boundaryTF{1});set(f,'Visible','off');title(a,'nbPlusDiaLocal2','fontsize',18);title(c,'um','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(nbDiaByGbLocal,boundaryTF{1});set(f,'Visible','off');title(a,'nbDiaByGbLocal','fontsize',18);title(c,'um','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);

[f,a,c] = myplot(nbMisoLocal,boundaryTF{1});set(f,'Visible','off');title(a,'nbMisoLocal','fontsize',18);title(c,'degree','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(nbPlusMisoLocal,boundaryTF{1});set(f,'Visible','off');title(a,'nbPlusMisoLocal','fontsize',18);title(c,'degree','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(nbMisoByGbLocal,boundaryTF{1});set(f,'Visible','off');title(a,'nbMisoByGbLocal','fontsize',18);title(c,'degree','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);

[f,a,c] = myplot(mPm3D,boundaryTF{1});set(f,'Visible','off');title(a,'mPm3D','fontsize',18);title(c,'1','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);
[f,a,c] = myplot(mP3m3D,boundaryTF{1});set(f,'Visible','off');title(a,'mP3m3D','fontsize',18);title(c,'1','fontsize',18); print([folder,get(a.Title,'String')],'-dtiff','-r150');close(f);

