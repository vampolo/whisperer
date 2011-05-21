function wordsMatrix = normalizeWordsMatrix (wordsMatrix,direction)
% wordsMatrix = normalizeWordsMatrix (wordsMatrix,mode)
% mode = 1 -- rows
%           = 2 -- columns

if (exist('direction')==0)
    direction=2;
end

if direction==2
    wNorm = sqrt (sum(wordsMatrix.^2,1));
    wNorm(find(wNorm==0))=1;
    wordsMatrix = wordsMatrix./wNorm(ones(1,size(wordsMatrix,1)),:);
else
    wNorm = sqrt (sum(wordsMatrix.^2,2));
    wNorm(find(wNorm==0))=1;
    wordsMatrix = wordsMatrix./wNorm(:,ones(1,size(wordsMatrix,2)));
end