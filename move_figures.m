function move_figures()
    %% Move guis
    locations = {'northwest','north','northeast','southwest','south','southeast'};
    for j=1:10
        if ~ishandle(j)
            break;
        end
        idx     = mod(j-1, length(locations)) + 1;
        figure(j); movegui( locations{idx} );

    end
end