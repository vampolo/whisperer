function [stemRow,isSinonim,stem,isStem,lang,stemType,dictionary] = parseDictionary(filePath)
%function [stemRow,isSinonim,stem,isStem,lang,stemType,dictionary] = parseDictionary(filePath)
%
% dictionary: rownum|isSinonim=0|stem|isStem=1|lang|stemType

%fid = fopen('D:\Documenti\Other\neptuny\swisscom\LSA2\20081119180423\itemtitle.dat');
lines=linesCount(filePath)-1;
fid = fopen(filePath);
%fgetl(fid); % skip the first line
DELIMITER = '|';
INITIAL_SIZE=lines;

h = waitbar(0,'Please wait...');

i=1;
stemRow=zeros(INITIAL_SIZE,1);
isSinonim=zeros(INITIAL_SIZE,1);
stem=cell(INITIAL_SIZE,1);
isStem=zeros(INITIAL_SIZE,1);
lang=cell(INITIAL_SIZE,1);
stemType=cell(INITIAL_SIZE,1);

dictionary.stem=cell(INITIAL_SIZE,1);
dictionary.lang=cell(INITIAL_SIZE,1);
dictionary.stemType=cell(INITIAL_SIZE,1);

while 1
    fline = fgetl(fid);
    if ~ischar(fline),   break,   end
    fline=strcat(fline, DELIMITER);
    splitted_indices = strfind(fline,DELIMITER);
    if (length(splitted_indices)~=6) 
        display('errore');
        i
    end
    stemRow(i)= str2num(fline(1:splitted_indices(1)-1))+1;
    isSinonim(i)= str2num(fline(splitted_indices(1)+1:splitted_indices(2)-1));
    stem{i} = fline(splitted_indices(2)+1:splitted_indices(3)-1);
    isStem(i) = str2num(fline(splitted_indices(3)+1:splitted_indices(4)-1));
    lang{i} = fline(splitted_indices(4)+1:splitted_indices(5)-1);
    stemType{i} = fline(splitted_indices(5)+1:splitted_indices(6)-1);
    dictionary.stem{stemRow(i)}=stem{i};
    dictionary.stemType{stemRow(i)}=stemType{i};
    dictionary.lang{stemRow(i)}=lang{i};
    i=i+1;
    if mod(i,10000)==0
        waitbar(i/INITIAL_SIZE,h,num2str(i));
        i
    end
end

dictionary.stem=dictionary.stem(1:max(stemRow));
dictionary.stemType=dictionary.stemType(1:max(stemRow));
dictionary.lang=dictionary.lang(1:max(stemRow));

if i<=INITIAL_SIZE
    stemRow=stemRow(1:i-1,1);
    isSinonim=isSinonim(1:i-1,1);
    isStem=isStem(1:i-1,1);
end

fclose(fid);
close(h);

end