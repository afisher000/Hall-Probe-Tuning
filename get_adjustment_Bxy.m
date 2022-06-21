function adjustment = get_adjustment_Bxy(p, x, Bcomponent)
%% Parse length x if p.opt_field=='Bxy'
if length(x)~=p.Ncrit 
    if strcmp(Bcomponent,'Bx')
        x   = x(1:p.Ncrit);
    elseif strcmp(Bcomponent,'By')
        x   = x(end-p.Ncrit+1:end);
    end
end



%% Linear combination of eigenfunctions
adjustment  = zeros(1,length(p.lattice));
for magnet = p.start_tune : (p.Ncrit+p.start_tune-1) %i is magnet position
    xi          = x(magnet-p.start_tune+1);
    starti      = 1+100*(magnet-p.lattice(1)-4);
    endi        = 1+100*(magnet-p.lattice(1)+4);
    scn         = starti:endi;
    adjustment  = add_eigenfunction(adjustment,scn,xi,magnet,p.eigen,Bcomponent);
end

end


function adjustment = add_eigenfunction(adjustment,scn,xi,magnet,eigen,Bcomponent)
    % Switch to return xfcn and yfcn
    switch magnet
        case -1
            xfcn    = eigen.sixent_pksinc;
            yfcn    = eigen.eight_pksine;
        case -2
            xfcn    = eigen.fourent_pksine;
            yfcn    = eigen.sixent_pksinc;
        case -3
            xfcn    = eigen.twoent_pksinc;
            yfcn    = eigen.fourent_pksine;
        case -4
            xfcn    = zeros(1,801);
            yfcn    = eigen.twoent_pksinc;
        case 115
            xfcn    = eigen.eight_pksine;
            yfcn    = eigen.sixexit_pksinc;
        case 116
            xfcn    = eigen.sixexit_pksinc;
            yfcn    = eigen.fourexit_pksine;
        case 117
            xfcn    = eigen.fourexit_pksine;
            yfcn    = eigen.twoexit_pksinc;
        case 118
            xfcn    = eigen.twoexit_pksinc;
            yfcn    = zeros(1,801);
        otherwise
            if mod(magnet,2)==1 %odd magnet position
               xfcn     = eigen.eight_pksinc;
               yfcn     = eigen.eight_pksine;
            else %even magnet position
                xfcn    = eigen.eight_pksine;
                yfcn    = eigen.eight_pksinc;
            end
    end
    
    if strcmp(Bcomponent,'Bx')
        adjustment(scn)=adjustment(scn)+xi*xfcn;
    else
        adjustment(scn)=adjustment(scn)+xi*yfcn;
    end
end