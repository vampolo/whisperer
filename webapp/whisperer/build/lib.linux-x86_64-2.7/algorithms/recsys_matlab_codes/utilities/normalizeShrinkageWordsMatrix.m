function wordsMatrix = normalizeShrinkageWordsMatrix (wordsMatrix,shrinkage, direction)
% wordsMatrix = normalizeShrinkageWordsMatrix (wordsMatrix,shrinkage,direction)
% shrinkage = shrinking constant (default 0)
% direction = 1 -- rows
%           = 2 -- columns

if (exist('direction')==0)
    direction=2;
end
if (exist('shrinkage')==0)
    shrinkage=0;
end

if direction==2
    wNorm = sqrt (sum(wordsMatrix.^2,1));
    wNorm(find(wNorm==0))=1;
    wordsMatrix = wordsMatrix./(wNorm(ones(1,size(wordsMatrix,1)),:)+shrinkage);
else
    wNorm = sqrt (sum(wordsMatrix.^2,2));
    wNorm(find(wNorm==0))=1;
    wordsMatrix = wordsMatrix./(wNorm(:,ones(1,size(wordsMatrix,2)))+shrinkage);
end