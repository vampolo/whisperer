function [] = convertURMtoNFformat (urm, directory)
% convert a generic user rating matrix into the netflix format

    timestamp='2010/01/01';

    if (nargin<2)
        directory = pwd;
    end
    tmpDir = pwd;
    cd(directory);
    
    numItems = size(urm,2);
    numUsers = size(urm,1);
    
    for i=1:numItems
        itemIDstr = num2str(i);
        fileName = 'mv_';
        for j=1:(6-length(itemIDstr))
            fileName = [fileName, '0'];
        end
        fileName = [fileName, itemIDstr,'.txt'];
        fid = fopen(fileName,'w');
        
        itemsCol = full(urm(:,i));
        ratingUsers = find(itemsCol);
%        for j=1:length(ratingUsers)
%            fprintf(fid,'%d,%d,%s\n',ratingUsers(j),urm(ratingUsers(j),i),timestamp);
%        end
        if (length(ratingUsers)>0)
            fprintf(fid,['%d,%d,',timestamp,'\n'],[ratingUsers';itemsCol(ratingUsers)']);
        end
        
        fclose(fid);
    end    
    
    cd(tmpDir);
end