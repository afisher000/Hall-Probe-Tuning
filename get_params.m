function p = get_params()
%% Parameter Struct
p.opt_type      = 'slippage'; %Bxy, Bz, slippage, entrance
p.und_type      = 'prebuncher'; %undulator of prebuncher
p.optimize_tf   = 0; %Run optimization or use current fields

% Constants
p.q             = 1.602e-19;
p.m             = 9.109e-31;
p.c             = 299792458;
p.dstep         = 0.124023438e-6;   %m/step of zaber translation stage

% Resonance/Tapering
p.lambda        = 515e-9;
p.B0            = 0.746;
p.taperdelay    = 0;
p.taper1        = 0;%-0.025;
p.taper2        = 0;%-0.002;
p.gamma         = 220/.511;

% Optimization parameters
p.max_iters     = 60;
p.x_bounds      = 0; %in mT
p.tol_x         = 1e-15;
p.tol_fcn       = 1e-15;
p.max_fcn_evals = 20000;

% Tuning parameters
p.start_crit    = -4; %First critical point of scan, 0 is first full By peak
p.ref_crit      = 2;
p.start_tune    = 1; 
if strcmp(p.und_type, 'prebuncher')
    p.end_tune  = 33;
elseif strcmp(p.und_type, 'undulator')
    p.end_tune  = 108; %check this!
end
p.start_slip    = 2; 
p.end_slip      = p.end_tune-2;     %Define range for computing slippage
        
if strcmp(p.und_type, 'prebuncher')
    p.lattice   = linspace(-8, 41, 4901);
elseif strcmp(p.und_type, 'undulator')
    p.lattice       = linspace(-8,122,13001);
end
p.Ncrit         = p.end_tune-p.start_tune+1;
p.Nvars     = 2*p.Ncrit+1; %two at each magnet and translation variable



%% If tuning entrance, adjust tuning parameters
if strcmp( p.opt_type, 'entrance' )
    p.start_crit    = -4; 
    p.ref_crit      = 2;
    p.start_tune    = 0;
    p.end_tune      = 1;
end
p.Ncrit         = p.end_tune-p.start_tune+1;
p.Nvars     = 2*p.Ncrit+1; %two at each magnet and translation variable



