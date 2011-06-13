function [colnum,itemId,titles] = parseItemTitleDat(filePath,skipfirstline,biasrownum)
%function [colnum,itemId,titles] = parseItemTitleDat(filePath,skipfirstline,biasrownum)

lines=linesCount(filePath);

fid = fopen(filePath);
DELIMITER = '|';

h = waitbar(0,'Please wait...');

if (nargin>1)
    if (skipfirstline)
        fgetl(fid);
    end
end
biasrow = 1;
if (nargin>2)
    biasrow=biasrownum;
end

titles='';
i=1;
colnum=zeros(lines,1);
itemId=zeros(lines,1);
while 1
    fline = fgetl(fid);
    if ~ischar(fline),   break,   end
    splitted_indices = strfind(fline,DELIMITER);
    if (length(splitted_indices)~=2) 
        display('errore');
        i
    end
    colnum(i)= str2num(fline(1:splitted_indices(1)-1))+biasrow;
    itemId(i)= str2num(fline(splitted_indices(1)+1:splitted_indices(2)-1));
    titles = strvcat(titles, fline(splitted_indices(2)+1:end));
    i=i+1;
    if mod(i,10)==0
        waitbar(i/lines,h,num2str(i))
    end
end

fclose(fid);
close(h);

end
