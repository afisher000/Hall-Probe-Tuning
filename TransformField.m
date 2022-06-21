function [THETA,dBX,dBY,dBZ] = TransformField(p, reference)
numcol      = 4;

%% Read in Reference scan (pulling probe from entrance to exit)
fid         = fopen(reference{1}, 'r');
temp        = fscanf(fid,'%f');
fclose(fid);
data        = reshape(temp',numcol,length(temp)/numcol)';
Fref.pos    =flipud(data(:,1)); 
Fref.Bx     = -1*data(:,2); 
Fref.Bz     = -1*data(:,3); 
Fref.By     = data(:,4);

%% Interpolate to finer meshing to ensure accuracy of findpeaks function
posfine     = linspace(Fref.pos(1),Fref.pos(end),10*length(Fref.pos));
Bxfine      = interp1(Fref.pos,Fref.Bx,posfine,'makima',0);
Byfine      = interp1(Fref.pos,Fref.By,posfine,'makima',0);

%% Compute peak positions
[bxpeaks,bxloc]=findpeaks(abs(Bxfine),'MinPeakProminence',0.02);
[bypeaks,byloc]=findpeaks(abs(Byfine),'MinPeakProminence',0.02);
[crit,I]=sort([bxloc,byloc]); critpos=posfine(crit);
peaks=[bxpeaks,bypeaks]; peaks=peaks(I);

%% Interpolate onto lattice
if p.start_crit >= 2
    shiftedpos = (Fref.pos-critpos(1))*4*(p.dstep)/.032+p.start_crit;
else
    shiftedpos = (Fref.pos-critpos(1-p.start_crit+2))*4*(p.dstep)/.032+2;
end
Fref.Bx=interp1(shiftedpos,Fref.Bx,p.lattice,'makima',0);
Fref.By=interp1(shiftedpos,Fref.By,p.lattice,'makima',0);
Fref.Bz=interp1(shiftedpos,Fref.Bz,p.lattice,'makima',0);
Fref.pos = p.lattice; 

% figure(); plot(lattice,F1.Bx,lattice,F1.Bz); legend('Bx','Bz');
% figure(); plot(lattice,F1.By,lattice,F1.Bz); legend('By','Bz');
% figure(); plot(lattice,F1.Bx,lattice,F1.By,lattice,F1.Bz); xlim([-5,20]);

%% Compute dBX,dBY,dBz from reference
ConvertToOnaxisField();
ComputeTwist();
