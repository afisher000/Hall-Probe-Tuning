function error = errorfcn(p, x, field, plot_tf)
if strcmp(p.opt_field,'Bz')
    error = errorfcn_Bz(p, x, field, plot_tf);
else
    error = errorfcn_Bxy(p, x, field, plot_tf);
end