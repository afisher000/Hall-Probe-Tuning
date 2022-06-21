function error = errorfcn_Bxy(p, x, field, plot_tf)
%% Apply shift variable
field.Bx        = interp1(p.lattice + x(1), field.Bx, p.lattice, 'makima', 0);
field.By        = interp1(p.lattice + x(1), field.By, p.lattice, 'makima', 0);
field.Bz        = interp1(p.lattice + x(1), field.Bz, p.lattice, 'makima', 0);

%% Get indices for optimization
starti  = find( p.lattice == (p.start_tune-0.5) );
endi    = find( p.lattice == (p.start_tune+p.Ncrit-0.5) );
scn     = starti:endi;

% Deltas may stay 0 so Slippage calc. code is same for 'Bx','By', and 'Bxy'
delta_Bx= zeros(1, length(p.lattice) );
delta_By= zeros(1, length(p.lattice) );
error   = 0;


%% Find error in Fields (run even if opt_error~='field' to compute deltas)
if strcmp(p.opt_field,'Bx') || strcmp(p.opt_field,'Bxy')
    delta_Bx        = get_adjustment_Bxy(p, x(2:end), 'Bx');
    Bx_error        = field.Bx + delta_Bx - p.radia.Bx;
    Bx_error(~scn)  = 0;
    xerror          = sqrt(Bx_error(scn)*Bx_error(scn)')/length(scn);
    error           = error + xerror;
end
if strcmp(p.opt_field,'By') || strcmp(p.opt_field,'Bxy')
    delta_By        = get_adjustment_Bxy(p, x(2:end), 'By');
    By_error        = field.By + delta_By - p.radia.By;
    By_error(~scn)  = 0;
    yerror          = sqrt(By_error(scn)*By_error(scn)')/length(scn);
    error           = error + yerror;
end

%% Find slippage error if needed
if strcmp(p.opt_error,'slippage')
    % Truncate so all field peaks are in slippage tuning range
    slippage_field.pos  = p.lattice;
    slippage_field.Bx   = field.Bx + delta_Bx;
    slippage_field.By   = field.By + delta_By; 
    error           = errorfcn_tapered_slippage(p, slippage_field, x(2:end), plot_tf); 
    
    % Add penalty for use of many magnets
%     error           = error + .1*sum(round(1000*x(2:end))~=0);
end


%% Plot flag
if plot_tf
%     figure(); plot(p.lattice, delta_Bx, p.lattice, delta_By);
%         legend('Change in Bx','Change in By');
%         xlim([p.start_tune, p.end_tune]);
%     figure(); plot(p.lattice, field.Bx, p.lattice, field.Bx+delta_Bx, p.lattice, p.radia.Bx);
%         legend('Orig Field','Tuned field','Ideal'); title('Bx field');
%         xlim([p.start_tune, p.end_tune]);
%     figure(); plot(p.lattice, field.By, p.lattice, field.By+delta_By, p.lattice, p.radia.By);
%         legend('Orig Field','Tuned field','Ideal'); title('By field');
%         xlim([p.start_tune, p.end_tune]);
%     figure(); plot(p.lattice, Bx_error, p.lattice, By_error); legend('Bx error','By error');
%         legend('Bx error','By error');
%         xlim([p.start_tune, p.end_tune]);

end
