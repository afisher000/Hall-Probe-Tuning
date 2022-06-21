function traj_error = entrance_trajectory_error(p, field, optvars, plot_tf)

%% Get peaks from 2 to 10, compute linear component
idx         = find(abs(field.Bx)>.001, 1, 'first');
scn         = 1:idx-1;

field.lattice   = field.pos;
field.pos       = ( field.pos - 0.5 ) * .032/4;

% Extrapolate using scaled radia fields
if plot_tf
    figure(100); hold on;
    plot(field.pos, field.Bx, 'b');
    plot(field.pos, field.By, 'r');
end
field.Bx(scn)   = p.radia.Bx(scn) * field.Bx(idx) / p.radia.Bx(idx);
field.By(scn)   = p.radia.By(scn) * field.By(idx) / p.radia.By(idx);
if plot_tf
	plot(field.pos, field.Bx, 'b--');
    plot(field.pos, field.By, 'r--');
    legend('Raw Bx','Raw By','Extrap. Bx','Extrap. By');
    xlabel('Z (m)'); ylabel('Field (T)');
end
%% Parameters 
lamu            = .032;
ku              = 2*pi/lamu;
K0              = p.q*p.B0/p.m/p.c/ku;
G               = sqrt( lamu/2/p.lambda * (1+K0^2) );

%% Compute trajectory
xp              = +p.q/p.m/p.c * cumtrapz(field.pos,field.By./G);
yp              = -p.q/p.m/p.c * cumtrapz(field.pos,field.Bx./G);
ideal.xp        = +p.q/p.m/p.c * cumtrapz(field.pos,p.radia.By./G);
ideal.yp        = -p.q/p.m/p.c * cumtrapz(field.pos,p.radia.Bx./G);

xscn            = logical( (field.lattice>=2) .* (field.lattice<=10) );
yscn            = logical( (field.lattice>=1) .* (field.lattice<=9) );
x               = cumtrapz(field.pos, xp);
y               = cumtrapz(field.pos, yp);
ideal.x         = cumtrapz(field.pos, ideal.xp);
ideal.y         = cumtrapz(field.pos, ideal.yp);
px              = polyfit(field.pos(xscn), x(xscn), 1);
py              = polyfit(field.pos(yscn), y(yscn), 1);

angle_error     = abs(px(1))/1e-5 + abs(py(1))/1e-5;
offset_error    = abs(px(2))/5e-6 + abs(py(2))/5e-6;
norm_error      = 0; %L2norm(optvars/.010);
traj_error      = angle_error + 1000*offset_error + norm_error;

if plot_tf
    figure(); plot(field.pos, x, field.pos, y); ylabel('Entrance Trajectory'); xlabel('Z (m)');
        hold on; plot(field.pos(xscn), polyval(px,field.pos(xscn)), 'b--', field.pos(yscn), polyval(py,field.pos(yscn)), 'r--');
        legend('X traj',...
            'Y traj', ...
            sprintf('xp = %d um/m',round(px(1)*1e6)), ...
            sprintf('yp = %d um/m',round(py(1)*1e6)) );
    figure(); plot(field.pos, ideal.x, field.pos, ideal.y); ylabel('Ideal trajectory'); 
end

















end