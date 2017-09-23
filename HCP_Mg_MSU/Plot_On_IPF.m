%  This code plots an inverse pole figure, i.e., a direction of the sample projected in the crystal's coordinate system.
%  Note: for different c_a ratio, the same point in IPF represents diffrent crystallographic direction. 
%  So, don't considers the position of the poles to be propotional...
%  Zhe Chen, rewritten based on the structure built by Hongmei & Dr. Bieler
%  2011-08-25


clc;
clear;

Nbasal = 105;    % number of basal slip
Nprism = 4;     % number of prism slip
Npyram = 10;     % number of pyramidal slip
                % the rest is tensile twin

Euler(:,3:5) = [216.478   38.220  133.38
207.239   42.680  138.42
222.677   36.958  124.03
227.858   59.892  151.21
240.739   72.060  139.93
312.089   76.381   76.08
27.824   62.112  330.66
224.467   41.270  149.74
244.817   73.601  119.93
213.471   40.447  146.84
336.331   31.050    1.22
30.764   68.367  348.35
48.436   79.560  331.67
317.515   79.555   88.86
182.881   39.973  167.96
34.040   62.582  317.96
67.097   75.179  301.98
203.206   43.806  153.83
60.375   71.817  268.49
201.039   61.622  139.98
231.441   45.650  103.63
242.231   75.844  141.41
234.568   69.349  148.14
291.962   84.038   81.27
244.320   51.545  100.72
153.769   48.620  146.76
18.510   47.304    8.50
318.359   74.538   23.49
359.432   37.282  347.81
235.812   60.025  141.68
40.178   56.216  296.56
232.101   61.019  136.56
21.645   49.058  315.29
338.803   60.877   18.82
172.589   67.441  164.07
55.609   57.509  323.75
150.309   41.454  251.65
173.154   40.460  158.72
168.999   40.040  225.50
219.164   78.552  132.62
323.650   80.775   30.21
157.708   38.477  225.56
35.946   40.013  295.43
229.607   53.206  113.38
52.204   55.112  285.37
141.053   46.693  212.52
140.494   43.405  226.11
220.680   46.619  103.40
49.833   66.825  331.95
66.032   66.676  269.85
44.032   37.647  309.53
244.282   88.828   99.36
50.873   44.281  310.57
203.597   70.240  128.33
56.634   86.569  332.69
205.539   29.984  180.10
38.245   39.533  305.48
36.813   44.075  312.87
60.649   88.322  285.72
302.885   72.976   70.28
338.052   39.636   28.37
118.391   86.001  235.27
8.955   30.994  332.32
197.538   63.491  160.79
58.174   88.648  287.36
49.894   73.614  287.83
309.173   82.332   27.85
41.235   74.974  343.95
214.522   73.691  165.77
224.333   82.639  153.39
154.449   59.333  230.73
30.850   66.229  351.32
214.650   81.289  141.89
153.624   66.348  203.91
173.494   46.515  177.45
149.967   56.453  238.35
50.228   67.222  315.72
356.441   52.269   25.09
42.408   63.153  338.33
163.790   41.729  180.22
219.566   80.703  140.01
62.630   53.978  283.24
110.345   88.257  237.48
238.990   74.099   96.21
337.786   27.857    0.75
57.179   59.761  306.47
50.458   49.223  319.15
16.233   39.648  337.18
173.052   57.855  172.64
43.010   64.067  300.47
25.411   45.033  333.55
156.146   64.422  188.75
49.129   70.337  311.63
36.590   79.097  315.85
318.103   71.886   27.72
217.260   70.540  154.31
106.430   60.903  227.63
113.845   82.495  274.22
296.925   70.746   75.65
206.532   27.532  166.16
302.665   79.223   70.36
132.594   80.869  200.00
149.495   59.846  227.60
1.973   51.887    3.50
323.621   45.196   64.51
224.398   26.474  116.36
28.547   49.354  327.71
52.227   40.586  297.90
55.243   33.197  277.64
242.698   71.116  142.82
244.213   76.152  139.31
66.989   72.859  315.82
22.519   69.946  329.96
86.818   46.338  300.48
265.704   62.669   73.88
171.618   62.160  206.03
118.391   86.001  235.27
196.536   80.508  185.44
205.274   79.008  146.01
];  % Euler angle, can be more than one set, each set occupies one row
phi_sys = -90;  % angle between EBSD data X axis and common-X-pointing-right X axis
phi_error = 0;  % angle error caused by placing the sample when doing experiment. i.e., rotate EBSD into In-situ SEM image orientation

Stress_State = [ 1 0 0; 0 0 0; 0 0 0];
Stress_State = Stress_State/norm(Stress_State);
sample_normal = [1 0 0];    % Direction you are interested in.  If it's [0 0 1], it's the normal direction of the sample
                            % here if I write [1 0 0], it means tensile axis is the interested direction
c_a = 1.62;
nss = 18;

g_sys = [
    cosd(phi_sys) cosd(phi_sys-90) 0;
    cosd(phi_sys+90) cosd(phi_sys) 0;
    0 0 1];
g_error = [
    cosd(phi_error) cosd(phi_error-90) 0;
    cosd(phi_error+90) cosd(phi_error) 0;
    0 0 1];


% generate inverse pole figure
hold on;
axis square;
axis([0 1.2 0 1.2]);
theta = [0:1:30];  % just the paremeter 'theta'
border_x = [0 cosd(theta) 0];
border_y = [0 sind(theta) 0];
plot(border_x, border_y, 'k-');
% border_x2 = [0 cosd(theta)*sqrt(3)/3 0];  % this is for plotting 60_degree line
% border_y2 = [0 sind(theta)*sqrt(3)/3 0];
% plot(border_x2, border_y2, 'k-');
set_of_Euler = size(Euler);  % sets of Euler angles

for i = 1:1:set_of_Euler(1,1)
    phi1 = Euler(i,3);
    PHI = Euler(i,4);
    phi2 = Euler(i,5);
    
    g_phi1 = [
        cosd(phi1) cosd(phi1-90) 0;
        cosd(phi1+90) cosd(phi1) 0;
        0 0 1];
    g_PHI = [
        1 0 0;
        0 cosd(PHI) cosd(PHI-90);
        0 cosd(PHI+90) cosd(PHI)];
    g_phi2 = [
        cosd(phi2) cosd(phi2-90) 0;
        cosd(phi2+90) cosd(phi2) 0;
        0 0 1];
    g(:,:,i) = g_phi2*g_PHI*g_phi1*g_sys*g_error;  % g is the 'transformation matrix' of Euler angle set i: x=gX, X is global.
    pole = g(:,:,i)*sample_normal.';  % sample normal in crystallographic Cartesian coordinate
    x = abs(pole(1));
    y = abs(pole(2));
    z = abs(pole(3));
    X = x/(1+z);
    Y = y/(1+z);  % This convert all points to 1st octant, then plot.  If you convert all point into 7th, then use X=x/(1-z), Y=y/(1-z).
    if z == 1  % for the extreme condition...
        X = 10^(-9); 
    end
    
    alpha = atand(Y/X);
    alpha = 30-abs(rem(alpha,60)-30);  % change to it's corresponding angle which is between 0-30 degrees.
    r = sqrt(X^2+Y^2);
    X = r*cosd(alpha);  % change the coord. X,Y into the plot region
    Y = r*sind(alpha);
    
    % plot basal red, prism blue, pryII black, tension twin green.
    if i<Nbasal+1
    plot(X,Y,'o','LineWidth',1,'MarkerEdgeColor',[1 1 1],...
                'MarkerFaceColor',[1 0 0],'MarkerSize',8)
    elseif i<Nbasal+Nprism+1
    plot(X,Y,'s','LineWidth',1,'MarkerEdgeColor',[1 1 1],...
                'MarkerFaceColor',[0 0 1],'MarkerSize',8)    
    elseif i<Nbasal+Nprism+Npyram+1
    plot(X,Y,'d','LineWidth',1,'MarkerEdgeColor',[1 1 1],...
                'MarkerFaceColor',[0 0 0],'MarkerSize',7)
    else
    plot(X,Y,'^','LineWidth',1,'MarkerEdgeColor',[1 1 1],...
                'MarkerFaceColor',[0.2 0.9 0.1],'MarkerSize',8)
    end
    %text(X,Y+0.03,num2str(i))
end

text(0.01,0.12,'0 0 0 1')
text(1.02,0.02,'2 -1 -1 0')
text(0.87,0.52,'1 0 -1 0')
hold off;


