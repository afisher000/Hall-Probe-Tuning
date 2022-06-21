function total_error = errorfcn_tapered_slippage(p, field, optvars, plot_tf)

%% Define fields in Z space
scn             = logical( (field.pos>=p.start_slip) .* (field.pos<=p.end_slip) );
field.lattice   = field.pos(scn);
field.pos       = ( field.pos(scn) - 0.5 ) * .032/4;
field.Bx        = field.Bx(scn);
field.By        = field.By(scn);
ideal.pos       = field.pos;
ideal.Bx        = p.radia.Bx(scn);
ideal.By        = p.radia.By(scn);

if plot_tf
    figure(); title('Slippage Fields');
        xlabel('Z (m)'); ylabel('Field (T)');
        hold on;
        plot(field.lattice,field.Bx);
        plot(field.lattice,field.By); 
        legend('Bx','By');
        hold off; movegui('south');
end

%% Parameters 
lamu            = .032;
ku              = 2*pi/lamu;
K0              = p.q*p.B0/p.m/p.c/ku;
gamma           = sqrt( lamu/2/p.lambda * (1+K0^2) );

%% Define ideals and tapering
% Doesn't support taperdelay...
ideal.B         = p.B0*(1 + p.taper1 * field.pos + p.taper2 * field.pos.^2);
ideal.K         = p.q*ideal.B/p.m/p.c/ku;
ideal.G         = sqrt( (lamu/2/p.lambda) * (1+ideal.K.^2) ); 

%% Find x', y', x, and y. Subtract means to avoid using ICs. Compare with ideals
xp              = +p.q/p.m/p.c * cumtrapz(field.pos,field.By./ideal.G);
yp              = -p.q/p.m/p.c * cumtrapz(field.pos,field.Bx./ideal.G);
ideal.xp        = +p.q/p.m/p.c * cumtrapz(field.pos,ideal.By./ideal.G);
ideal.yp        = -p.q/p.m/p.c * cumtrapz(field.pos,ideal.Bx./ideal.G);
xp              = xp-mean(xp);
yp              = yp-mean(yp);

x               = cumtrapz(field.pos, xp);
y               = cumtrapz(field.pos, yp);
px              = polyfit(field.pos, x, 1);
py              = polyfit(field.pos, y, 1);
x               = x - polyval(px, field.pos); %just want linear trajectory
y               = y - polyval(py, field.pos); 

ideal.x         = cumtrapz(field.pos, ideal.xp);
ideal.y         = cumtrapz(field.pos, ideal.yp);
ideal.px        = polyfit(field.pos, ideal.x, 1);
ideal.py        = polyfit(field.pos, ideal.y, 1);
ideal.x         = ideal.x - polyval(ideal.px, field.pos);
ideal.y         = ideal.y - polyval(ideal.py, field.pos);

if plot_tf
%     figure(); plot(field.lattice, xp, field.lattice, yp); legend('xp','yp');
    figure(); plot(field.lattice, x, field.lattice, y); legend('x','y'); title('Trajectory - linear');
%     figure(); plot(field.lattice, orig_x, field.lattice, orig_y); legend('x','y'); title('Original Traj.');
%     figure(); plot(field.lattice, y, field.lattice, ideal.y); ylabel('X traj'); legend('Measured','Ideal');
end

%% Compute slippage
S               = 0.5 * cumtrapz(field.pos,1./ideal.G.^2 + xp.^2 + yp.^2);
ideal.S         = 0.5 * cumtrapz(field.pos,1./ideal.G.^2 + ideal.K.^2./ideal.G.^2);
Serror          = S - ideal.S;

%% Subtract off linear component of error (lamr slightly different from lambda)
% Confirm radiated lambda is correct
pS              = polyfit(field.pos, S, 1);
Meff            = pS(1);
lambda_eff      = lamu*Meff;
pSerror         = polyfit(field.pos,Serror,1);
Serror_eff      = Serror - polyval(pSerror,field.pos);

%% Subtract mean of slippage error
Serror          = Serror - mean(Serror);
Serror_eff      = Serror_eff - mean(Serror_eff);

%% Average the errors
avg_Serror      = smooth(Serror, 400);
rel_Serror      = avg_Serror/p.lambda;
avg_Serror_eff  = smooth(Serror_eff, 400);
rel_Serror_eff  = avg_Serror_eff/p.lambda;
    
avg_scn         = 400:(length(field.pos)-400);
field.magnet= 0.5 + field.pos * 4/.032;
if plot_tf
    figure(); movegui('southwest'); 
        subplot(1,2,1); hold on; 
        plot(field.magnet, Serror); 
        plot(field.magnet(avg_scn),avg_Serror(avg_scn) ); 
        legend('Error','Avg Error'); ylabel('Slippage error');
        
        subplot(1,2,2); 
        plot(field.magnet(avg_scn), rel_Serror(avg_scn) );  
        legend('Rel Avg Error');
        sgtitle('\lambda_r = 515 nm');
end
    
%% Find measured and ideal peak fields
[xpks,bxloc]    = findpeaks(abs(field.Bx),'MinPeakProminence',0.05);
[ypks,byloc]    = findpeaks(abs(field.By),'MinPeakProminence',0.05);
pks             = [xpks; ypks];
ideal.pks       = ideal.B([bxloc; byloc]);


%% Compute final error
error.avgslip   = L2norm( rel_Serror(avg_scn)/0.5e-3 ) ;
error.slip      = L2norm( Serror/5e-9 );
error.traj      = L2norm( (x-ideal.x)/5e-6 ) + ...
                  L2norm( (y-ideal.x)/5e-6 );
error.pks       = L2norm( diff(pks-ideal.pks)/.005 );
error.optvars   = L2norm( optvars/.002 );

weight.avgslip  = 1;
weight.slip     = 0;
weight.pks      = 2;
weight.traj     = 10;
weight.optvars  = 5;

total_error     = weight.avgslip*error.avgslip + ...
                    weight.slip*error.slip + ...
                    weight.traj*error.traj + ...
                    weight.pks*error.pks + ...
                    weight.optvars*error.optvars;

if plot_tf
    xvec = 1:length(pks);
    figure(); plot(xvec, pks, xvec, ideal.pks);   
    fprintf('Errors:\n');
    fprintf('%-16s%.2f\n',...
        'Avg. Slippage', error.avgslip,...
        'Slippage', error.slip,...
        'Trajectory', error.traj,...
        'Peaks', error.pks,...
        'Optvars', error.optvars);
    figure(); plot(optvars*1000,'.'); ylabel('mT');
end

end