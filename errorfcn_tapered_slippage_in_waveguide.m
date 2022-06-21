function output = errorfcn_tapered_slippage_in_waveguide(p, field, plot_tf)
%% Slippage calculation needs to be checked!!!!


%% Field is truncated to 0.5 magnets before and after slippage tuning range.


%% Find peaks
[~,bxloc]       = findpeaks(abs(field.Bx),'MinPeakProminence',0.05);
[~,byloc]       = findpeaks(abs(field.By),'MinPeakProminence',0.05);
crit            = sort([bxloc;byloc]); 
crit_pos         = field.pos(crit);

if plot_tf
    figure(); hold on;
        plot(field.pos,field.Bx);
        plot(pos,By); 
        scatter(crit_pos,peaks,'rX'); 
        hold off;
end

%% Truncate again
scn             = logical( (field.pos>=crit_pos(1) ) .* (field.pos<=crit_pos(end)) );
field.pos       = field.pos(scn); 
field.pos       = (field.pos-field.pos(1))' * .032/4;
field.Bx        = field.Bx(scn)';
field.By        = field.By(scn)';

%% Parameters (MAKE SURE THEY ARE DESIGN PARAMETERS)
% Could be wrapped into p struct in Main_Tuning_Script so not hidden...
lamu            = .032;
ku              = 2*pi/lamu;

lamr            = 714.37e-6;
kz              = 2*pi/lamr;
K0              = p.q*p.B0/p.m/p.c/ku;
betaz           = .9890;
f               = 4.2496e11;
omega           = 2*pi*f;



%% Define ideals and tapering
OffAxis         = 1.0; % increase in effective K due to Bz effects
taperdelay      = taperdelay-0.016; %pos=0 at magnet 2
scn1            = pos<taperdelay;
scn2            = pos>=taperdelay;
Bideal          = zeros(1,length(pos));
Bideal(scn1)    = B0;
Bideal(scn2)    = B0*(1 + (pos(scn2)-taperdelay)*taper1 + (pos(scn2)-taperdelay).^2*taper2);
Kideal          = q*Bideal/m/c/ku;
Keff            = Kideal*OffAxis; 
Gideal          = sqrt(1+Keff.^2)/sqrt(1-betaz^2); %betaz is constant,  check this matches initial gamma
B2ideal         = Bideal.^2;


% figure(); plot(pos,Bideal); hold on; plot(pos,-Bideal); plot(pos,Bx); plot(pos,By); hold off; legend('+Bideal','-Bideal','Bx Measured','By Measured');

% Get xp0 and yp0 at the starting magnet
gamma0          = 16.5362; % Nominal energy (E=8.45MeV)
xp0             = -0.084 * K0*OffAxis/gamma0;
yp0             = -1.015 * K0*OffAxis/gamma0;
x0              = -0.85 * K0*OffAxis/gamma0 / ku;
y0              = +0.00 * K0*OffAxis/gamma0 / ku;

xp              = -q/m/c * cumtrapz(pos,By./Gideal*OffAxis) + xp0;
yp              = +q/m/c * cumtrapz(pos,Bx./Gideal*OffAxis) + yp0;
x               = cumtrapz(pos,xp) + x0;
y               = cumtrapz(pos,yp) + y0;
B2              = Bx.^2 + By.^2;


if plot_tf
%     figure(); subplot(1,2,1); plot(pos,Bx); hold on; plot(pos,By); plot(pos,B0*ones(1,length(pos))); hold off; ylim([.95,1.05]*B0);
%     subplot(1,2,2); plot(pos,Bx); hold on; plot(pos,By); plot(pos,-B0*ones(1,length(pos))); hold off; ylim([1.05,.95]*-B0); 
    
%     figure(); plot(pos,xp); hold on; plot(pos,yp); plot(pos,Keff./Gideal); plot(pos,-Keff./Gideal); hold off; legend('xp','yp','K/gamma','-K/gamma');    

figure(); plot(pos*4/.032+2,B2./B2ideal); title('Plot of B2');
    hold on; plot(pos*4/.032+2,movmean(B2./B2ideal,400));
end

% Compute slippage
delta       = omega/c/kz-1; %extra slippage due to vp>c
S           = 0.5 * cumtrapz(pos,1./Gideal.^2 + 2*delta + xp.^2+yp.^2);
Sideal      = 0.5 * cumtrapz(pos,1./Gideal.^2 + 2*delta + Keff.^2./Gideal.^2);



slip_error  = S-Sideal;

%% ONLY FOR TESSA FIGURE
p = polyfit(1:length(slip_error),slip_error,1);
slip_error = slip_error-polyval(p,1:length(slip_error));
%

slip_error  = slip_error-mean(slip_error); %subtract mean, no reason for S=0 at pos(1)
posres      = pos(2)-pos(1); 
window      = round(lamu/posres);
numperiods  = floor((pos(end)-pos(1))/lamu);
peak_ind    = round((1:numperiods*4)*lamu/4/posres); %indices for peaks

% Average the errors
averaged_slip_error     = movmean(slip_error,[0,window]);
rel_averaged_slip_error = averaged_slip_error(1:end-window)/lamr;
rad_lam                 = S(1+window:end)-S(1:end-window);
averaged_rad_lam        = movmean(rad_lam,[0,window]);
xmean                   = movmean(x,[0,window]);
ymean                   = movmean(y,[0,window]);
    
if plot_tf
%     figure(); scatter([0,pos(peak_ind)'],[xp0,xp(peak_ind)],'rX'); hold on; plot([0,pos(peak_ind)'],[yp0,yp(peak_ind)],'bX'); hold off; title('Slopes at peaks'); legend('xp','yp'); xlabel('Dist. (m)');
    figure(); movegui('north'); subplot(1,2,1); plot(2+pos*4/.032,slip_error); hold on; plot(2+pos(1:end-window)*4/.032,averaged_slip_error(1:end-window)); legend('Slippage Error','Averaged Slippage Error'); title('Slippage Errors');
    subplot(1,2,2); plot(2+pos(1:end-window)*4/.032,rel_averaged_slip_error);  xlabel('Magnet Number');
    P = polyfit(2+pos(1:end-window)*4/.032 , rel_averaged_slip_error , 1); title('Rel. Avg. Slip. Error');
    hold on; plot(2+pos(1:end-window)*4/.032, rel_averaged_slip_error - polyval(P,2+pos(1:end-window)*4/.032)); legend('Raw','Subtract linear fit');
    
    figure(); movegui('northwest'); plot(pos(1:end-window), rad_lam ); ylabel('Radiated Wavelength (m)'); xlabel('Dist. (m)');
    hold on; plot(pos(1:end-2*window), averaged_rad_lam(1:end-window)); legend('Instant','Averaged');

    figure(); movegui('northeast'); plot(pos*4/.032+2 , x , pos*4/.032+2 , y); legend('x','y'); title('Beam Trajectory (position)');
    hold on; plot(pos(1:end-window)*4/.032+2 , xmean(1:end-window) , pos(1:end-window)*4/.032+2 , ymean(1:end-window) ); ylabel(num2str(xmean(end-window)*1000));

%     figure(); plot(pos*4/.032+2,xp,pos*4/.032+2,yp); legend('xp','yp');

    %% TESSA Figure
    figure(); movegui('southwest'); subplot(1,2,1); plot(2+pos*4/.032,slip_error*1e6); hold on; plot(2+pos(1:end-window)*4/.032,averaged_slip_error(1:end-window)*1e6); legend('Unaveraged','Period Averaged'); title('Slippage Error');
    xlabel('Magnet Number'); ylabel('Error (\mu m)');
    subplot(1,2,2); plot(2+pos(1:end-window)*4/.032,rel_averaged_slip_error);  xlabel('Magnet Number'); ylabel('Normalized Error');
    P = polyfit(2+pos(1:end-window)*4/.032 , rel_averaged_slip_error , 1); title('Relative Period-Averaged Error');
    
end
    


tapered_K   = -q*sqrt(Bx.^2+By.^2)/(m*c*ku);
averaged_K  = movmean(tapered_K,[0,window]);
scn         = 1:length(tapered_K)-window;
if plot_tf
    % Comparing tapered K
%     figure(1); subplot(2,2,3); plot(pos,tapered_K); hold on; plot(pos,K); plot(pos(scn),averaged_K(scn));  hold off; title('Checking K Parameter'); xlabel('Dist. (m)'); legend('Measured','Ideal','Averaged');
%     subplot(2,2,4); plot(pos(scn),(averaged_K'-K(scn))./K(scn)); title('Relative Error in K');  xlabel('Dist. (m)');
end

% Fit error to cosine error to check slippage tolerance
P       = 2; %total oscillations
N       = length(rel_averaged_slip_error);
thresh  = 0.001e-3;

seterror= thresh * sin(2*pi * (1:N)*P/N ); %sine shape
% seterror= -thresh + (1:N)/N * 2*thresh; %ramp shape

diffa   = 1  * sum( abs(rel_averaged_slip_error-seterror) );
diffb   = 80 * sum( abs(xmean(1:end-window)) + abs(ymean(1:end-window)) );
diff    = diffa + diffb;

output  = sqrt(diff*diff'/length(diff));


if plot_tf
    output={pos(scn),rel_averaged_slip_error,tapered_K(scn),averaged_K(scn)};
end

fclose('all');

end