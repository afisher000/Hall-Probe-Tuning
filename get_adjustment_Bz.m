function adjustment = get_adjustment_Bz(p, x)
%% Linear combination of eigenfunctions
adjustment  = zeros(1,length(p.lattice));

for magnet = p.start_tune : (p.Ncrit+p.start_tune-1) %i is magnet position
    index       = 2*(magnet - p.start_tune)+1;
    xi          = x(index:index+1); %first magnet is EW (sinc)
    starti      = 1+100*(magnet-p.lattice(1)-4);
    endi        = 1+100*(magnet-p.lattice(1)+4);
    scn         = starti:endi;
    adjustment  = add_eigenfunction(adjustment,scn,xi,magnet,p.eigen);
end

end

function adjustment = add_eigenfunction(adjustment,scn,xi,i,eigen)
    % Switch to return sincfcn and sinefcn
    switch i
        case -1
            sincfcn=eigen.eight_sinc;
            sinefcn=eigen.sixent_sine;
        case -2
            sincfcn=eigen.fourent_sinc;
            sinefcn=eigen.sixent_sine;
        case -3
            sincfcn=eigen.fourent_sinc;
            sinefcn=eigen.twoent_sine;
        case -4
            sincfcn=zeros(1,801);
            sinefcn=eigen.twoent_sine;
        case 115
            sincfcn=eigen.eight_sinc;
            sinefcn=eigen.sixexit_sine;
        case 116
            sincfcn=eigen.fourexit_sinc;
            sinefcn=eigen.sixexit_sine;
        case 117
            sincfcn=eigen.fourexit_sinc;
            sinefcn=eigen.twoexit_sine;
        case 118
            sincfcn=zeros(1,801);
            sinefcn=eigen.twoexit_sine;
        otherwise
            sincfcn=eigen.eight_sinc;
            sinefcn=eigen.eight_sine;
    end
    adjustment(scn)=adjustment(scn)+xi(1)*sincfcn+xi(2)*sinefcn;
end