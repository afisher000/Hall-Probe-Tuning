function field = get_raw_field(file, plot_tf)
    fid         = fopen(file,'r');
    temp        = fscanf(fid,'%f');
    fclose(fid);
    
    numcol      = 4;
    data        = reshape(temp',numcol,length(temp)/numcol)';
    field.pos   = flipud(data(:,1)); 
    field.Bx    = -1*data(:,2); 
    field.Bz    = -1*data(:,3); 
    field.By    = data(:,4); 
    
    if plot_tf
        legendcell={};
        figure(); hold on;
%             plot(field.pos, field.Bx); legendcell{end+1}='Bx';
%             plot(field.pos, field.By); legendcell{end+1}='By';
            plot(field.pos, field.Bz); legendcell{end+1}='Bz';
%             title(file); legend(legendcell);
            xlabel('Zaber Steps'); ylabel('Field (T)');
    end
end