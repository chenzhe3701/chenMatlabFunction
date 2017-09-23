% make drawings, and do some example calculations, to illustrate how sample
% bending can affect the measured strain/displacement field.

p0 = [0,0,100];
p1 = [-60, 60, 0];
p2 = [-60, -60, 0];
p3 = [60, -60, 0];
p4 = [60, 60, 0];

M = angle2dcm(0, 10/180*pi, 0, 'zyz');
R = M';
q1 = p1 * M;
q2 = p2 * M;
q3 = p3 * M;
q4 = p4 * M;

figure; hold on; axis equal; set(gca,'xlim',[-80,80],'ylim',[-80,80],'zlim',[-40,100]);view([1 -1 1]);
fill3([p1(1),p2(1),p3(1),p4(1),p1(1)],...
    [p1(2),p2(2),p3(2),p4(2),p1(2)],...
    [p1(3),p2(3),p3(3),p4(3),p1(3)],'k','facealpha',0.5,'edgecolor','k');
fill3([q1(1),q2(1),q3(1),q4(1),q1(1)],...
    [q1(2),q2(2),q3(2),q4(2),q1(2)],...
    [q1(3),q2(3),q3(3),q4(3),q1(3)],'r','facealpha',0.5,'edgecolor','r');
plot3([p0(1),q1(1)],[p0(2),q1(2)],[p0(3),q1(3)],'-r');
plot3([p0(1),interp1([p0(3),q1(3)],[p0(1),q1(1)],0,'linear','extrap')],...
    [p0(2),interp1([p0(3),q1(3)],[p0(2),q1(2)],0,'linear','extrap')],...
    [p0(3), 0], '-r');
plot3([p0(1),interp1([p0(3),q2(3)],[p0(1),q2(1)],0,'linear','extrap')],...
    [p0(2),interp1([p0(3),q2(3)],[p0(2),q2(2)],0,'linear','extrap')],...
    [p0(3), 0], '-r');
plot3([p0(1),q3(1)],[p0(2),q3(2)],[p0(3),q3(3)],'-r');
plot3([p0(1),q4(1)],[p0(2),q4(2)],[p0(3),q4(3)],'-r');

%%
X = 120;
thetad = 21;
H = 20000;
Y = 120;
X_measured = H * X/2*cosd(thetad)/(H+X/2*sind(thetad)) + H * X/2*cosd(thetad)/(H+X/2-sind(thetad));
artificial_strain_x = (X-X_measured)/X
y_measured_low = H*Y/(H+X/2*sind(thetad));
y_measured_high = H*Y/(H-X/2*sind(thetad));
artificial_strain_y1 = (Y - y_measured_low)/Y
artificial_strain_y1 = (y_measured_high - Y)/Y
