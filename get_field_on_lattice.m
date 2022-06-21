function field = get_field_on_lattice(p, raw_field)
%% Use finer resolution of field
fine.pos        = linspace(raw_field.pos(1), raw_field.pos(end), length(raw_field.pos)*10);
fine.Bx         = interp1(raw_field.pos, raw_field.Bx, fine.pos, 'makima',0);
fine.By         = interp1(raw_field.pos, raw_field.By, fine.pos, 'makima',0);

% figure(); plot(fine.pos, fine.Bx); hold on; plot(raw_field.pos, raw_field.Bx,'rx');
%     legend('Interpolation','Raw Data');

%% Find the critical positions (peaks of the field)
[xpeaks,bxloc]  = findpeaks(abs(fine.Bx),'MinPeakProminence',0.05);
[ypeaks,byloc]  = findpeaks(abs(fine.By),'MinPeakProminence',0.05);
pklocs          = [bxloc, byloc];
peaks           = [xpeaks, ypeaks];
[sorted_pklocs, I]  = sort(pklocs);
sorted_peaks    = peaks(I);
crit_pos        = fine.pos(sorted_pklocs);

% figure(); hold on;
%     plot(fine.pos, fine.Bx, fine.pos, fine.By);
%     plot(crit_pos, peaks,'x');


%% Shift so peak is on lattice integers
if p.start_crit>=2
    shifted_pos = (raw_field.pos - crit_pos(1)) * (4*p.dstep/.032) + p.start_crit;
else
    shifted_pos = (raw_field.pos - crit_pos(1-p.start_crit+2)) * (4*p.dstep/.032) + 2;
end

%% Interpolate onto the lattice
field.pos       = p.lattice;
field.Bx        = interp1(shifted_pos, raw_field.Bx, p.lattice, 'makima',0);
field.By        = interp1(shifted_pos, raw_field.By, p.lattice, 'makima',0);
field.Bz        = interp1(shifted_pos, raw_field.Bz, p.lattice, 'makima',0);

end