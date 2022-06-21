function field = get_on_axis_field(p, off_axis_field, plot_tf)
%% Undo twist
tempBx      = off_axis_field.Bx.*cos(p.THETA) - off_axis_field.By.*sin(p.THETA);
tempBy      = off_axis_field.Bx.*sin(p.THETA) + off_axis_field.By.*cos(p.THETA);
tempBz      = off_axis_field.Bz;

%% Move on axis
B0          = smooth( sqrt(tempBx.^2+tempBy.^2) , 400 )';
field.Bx    = tempBx - B0.*p.dBX;
field.By    = tempBy - B0.*p.dBY;
field.Bz    = tempBz - B0.*p.dBZ;

if plot_tf
    legendcell={};
    figure(); hold on;
        plot(p.lattice, field.Bx); legendcell{end+1}='Bx';
        plot(p.lattice, field.By); legendcell{end+1}='By';
        plot(p.lattice, field.Bz); legendcell{end+1}='Bz';
        title('On axis field'); legend(legendcell);
        xlabel('Magnet Number'); ylabel('Field (T)');
end
end