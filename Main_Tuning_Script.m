%TunePeaks
clearvars;
close all;
clc;

%% Comments
% Optimizing a Radia Field is no longer supported...

% % To Trouble shoot slippage code, can use noise radia field as field.
% noisy_radia     = add_noise(p.radia, 0.01)'; %used to test slippage calculation
% field           = noisy_radia; 


%% Specify Files
% background_file = 'Text Files/FAST - THESEUS1 background (0, -0.025, -0.002).txt'; % Targeting 3.3% over two undulators
background_file = 'Text Files/FAST - Prebuncher background.txt'; %Prebuncher with B0=746mT

% reference_file  = 'Text Files/2022-03-04-11.47.txt'; %With 4 magnet support
% reference_file  = 'Text Files/2022-03-04-12.08.txt'; 
% reference_file  = 'Text Files/2022-03-04-12.24.txt';
% reference_file  = 'Text Files/2022-03-04-12.46.txt';
% reference_file  = 'Text Files/2022-03-04-14.21.txt';
% reference_file  = 'Text Files/2022-03-04-15.14.txt';
% reference_file  = 'Text Files/2022-03-04-15.43.txt';
% reference_file = 'Text Files/2022-03-07-09.17.txt';
% reference_file = 'Text Files/2022-03-08-10.03.txt'; % Inserted Magnet, reset tweezers...
% reference_file = 'Text Files/2022-03-11-12.03.txt'; %


% scan_file       = 'Text Files/2022-03-07-13.28.txt'; %Jason tuned Bx
% scan_file       = 'Text Files/2022-03-07-16.03.txt'; %Jason tuned By (magnet in)
% scan_file       = 'Text Files/2022-03-08-10.03.txt'; % Inserted Magnet, reset tweezers...
% scan_file       = 'Text Files/2022-03-08-14.40.txt'; %Jason Tuned Bz
% scan_file     = 'Text Files/2022-03-09-11.02.txt'; %Andrew Tuned Bz
% scan_file       = 'Text Files/2022-03-09-15.18.txt'; % Andrew Tuned Bxy
% scan_file       = 'Text Files/2022-03-10-12.29.txt'; %Andrew tuned slippage 0-70, Bz 75-end
% scan_file       = 'Text Files/2022-03-10-15.46.txt'; %Andrew tuned trajectory, 0-70
% scan_file       = 'Text Files/2022-03-11-10.14.txt'; %Andrew tuned peaks/trajectory, 0-70
% scan_file       = 'Text Files/2022-03-11-11.32.txt'; %Jason tuned peaks/trajectory 0-70
% scan_file       = 'Text Files/2022-03-11-11.43.txt'; %Check if bend affected scan...
% scan_file       = 'Text Files/2022-03-11-12.03.txt'; %Unchanged full scan
% scan_file       = 'Text Files/2022-03-11-12.52.txt'; % Tuned Trajectory 0-70, but tape slipped during scan
% scan_file       = 'Text Files/2022-03-11-13.16.txt'; % Rescan, still bad

% reference_file  = 'Text Files/2022-04-20-16.10.txt'; %Reference scan
scan_file       = 'Text Files/2022-04-20-16.19.txt'; %Reference scan repeated
% scan_file       = 'Text Files/2022-04-21-14.56.txt'; %Andrew tuned Bxy
% scan_file       = 'Text Files/2022-04-21-17.47.txt'; %Andrew tuned Bxy again
% scan_file       = 'Text Files/2022-04-21-18.40.txt'; %Andrew tuned Bz
scan_file       = 'Text Files/2022-04-22-14.05.txt'; %Andrew tuned slippage
% scan_file       = 'Text Files/2022-04-25-11.17.txt'; %Andrew removed S/W in entrance
% scan_file       = 'Text Files/2022-04-25-11.53.txt'; %Andrew inserted N/W in entrance
% scan_file       = 'Text Files/2022-04-25-12.32.txt'; %Andrew inserted/removed exit magnets
reference_file  = scan_file;
%% Get parameter struct
p               = get_params();

%% Get fields and magnet profiles
raw_meas_field  = get_raw_field(scan_file,0);
raw_ref_field   = get_raw_field(reference_file,0);

p.radia         = get_background(p, background_file, 0);
p.eigen         = get_eigen();
    
%% Get fields on lattice
meas_field              = get_field_on_lattice(p, raw_meas_field);
ref_field               = get_field_on_lattice(p, raw_ref_field);

%% Get corrections from reference offset and twist
[p.dBX, p.dBY, p.dBZ]   = get_offaxis_field_errors(p, ref_field, 1);
p.THETA                 = get_twist(p, ref_field, 1);

%% Check offset/twist of measured field
get_offaxis_field_errors(p, meas_field, 0);
get_twist(p, meas_field, 0); % Confirm no slipping


%% Compute estimate field on axis
field                   = get_on_axis_field(p, meas_field, 0);

%% Fmincon Optimization
opt_tic         = tic;
x0              = zeros(1,p.Nvars);
options         = optimset('TolX', p.tol_x, ...
                            'TolFun', p.tol_fcn, ...
                            'MaxIter', p.max_iters, ...
                            'MaxFunEvals',p.max_fcn_evals, ...
                            'Display','iter');
                        
% Bounds
lb              = -p.x_bounds/1000 * ones(1,p.Nvars); 
ub              = +p.x_bounds/1000 * ones(1,p.Nvars);
lb(1)           = -.01;
ub(1)           = .01;

% Optimize
if p.optimize_tf==1
%     fun = @(x) errorfcn(p, x, field, 0);
    fun = @(x) test_errorfcn(p, x, field, 0);
    [xbest,fval,exitflag,output] = fmincon(fun, x0,[],[],[],[],lb,ub,[],options);
    fprintf('Optimization took %.2f seconds\n',toc(opt_tic));
    save('xbest.mat','xbest');
else
    xbest = x0;
end


%% Run optimized solution (for plots)
% errorfcn(p, xbest, field, 1);
test_errorfcn(p, xbest, field, 1);

%% Plot trajectory
plot_trajectory(p, field);

%% Output adjustments
fprintf('Shift variable: %.5f\n',xbest(1));

% Write annotated tuning adjustments
% Sign is flipped for Bx and Bz, same as when reading in probe fields. 
fid     = fopen( sprintf('Tuning Adjustments/Adjustments %d.txt',p.start_tune), 'w');
if strcmp( p.opt_type, 'Bz')
    output_adjustments(p, fid, -1000*xbest(2:end), 'Bz');
else
    output_adjustments(p, fid, -1000*xbest(2:2+p.Ncrit-1), 'Bx');
    output_adjustments(p, fid, +1000*xbest(end-p.Ncrit+1:end), 'By');
end
fclose(fid);

%% Move guis
move_figures();
