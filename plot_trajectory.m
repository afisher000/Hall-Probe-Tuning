function plot_trajectory(p, field)

%% Compute trajectories
ent_scn     = logical( (field.Bx==0) .* p.lattice<0 );
ext_scn     = logical( (field.Bx==0) .* p.lattice>0 );
ent_idx     = find(ent_scn, 1, 'last');
ext_idx     = find(ext_scn, 1, 'first');

Bx          = field.Bx;
By          = field.By;

% Estimate tails of fields with scaled radia
Bx(ent_scn) = field.Bx(ent_scn) + p.radia.Bx(ent_scn)*Bx(ent_idx)/p.radia.Bx(ent_idx);
By(ent_scn) = field.By(ent_scn) + p.radia.By(ent_scn)*By(ent_idx)/p.radia.By(ent_idx);
Bx(ext_scn) = field.Bx(ext_scn) + p.radia.Bx(ext_scn)*Bx(ext_idx)/p.radia.Bx(ext_idx);
By(ext_scn) = field.By(ext_scn) + p.radia.By(ext_scn)*By(ext_idx)/p.radia.By(ext_idx);

% Compute velocity and trajectory
vy          = -p.q/p.gamma/p.m/p.c * (.032/4) * cumtrapz(p.lattice,Bx);
vx          = +p.q/p.gamma/p.m/p.c * (.032/4) * cumtrapz(p.lattice,By);
y           = (.032/4) * cumtrapz(p.lattice,vy);
x           = (.032/4) * cumtrapz(p.lattice,vx);

% Subtract linear components
ymodel      = polyfit(p.lattice, y, 1);
y_delined   = y - polyval(ymodel, p.lattice);
xmodel      = polyfit(p.lattice, x, 1);
x_delined   = x - polyval(xmodel, p.lattice);

% figure(); plot(field.pos,Bx);
% figure(); plot(p.lattice,y); title(sprintf('Y Trajectory (gamma=%.1f)',p.gamma)); ylabel('Y Trajectory (m)'); xlabel('Z (magnet number)');
% figure(); plot(p.lattice,x); title(sprintf('X Trajectory (gamma=%.1f)',p.gamma)); ylabel('Y Trajectory (m)'); xlabel('Z (magnet number)');
figure(); plot(p.lattice, x, p.lattice, y);
    legend('Xtraj','Ytraj'); title('Trajectory as integrated');
    xlabel('Z (magnet number)'); ylabel('Trajectory (m)');


figure(); plot(p.lattice, x_delined, p.lattice, y_delined);
    legend('Xtraj','Ytraj'); title('Trajectory subtracting linear part');
    xlabel('Z (magnet number)'); ylabel('Trajectory (m)');



% figure(); plot(p.lattice,Bx,p.lattice,-1*Bx,p.lattice,By,p.lattice,-1*By); legend('BxMax','BxMin','ByMax','ByMin'); ylim([.5 .8]);
% save('Hall Probe Fields and Trajectories','traj','p');