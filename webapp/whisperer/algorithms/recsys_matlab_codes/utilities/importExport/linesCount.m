function [lines] = linesCount (filename)
% function [lines] = linesCount (filename)
%
% counts the number of lines in a text file
% e.g., lines = linesCount
% ('ydata-ymovies-user-movie-ratings-train-v1_0.txt');

    fid = fopen(filename,'r');
    
    [status, lines] = system(['type ',filename,' | find "~`!@#$%^&*()_+" /V /C']);
    
    if (status~=0)
        lines = -1; 
    else
        lines = str2num(lines);
    end

    if (status~=0) 
        [status, lines] = system(['cat ',filename,' | wc -l']);
        if (status~=0)
            lines = -1; 
        else
            lines = str2num(lines);
        end
    end
        
    fclose (fid);
end