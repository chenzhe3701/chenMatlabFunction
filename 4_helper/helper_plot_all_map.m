
myplot(x{1},boundaryTF{1});title('x','fontsize',18);title(colorbar,'um','fontsize',18)
myplot(y{1},boundaryTF{1});title('y','fontsize',18);title(colorbar,'um','fontsize',18)
myplot(phi1{1},boundaryTF{1});title('phi1','fontsize',18);title(colorbar,'degree','fontsize',18)
myplot(phi{1},boundaryTF{1});title('phi','fontsize',18);title(colorbar,'degree','fontsize',18)
myplot(phi2{1},boundaryTF{1});title('phi2','fontsize',18);title(colorbar,'degree','fontsize',18)
myplot(ID{1},boundaryTF{1});title('ID','fontsize',18);title(colorbar,'#','fontsize',18)
myplot(edge{1},boundaryTF{1});title('edge','fontsize',18);title(colorbar,'T/F','fontsize',18)

myplot(boundaryTF{1});title('boundaryTF','fontsize',18);title(colorbar,'T/F','fontsize',18)
myplot(boundaryID{1});title('boundaryID','fontsize',18);title(colorbar,'#','fontsize',18)
myplot(neighborID{1},boundaryTF{1});title('neighborID','fontsize',18);title(colorbar,'#','fontsize',18)
myplot(tripleTF{1});title('tripleTF','fontsize',18);title(colorbar,'T/F','fontsize',18)
myplot(tripleID{1});title('tripleID','fontsize',18);title(colorbar,'#','fontsize',18)

myplot(dToBoundary{1},boundaryTF{1});title('dToBoundary','fontsize',18);title(colorbar,'um','fontsize',18);caxis([0,90]);
myplot(dToCenter{1},boundaryTF{1});title('dToCenter','fontsize',18);title(colorbar,'um','fontsize',18);caxis([0,120]);
myplot(dToTriple{1},boundaryTF{1});title('dToTriple','fontsize',18);title(colorbar,'um','fontsize',18);caxis([0,120]);
myplot(rToBoundary{1},boundaryTF{1});title('rToBoundary','fontsize',18);title(colorbar,'1','fontsize',18);caxis([0,0.7]);
myplot(rToCenter{1},boundaryTF{1});title('rToCenter','fontsize',18);title(colorbar,'1','fontsize',18);caxis([0,1.3]);
myplot(rToTriple{1},boundaryTF{1});title('rToTriple','fontsize',18);title(colorbar,'1','fontsize',18);caxis([0,1]);
myplot(neighborID{1},boundaryTF{1});title('neighborID','fontsize',18);title(colorbar,'#','fontsize',18);

myplot(sfBa{1},boundaryTF{1});title('sfBa','fontsize',18);title(colorbar,'1','fontsize',18);caxis([0,0.5]);
myplot(sfPr{1},boundaryTF{1});title('sfPr','fontsize',18);title(colorbar,'1','fontsize',18);caxis([0,0.5]);
myplot(sfPy{1},boundaryTF{1});title('sfPy','fontsize',18);title(colorbar,'1','fontsize',18);caxis([0,0.5]);
myplot(sfPyCA{1},boundaryTF{1});title('sfPyCA','fontsize',18);title(colorbar,'1','fontsize',18);caxis([0,0.5]);
myplot(sfTT{1},boundaryTF{1});title('sfTT','fontsize',18);title(colorbar,'1','fontsize',18);caxis([-0.5,0.5]);
myplot(sfBaNum{1},boundaryTF{1});title('sfBaNum','fontsize',18);title(colorbar,'#','fontsize',18);
myplot(sfPrNum{1},boundaryTF{1});title('sfPrNum','fontsize',18);title(colorbar,'#','fontsize',18);
myplot(sfPyNum{1},boundaryTF{1});title('sfPyNum','fontsize',18);title(colorbar,'#','fontsize',18);
myplot(sfPyCANum{1},boundaryTF{1});title('sfPyCANum','fontsize',18);title(colorbar,'#','fontsize',18);
myplot(sfTTNum{1},boundaryTF{1});title('sfTTNum','fontsize',18);title(colorbar,'#','fontsize',18);
image(IPF{1});title('IPF','fontsize',18);axis equal;

myplot(exx,boundaryTF{1});title('exx','fontsize',18);title(colorbar,'1','fontsize',18);
myplot(exy,boundaryTF{1});title('exy','fontsize',18);title(colorbar,'1','fontsize',18);
myplot(eyy,boundaryTF{1});title('eyy','fontsize',18);title(colorbar,'1','fontsize',18);
myplot(e1,boundaryTF{1});title('e1','fontsize',18);title(colorbar,'1','fontsize',18);
myplot(e2,boundaryTF{1});title('e2','fontsize',18);title(colorbar,'1','fontsize',18);
myplot(e3,boundaryTF{1});title('e3','fontsize',18);title(colorbar,'1','fontsize',18);
myplot(sigma,boundaryTF{1});title('sigma','fontsize',18);title(colorbar,'1','fontsize',18);

myplot(exxAvg,boundaryTF{1});title('exxAvg','fontsize',18);title(colorbar,'1','fontsize',18);
myplot(exyAvg,boundaryTF{1});title('exyAvg','fontsize',18);title(colorbar,'1','fontsize',18);
myplot(eyyAvg,boundaryTF{1});title('eyyAvg','fontsize',18);title(colorbar,'1','fontsize',18);
myplot(e1Avg,boundaryTF{1});title('e1Avg','fontsize',18);title(colorbar,'1','fontsize',18);
myplot(e2Avg,boundaryTF{1});title('e2Avg','fontsize',18);title(colorbar,'1','fontsize',18);
myplot(e3Avg,boundaryTF{1});title('e3Avg','fontsize',18);title(colorbar,'1','fontsize',18);
myplot(exxStdAvg,boundaryTF{1});title('exxStdAvg','fontsize',18);title(colorbar,'1','fontsize',18);
myplot(exyStdAvg,boundaryTF{1});title('exyStdAvg','fontsize',18);title(colorbar,'1','fontsize',18);
myplot(eyyStdAvg,boundaryTF{1});title('eyyStdAvg','fontsize',18);title(colorbar,'1','fontsize',18);
myplot(e1StdAvg,boundaryTF{1});title('e1StdAvg','fontsize',18);title(colorbar,'1','fontsize',18);
myplot(e2StdAvg,boundaryTF{1});title('e2StdAvg','fontsize',18);title(colorbar,'1','fontsize',18);
myplot(e3StdAvg,boundaryTF{1});title('e3StdAvg','fontsize',18);title(colorbar,'1','fontsize',18);

myplot(depth3D,boundaryTF{1});title('depth3D','fontsize',18);title(colorbar,'um','fontsize',18);
myplot(width3D,boundaryTF{1});title('width3D','fontsize',18);title(colorbar,'um','fontsize',18);
myplot(volume3D,boundaryTF{1});title('volume3D','fontsize',18);title(colorbar,'um^3','fontsize',18);
myplot(diameter3D,boundaryTF{1});title('diameter3D','fontsize',18);title(colorbar,'um','fontsize',18);
myplot(aspect3D,boundaryTF{1});title('aspect3D','fontsize',18);title(colorbar,'1','fontsize',18);

myplot(sfBa3D,boundaryTF{1});title('sfBa3D','fontsize',18);title(colorbar,'1','fontsize',18);caxis([0,0.5]);
myplot(sfPr3D,boundaryTF{1});title('sfPr3D','fontsize',18);title(colorbar,'1','fontsize',18);caxis([0,0.5]);
myplot(sfPy3D,boundaryTF{1});title('sfPy3D','fontsize',18);title(colorbar,'1','fontsize',18);caxis([0,0.5]);
myplot(sfPyCA3D,boundaryTF{1});title('sfPyCA3D','fontsize',18);title(colorbar,'1','fontsize',18);caxis([0,0.5]);
myplot(sfTT3D,boundaryTF{1});title('sfTT3D','fontsize',18);title(colorbar,'1','fontsize',18);caxis([0,0.5]);
myplot(sfBaNum3D,boundaryTF{1});title('sfBaNum3D','fontsize',18);title(colorbar,'#','fontsize',18);
myplot(sfPrNum3D,boundaryTF{1});title('sfPrNum3D','fontsize',18);title(colorbar,'#','fontsize',18);
myplot(sfPyNum3D,boundaryTF{1});title('sfPyNum3D','fontsize',18);title(colorbar,'#','fontsize',18);
myplot(sfPyCANum3D,boundaryTF{1});title('sfPyCANum3D','fontsize',18);title(colorbar,'#','fontsize',18);
myplot(sfTTNum3D,boundaryTF{1});title('sfTTNum3D','fontsize',18);title(colorbar,'#','fontsize',18);
myplot(sf3D,boundaryTF{1});title('sf3D','fontsize',18);title(colorbar,'1','fontsize',18);caxis([0,0.5]);
myplot(sfNum3D,boundaryTF{1});title('sfNum3D','fontsize',18);title(colorbar,'#','fontsize',18);

myplot(avgMisoByGb3D,boundaryTF{1});title('avgMisoByGb3D','fontsize',18);title(colorbar,'degree','fontsize',18);
myplot(avgMisoByVol3D,boundaryTF{1});title('avgMisoByVol3D','fontsize',18);title(colorbar,'degree','fontsize',18);
myplot(avgNbDiaByGb3D,boundaryTF{1});title('avgNbDiaByGb3D','fontsize',18);title(colorbar,'degree','fontsize',18);
myplot(avgNbDiaByVol3D,boundaryTF{1});title('avgNbDiaByVol3D','fontsize',18);title(colorbar,'degree','fontsize',18);
myplot(misoStdByGb3D,boundaryTF{1});title('misoStdByGb3D','fontsize',18);title(colorbar,'degree','fontsize',18);
myplot(misoStdByVol3D,boundaryTF{1});title('misoStdByVol3D','fontsize',18);title(colorbar,'degree','fontsize',18);
myplot(nbDiaStdByGb3D,boundaryTF{1});title('nbDiaStdByGb3D','fontsize',18);title(colorbar,'degree','fontsize',18);
myplot(nbDiaStdByVol3D,boundaryTF{1});title('nbDiaStdByVol3D','fontsize',18);title(colorbar,'degree','fontsize',18);

myplot(dToBoundary3D,boundaryTF{1});title('dToBoundary3D','fontsize',18);title(colorbar,'um','fontsize',18);caxis([0,90]);
myplot(dToTriple3D,boundaryTF{1});title('dToTriple3D','fontsize',18);title(colorbar,'um','fontsize',18);caxis([0,120]);
myplot(neighborID3D,boundaryTF{1});title('neighborID3D','fontsize',18);title(colorbar,'#','fontsize',18);

myplot(misoLocalByVol,boundaryTF{1});title('misoLocalByVol','fontsize',18);title(colorbar,'degree','fontsize',18);
myplot(nbDiaLocalByVol,boundaryTF{1});title('nbDiaLocalByVol','fontsize',18);title(colorbar,'degree','fontsize',18);
myplot(misoLocalByGb,boundaryTF{1});title('misoLocalByGb','fontsize',18);title(colorbar,'degree','fontsize',18);
myplot(nbDiaLocalByGb,boundaryTF{1});title('nbDiaLocalByGb','fontsize',18);title(colorbar,'degree','fontsize',18);

myplot(mPrime,boundaryTF{1});title('mPrime','fontsize',18);title(colorbar,'degree','fontsize',18);

