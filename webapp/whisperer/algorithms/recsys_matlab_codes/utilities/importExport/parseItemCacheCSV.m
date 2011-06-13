function [itemcache] = parseItemCacheCSV (fileName)
% function [itemcache] = parseItemCacheCSV (fileName)
%
% itemcache: itemid|rownum

fid = fopen(fileName);
   
fgetl(fid); %removes first line    
itemcache = (fscanf(fid,'%d|%d',[2 inf]))';
fclose(fid);