% chenzhe 2016-3-17
% try to use fill3 to draw hcp_cell
%
% chenzhe 2016 5-31
% Modify again. To view from -z direction, x-right, y-down, use set(gca,'ydir','reverse','zdir','reverse').

function [] = hcp_cell(varargin)
[euler,phi_sys,phi_error] = parse_angle_inputs(varargin);
g = euler_to_transformation(euler,phi_sys,phi_error);
[ssa, c_a] = define_SS('Ti','notwin');
nss = size(ssa,3);
ss = hex_to_cart_ss(ssa,c_a);
stress = [1 0 0; 0 0 0; 0 0 0];
for ii = 1:24
    N(ii,:) = ss(1,:,ii) * g;
    M(ii,:) = ss(2,:,ii) * g;
    abs_SF(ii,1) = ii;
    abs_SF(ii,2) = N(ii,:)*stress*M(ii,:)';
    slipTrace(ii,:) = cross(N(ii,:), [0 0 1]);
end
plot_order = sortrows (abs_SF,-2);
        

close all;
vert = [2/3 -1/3 -1/3 0;
    1/3 1/3 -2/3 0;
    -1/3 2/3 -1/3 0;
    -2/3 1/3 1/3 0;
    -1/3 -1/3 2/3 0;
    1/3 -2/3 1/3 0;
    2/3 -1/3 -1/3 1;
    1/3 1/3 -2/3 1;
    -1/3 2/3 -1/3 1;
    -2/3 1/3 1/3 1;
    -1/3 -1/3 2/3 1;
    1/3 -2/3 1/3 1];
vert = uvtw2xyz(vert);
vert = vert * g;
face = {[1,2,3,4,5,6],[7,8,9,10,11,12],[2,3,9,8],[1,2,8,7],...
    [3,4,10,9],[5,6,12,11],[4,5,11,10],[6,1,7,12]};
hold on;
for ii=1:length(face)
    fill3(vert(face{ii},1),vert(face{ii},2),vert(face{ii},3),'w','facealpha',0.3,'linewidth',2);
end
set(gca,'xlim',[-2,2],'ylim',[-2,2]);
axis equal;
set(gca,'ydir','reverse','zdir','reverse')


