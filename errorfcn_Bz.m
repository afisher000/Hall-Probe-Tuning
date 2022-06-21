function error=errorfcn_Bz(p, x, field, plot_tf)
%% Apply shift variable
field.Bx        = interp1(p.lattice + x(1), field.Bx, p.lattice,'makima',0);
field.By        = interp1(p.lattice + x(1), field.By, p.lattice,'makima',0);
field.Bz        = interp1(p.lattice + x(1), field.Bz, p.lattice,'makima',0);
%% Get indices for optimization
starti  = find( p.lattice ==(p.start_tune-0.5) );
endi    = find( p.lattice ==(p.start_tune+p.Ncrit-0.5) );
scn     = starti:endi;

delta_Bz    = get_adjustment_Bz(p, x(2:end));
Bz_error    = field.Bz + delta_Bz - p.radia.Bz; %Ideal radia is 0
error       = L2norm( Bz_error(scn) );

if strcmp(p.opt_error','slippage')
    warning('Bz optimization cannot use slippage condition. Error calculated from fields.');
end


%% Plot flag
if plot_tf
%     figure(); plot(p.lattice, delta_Bz); title('Delta Bz');
    figure(); plot(p.lattice, field.Bz, p.lattice, field.Bz + delta_Bz); legend('Before Tuning','After Tuning');
    
%     figure(); plot(p.lattice, field.Bz, p.lattice, field.Bz+delta_Bz, p.lattice, p.radia.Bz);
%         legend('Orig Field','Tuned field','Ideal'); title('Bz field');
%         xlim([p.start_tune, p.end_tune]);
%     figure(100); hold on; plot(p.lattice, field.Bz);
%         xlim([p.start_tune, p.end_tune]); hold off;
end