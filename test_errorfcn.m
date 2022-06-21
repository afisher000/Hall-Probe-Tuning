function error = test_errorfcn(p, x, field, plot_tf)

%% Apply shift variable
field.Bx        = interp1(p.lattice + x(1), field.Bx, p.lattice,'makima',0);
field.By        = interp1(p.lattice + x(1), field.By, p.lattice,'makima',0);
field.Bz        = interp1(p.lattice + x(1), field.Bz, p.lattice,'makima',0);

%% Get indices for optimization
starti          = find( p.lattice ==(p.start_tune-0.5) );
endi            = find( p.lattice ==(p.start_tune+p.Ncrit-0.5) );
scn             = starti:endi;

delta_Bx        = get_adjustment_Bxy(p, x(2:end), 'Bx');
delta_By        = get_adjustment_Bxy(p, x(2:end), 'By');
delta_Bz        = get_adjustment_Bz(p, x(2:end));

new_field.pos   = p.lattice;
new_field.Bx    = field.Bx + delta_Bx;
new_field.By    = field.By + delta_By;
new_field.Bz    = field.Bz + delta_Bz;


Bx_dfield       = new_field.Bx - p.radia.Bx;
By_dfield       = new_field.By - p.radia.By;
Bz_dfield       = new_field.Bz - p.radia.Bz;

% Zero outside tuning range
Bx_dfield(~scn) = 0; 
By_dfield(~scn) = 0;
Bz_dfield(~scn) = 0;

% Return error
Bx_error        = L2norm( Bx_dfield(scn)/5e-3 );
By_error        = L2norm( By_dfield(scn)/5e-3 );
Bz_error        = L2norm( Bz_dfield(scn)/5e-3 );
switch p.opt_type
    case 'Bxy'
        error = Bx_error + By_error;
    case 'Bz'
        error = Bz_error;
    case 'slippage'
        error   = errorfcn_tapered_slippage(p, new_field, x(2:end), plot_tf);
    case 'entrance'
        traj_error = entrance_trajectory_error(p, new_field, x(2:end), plot_tf);
        error = traj_error + Bx_error + By_error;
end
        
if plot_tf
    switch p.opt_type
        case 'Bxy'
        case 'Bz'
            figure(); plot(p.lattice, delta_Bz); title('Delta Bz');
            figure(); plot(p.lattice, field.Bz, p.lattice, field.Bz + delta_Bz); legend('Before Tuning','After Tuning');

            figure(); plot(p.lattice, field.Bz, p.lattice, field.Bz+delta_Bz, p.lattice, p.radia.Bz);
                legend('Orig Field','Tuned field','Ideal'); title('Bz field');
                xlim([p.start_tune, p.end_tune]);
            figure(100); hold on; plot(p.lattice, field.Bz);
                xlim([p.start_tune, p.end_tune]); hold off;
        case 'slippage'
        case 'entrance'
            figure(); plot(new_field.pos, new_field.Bx, p.radia.pos, p.radia.Bx);
                legend('Tuned','Ideal');
            figure(); plot(new_field.pos, new_field.Bx,...
                            new_field.pos, new_field.By);
                title('New Fields'); ylabel('Field (mT)'); legend('Bx','By')
                xlabel('Z (m)'); 
    end
end
