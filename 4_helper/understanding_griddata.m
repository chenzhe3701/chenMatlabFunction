close all;
% // define a surface
[A,B] = meshgrid(-3:0.25:3);
C = peaks(A,B);

%// poke some holes in it (in every coordinate set)
A(15,3:8)   = NaN ;
B(14:18,13) = NaN ;
C(8:12,16:21)  = NaN ;

figure;imagesc(A);
figure;imagesc(B);
figure;imagesc(C);

%// identify indices valid for the 3 matrix 
idxgood=~(isnan(A) | isnan(B) | isnan(C)); 
figure;imagesc(idxgood);

%// define a "uniform" grid without holes (same boundaries and sampling than original grid)
[AI,BI] = meshgrid(-3:0.25:3) ;

%// re-interpolate scattered data (only valid indices) over the "uniform" grid
CI = griddata( A(idxgood),B(idxgood),C(idxgood), AI, BI ) ;
figure; imagesc(CI);


[XI,YI] = meshgrid(-3:0.1:3) ;   %// create finer grid
ZI = interp2( AI,BI,CI,XI,YI ) ; %// re-interpolate
figure; imagesc(ZI);
