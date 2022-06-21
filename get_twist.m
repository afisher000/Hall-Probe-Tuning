function THETA = get_twist(p, ref_field, plot_tf)
    
    %% Twisting error
    [xpeaks,bxloc]  = findpeaks(abs(ref_field.Bx),'MinPeakProminence',0.10);
    [ypeaks,byloc]  = findpeaks(abs(ref_field.By),'MinPeakProminence',0.1);
    [pkloc, I]      = sort([ref_field.pos(bxloc),ref_field.pos(byloc)]);
    peaks           = [xpeaks, ypeaks];
    peaks           = peaks(I);
    pkloc           = pkloc(1+4:end-4); %don't include 4 weak peaks
    peaks           = peaks(1+4:end-4);
    mod_pkloc       = mod(pkloc+.1,1)-.1; 
    int_pkloc       = round(pkloc);

    ptwist          = polyfit(int_pkloc,mod_pkloc,2); %First twist with quadratic

    SHIFT           = interp1( int_pkloc , polyval(ptwist,int_pkloc) , p.lattice , 'makima' , 'extrap' );
%     SHIFT           = SHIFT - SHIFT(401); %assume angle is 0 at entrance... why????

%     fprintf('Total shift = %.2e\n', SHIFT(end) - SHIFT(401) );
    fprintf('Total change in theta = %.1f deg\n', ( SHIFT(end) - SHIFT(401) ) * 360/4 );

    THETA       = SHIFT*(2*pi)/4; %THETA is in radians
    
    if plot_tf
        figure(); plot(int_pkloc,mod_pkloc*360/4);
            hold on; plot(p.lattice,SHIFT*360/4); hold off;
            xlabel('Magnet Number'); ylabel('Probe Twist Angle (deg)');
            ylim([-10,20]);
    end
end