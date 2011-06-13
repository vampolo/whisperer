function [urm] = parseURMstatic(filePath, itemcacheFile, usercacheFile)
% function [urmTS] = parseURMstatic(filePath, itemcacheFile, usercacheFile)
%
% parse URM WITHOUT timestamp 
%
% userid|itemid|rating
%

    %lines=linesCount(filePath);
    
    fid = fopen(filePath,'r');
    DELIMITER = '|';

    %urmParsed=zeros(lines-1,3);
    itemcache = parseItemCacheCSV(itemcacheFile);
    usercache = parseItemCacheCSV(usercacheFile);

    fgetl(fid);

    %i=1;
    urmParsed = (fscanf(fid,strcat('%d',DELIMITER,'%d',DELIMITER,'%d'),[3 inf]))';
    
    fclose(fid);
    
    itemnum = getIndexFromID(itemcache,urmParsed(:,2));
    usernum = getIndexFromID(usercache,urmParsed(:,1));
    itemscount = length(itemcache);
    userscount = length(usercache);
    urm = sparse(usernum,itemnum,urmParsed(:,3));
    if (size(urm,2)<itemscount || size(urm,1)<userscount) %resize matrix
        urm(userscount,itemscount)=0;
    end    
end