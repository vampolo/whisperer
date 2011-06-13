function [stems] = displayStems (vectorOfStemWeight,dictionary_stem,dictionary_stemRow, weightThreshold)
% function [stems] = displayStems
% (vectorOfStemWeight,dictionary_stem,dictionary_stemRow)

[iValues,jIndexes]=sort(-vectorOfStemWeight); iValues=-iValues;

if nargin==4
    if weightThreshold<=1
        stemIDs=find(abs(iValues)>weightThreshold);
    else
        stemIDs=find(iValues);
        stemIDs=stemIDs(1:weightThreshold);
    end
else
    stemIDs=jIndexes(find(iValues));
end

stems ='';
for myStem=1:length(stemIDs),
    stem = dictionary_stem((find(dictionary_stemRow==jIndexes(stemIDs(myStem)))),:);
    stems=strvcat(stems,stem);
    display([stem(1,:), ' | ',num2str((iValues(stemIDs(myStem)))),' ']);
end
end