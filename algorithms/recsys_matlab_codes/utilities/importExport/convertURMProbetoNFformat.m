function [] = convertURMProbetoNFformat (urmProbe, directory)
% convert a generic user rating matrix PROBE into the PROBE netflix format

    fileName = 'probe.txt';

    if (nargin<2)
        directory = pwd;
    end
    tmpDir = pwd;
    cd(directory);
    
    numItems = size(urmProbe,2);
    
    fid = fopen(fileName,'w');
    for i=1:numItems        
        itemsCol = full(urmProbe(:,i));
        ratingUsers = find(itemsCol);
        if length(ratingUsers)<1
            continue;
        end
        fprintf(fid,'%d:',i);
        fprintf(fid,'\n%d',ratingUsers);
        fprintf(fid,'\n');
    end    
    fclose(fid);
    cd(tmpDir);
end