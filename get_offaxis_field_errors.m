function [dBX, dBY, dBZ] = get_offaxis_field_errors(p, ref_field, plot_tf)
    %% Compute offset from inner products (independent of twist angle)    
    scn     = logical( (p.lattice>p.start_tune) .* (p.lattice<p.end_tune) );
    B0      = mean( sqrt(ref_field.Bx(scn).^2 + ref_field.By(scn).^2) ); 
    ku      = 2*pi/.032;
    if strcmp(p.und_type, 'undulator')
        vec     = linspace(2,108,1000);
    elseif strcmp(p.und_type, 'prebuncher')
        vec     = linspace(2, 31, 1000);
    end
    
    for j=1:length(vec)
        [~,index]   = min(abs(p.lattice-vec(j)));
        scn         = index:index+199; %integrate half a period
        aconst = trapz( p.lattice(scn), ref_field.Bz(scn).* (-1*sin(pi*p.lattice(scn)/2)) );
        bconst = trapz( p.lattice(scn), ref_field.Bz(scn).* (+1*cos(pi*p.lattice(scn)/2)) );

        yoffset(j) =  aconst / (ku*B0) * 1e6; %in um
        xoffset(j) = -bconst / (ku*B0) * 1e6; %in um
        zoffset(j) = p.lattice(index+100);

    end

    %% Polyfit the offsets, transfrom to on-axis fields (subtract dBx,dBy,dBz)
    porder      = 5; %shift zoffset to center poly for better results
    pxoffset    = polyfit(zoffset-zoffset(end)/2,xoffset,porder); 
    pyoffset    = polyfit(zoffset-zoffset(end)/2,yoffset,porder);
    xfit        = polyval(pxoffset,zoffset-zoffset(end)/2);
    yfit        = polyval(pyoffset,zoffset-zoffset(end)/2);
    
    X       = interp1(zoffset,xfit,p.lattice,'linear','extrap')*1e-6; %in meters
    Y       = interp1(zoffset,yfit,p.lattice,'linear','extrap')*1e-6; %in meters
    Z       = p.lattice;

    %% Take offaxis expansion and subtract off field
    alpha   = 1.5337;
    beta    = sqrt(alpha^2-1);
    kuz     = 2*pi/4; %for period 4 (since Z has been scaled)
    dBX 	= +cosh(alpha*ku*X) .* cos(beta*ku*Y) .* (-sin(kuz*Z)) - beta / alpha * sin(beta*ku*X) .* sinh(alpha*ku*Y) .* (cos(kuz*Z))    - (-sin(kuz*Z)); 
    dBY 	= -beta / alpha * sin(beta*ku*Y) .* sinh(alpha*ku*X) .* (-sin(kuz*Z)) + cos(beta*ku*X) .* cosh(alpha*ku*Y) .* (cos(kuz*Z))    - (cos(kuz*Z));
    dBZ 	= -1/ alpha * cos(beta*ku*Y) .* sinh(alpha*ku*X) .* (cos(kuz*Z)) + 1 / alpha * cos(beta*ku*X) .* sinh(alpha*ku*Y) .* (-sin(kuz*Z));

    if plot_tf
        figure(); 
            plot(zoffset,xoffset,Z,X*1e6,zoffset,yoffset,Z,Y*1e6); 
            legend('X offset','X fit','Y offset','Yfit'); 
            title([num2str(porder),' degree poly fits']); 
            ylabel('Microns'); xlabel('Magnet Number');
            xlim([min(zoffset), max(zoffset)]);
    end
end
