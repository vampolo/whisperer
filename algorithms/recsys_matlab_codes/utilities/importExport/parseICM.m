function [icm, itemcache, dictionary] = parseICM(icmFile,itemcacheFile,dictionaryFile)
% [icm, itemcache, dictionary]=parseICM [icm, itemcache, dictionary] =
% parseICM(icmFile,itemcacheFile,dizionaryFile)
%
% icm: stem|itemid|count/weight|lang
% itemcache: itemid|rownum
% dictionary: rownum|isSinonim=0|stem|isStem=1|lang|stemType
%
% [icm, itemcache,dictionary]=parseICM('icm.dat','itemcache.dat','dictionary.dat');

DELIMITER = '|';

itemcache = parseItemCacheCSV(itemcacheFile);
[stemRows,isSinonims,stems,isStems,langs,stemTypes] = parseDictionary(dictionaryFile);

stemRows=stemRows-1;

dictionary.stemRows=stemRows;
dictionary.isSinonims=isSinonims;
dictionary.stems=stems;
dictionary.isStems=isStems;
dictionary.langs=langs;
dictionary.stemTypes=stemTypes;


itemscount = length(itemcache);
stemscount = length(stemRows);

h = waitbar(0,'Please wait...');
lines = linesCount(icmFile);
iditem=zeros(lines,1);
stemnum=zeros(lines,1);
weight=zeros(lines,1);
fidICM = fopen(icmFile);
fgetl(fidICM); %skip first line
refTime = tic;
i=1;
while 1
    flineICM = fgetl(fidICM);
    if ~ischar(flineICM),   break,   end
    flineICM = strcat(flineICM, DELIMITER);
    splitted_indices = strfind(flineICM,DELIMITER);
    if (length(splitted_indices)<3) 
        warning(strcat('Wrong number of input elements in the input file: row',i));
        pause;
    end
    stem = flineICM(1:splitted_indices(1)-1);
    stemrow = strmatch(stem,stems,'exact'); 
    if(length(stemrow)>1)
        tmpstemrow = stemrow(1);
        if (length(splitted_indices)>3)
            lang = flineICM(splitted_indices(3)+1:splitted_indices(4)-1);
            for z=1:length(stemrow)
                if (strcmp(langs{stemrow(z)},lang)==1)
                    tmpstemrow = stemrow(z);
                    break;
                end
            end            
        else
            warning('Multiple stems found, but no corresponding language. The first language will be taken.')
        end
        stemrow=tmpstemrow;
    elseif (isempty(stemrow))
        warning('Stem not found in the dictionary');
        pause;
    end
    stemnum(i) = stemRows(stemrow);
    iditem(i) = str2num(flineICM(splitted_indices(1)+1:splitted_indices(2)-1));
    
    weight(i) = str2num(flineICM(splitted_indices(2)+1:splitted_indices(3)-1));
    
    if (iditem(i)~=0) 
        i=i+1;
        %icm(stemnum,itemnum)=weight;
    else
        display(['item ',num2str(iditem(i)),' not found']);
    end
        
    if mod(i,2000)==0
        waitbar(i/lines,h,num2str(i));
        displayRemainingTime(i, lines,refTime);
        break;
    end
end

iditem=iditem(1:i-1);
stemnum=stemnum(1:i-1);
weight=weight(1:i-1);

itemnum = getIndexFromID(itemcache,iditem);
icm=sparse(stemnum,itemnum,weight);
if (size(icm,1)<stemscount || size(icm,2)<itemscount) %resize matrix
    icm(stemscount,itemscount)=0;
end

fclose(fidICM);
close(h);

end