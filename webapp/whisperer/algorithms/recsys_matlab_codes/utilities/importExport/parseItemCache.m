function [itemcache,numRow,numCol] = parseItemCache (fileName)

fid = fopen(fileName);
   
fgetl(fid);
fline=fgetl(fid);
tmpLine=str2Num(fline);
numRow=tmpLine(1);
numCol=tmpLine(2);
if (numCol~=2) 
    disp('error');
end
itemcache=zeros(numRow,numCol);
    
i=1;
while 1
    fline = fgetl(fid);
    if ~ischar(fline),   break,   end
    itemcache(ceil(i/2),mod(i,2)+1)= str2num(fline);
    i=i+1;
end
itemcache(:,2)=itemcache(:,2)+1;
itemcache=sortrows(itemcache,2);
fclose(fid);