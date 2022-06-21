function radia = get_background(p, file, plot_tf)
%% Gets RADIA background from file
%Reads table of pos and fields from RADIA, reshapes into matrix, divide by 
%8 so each period is length 4. Interpolate so each fields are compatible
%with lattice spacing.

%% Read in fields and interpolate to lattice
fid     = fopen(file,'r');
temp    = fscanf(fid,'%f'); 
fclose(fid);
temp    = reshape(temp',4,length(temp)/4); 
pos     = round((temp(1,:))/8,6); 
Bx      = temp(2,:); 
By      = temp(3,:); 
Bz      = temp(4,:);

lattice     = p.lattice;
radia.Bx    = interp1(pos,Bx,lattice,'makima',0);
radia.By    = interp1(pos,By,lattice,'makima',0);
radia.Bz    = interp1(pos,Bz,lattice,'makima',0);
radia.pos   = lattice;

if plot_tf
    figure(); hold on;
        plot(radia.pos,radia.Bx);  
        plot(radia.pos,radia.By); 
        plot(radia.pos,radia.Bz); 
        hold off;
        title(file); legend('Bx','By','Bz');
        xlabel('Magnet Number'); ylabel('Field (T)'); 
end

