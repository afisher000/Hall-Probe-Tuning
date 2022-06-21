function eigen = get_eigen()
%% Returns magnetic profiles
%Reads table of pos and fcn from text file, reshapes into matrix, scales
%pos to [-4,4] and normalizes fcn so max(fcn=1). Output is a interpolation
%that is compatible with xvec=linspace(-4,4,801).
xvec    = linspace(-4,4,801);

file    = 'Text Files\8mm NS.txt';
[pos, Bx, Bz]       = read_magnet_profile(file,-8);
eigen.eight_pksinc  = interp1(pos,Bx/max(Bx),xvec,'linear');
eigen.eight_sine    = interp1(pos,-Bz/max(-Bz),xvec,'linear');

file    = 'Text Files\8mm EW.txt';
[pos, Bx, Bz]       = read_magnet_profile(file,0);
eigen.eight_pksine  = interp1(pos,Bx/max(Bx),xvec,'linear');
eigen.eight_sinc    = interp1(pos,Bz/max(Bz),xvec,'linear');

file    = 'Text Files\6mm NS.txt';
[pos, Bx, Bz]       = read_magnet_profile(file,8);
eigen.sixent_pksinc = interp1(pos,-Bx/max(-Bx),xvec,'linear',0);
eigen.sixent_sine   = interp1(pos,Bz/max(Bz),xvec,'linear',0);

file    = 'Text Files\6mm NS.txt';
[pos, Bx, Bz]       = read_magnet_profile(file,6);
eigen.sixexit_pksinc= interp1(pos,-Bx/max(-Bx),xvec,'linear',0);
eigen.sixexit_sine  = interp1(pos,Bz/max(Bz),xvec,'linear',0);

file='Text Files\4mm EW.txt';
[pos, Bx, Bz]       = read_magnet_profile(file,16);
eigen.fourent_pksine= interp1(pos,-Bx/max(-Bx),xvec,'linear',0);
eigen.fourent_sinc  = interp1(pos,-Bz/max(-Bz),xvec,'linear',0);

file='Text Files\4mm EW.txt';
[pos, Bx, Bz]       = read_magnet_profile(file,12);
eigen.fourexit_pksine= interp1(pos,-Bx/max(-Bx),xvec,'linear',0);
eigen.fourexit_sinc = interp1(pos,-Bz/max(-Bz),xvec,'linear',0);

file='Text Files\2mm NS.txt';
[pos, Bx, Bz]   = read_magnet_profile(file,24);
eigen.twoent_pksinc = interp1(pos,Bx/max(Bx),xvec,'linear',0);
eigen.twoent_sine   = interp1(pos,-Bz/max(-Bz),xvec,'linear',0);

file='Text Files\2mm NS.txt';
[pos, Bx, Bz]       = read_magnet_profile(file,18);
eigen.twoexit_pksinc= interp1(pos,Bx/max(Bx),xvec,'linear',0);
eigen.twoexit_sine  = interp1(pos,-Bz/max(-Bz),xvec,'linear',0);


%% Read magnet profile from text file
function [pos, Bx, Bz] = read_magnet_profile(file,z_shift)
    fid     = fopen(file,'r');
    temp    = fscanf(fid,'%f'); 
    fclose(fid);
    temp    = reshape(temp',4,length(temp)/4); 
    pos     = round( (temp(1,:) + z_shift) / 8 ,6); %shift and scale pos
    Bx      = temp(2,:); 
    Bz      = temp(4,:);
end
end
