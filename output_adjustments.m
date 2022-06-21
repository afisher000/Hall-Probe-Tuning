function output_adjustments(p, fid, x, Bcomponent)

if strcmp(Bcomponent,'Bz')
    for i=1:length(x)
        if mod(i,2)~=0
            index=round((i+1)/2+p.start_tune-1);
%             fprintf(fid,'Magnet %i-EW (sinc): %i\n',index,round(x(i)));
            fprintf(fid,'Magnet %i-EW: %i\n',index,round(x(i)));
        else
            index=round(i/2+p.start_tune-1);
%             fprintf(fid,'Magnet %i-NS (sine): %i\n',index,round(x(i)));
            fprintf(fid,'Magnet %i-NS: %i\n',index,round(x(i)));
        end
    end    
else
    for i=1:length(x)
        index=i-1+p.start_tune; %magnet position
        if strcmp(Bcomponent,'Bx')
            if mod(index,2)~=0 %odd position
%                 fprintf(fid,'Magnet %i-NS (peaksinc): %i\n',index,round(x(i)));
                fprintf(fid,'Magnet %i-NS: %i\n',index,round(x(i)));
            else %even position
%                 fprintf(fid,'Magnet %i-EW (peaksine): %i\n',index,round(x(i)));
                fprintf(fid,'Magnet %i-EW: %i\n',index,round(x(i)));
            end
        else
            if mod(index,2)~=0 %odd position
%                 fprintf(fid,'Magnet %i-EW (peaksine): %i\n',index,round(x(i)));
                fprintf(fid,'Magnet %i-EW: %i\n',index,round(x(i)));
            else %even position
%                 fprintf(fid,'Magnet %i-NS (peaksinc): %i\n',index,round(x(i)));
                fprintf(fid,'Magnet %i-NS: %i\n',index,round(x(i)));
            end
        end
    end
end