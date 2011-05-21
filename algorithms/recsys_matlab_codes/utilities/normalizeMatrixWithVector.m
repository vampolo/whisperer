function normMatrix = normalizeMatrixWithVector (originalMatrix,normalizingVector,direction)
% normMatrix = normalizeMatrixWithVector(originalMatrix,normalizingVector,direction)
% normalizingVector = vector containing the normalizing values
% direction = 1 -- rows
%           = 2 -- columns
%
% e.g., icm_idf = normalizeMatrixWithVector(icm,stemOcc,1); 
% being stemOcc = log10(size(icm,2) ./ full(sum(icm,2)));

if (nargin<3)
    direction=2;
end

if size(normalizingVector,direction)~=size(originalMatrix,direction)
    error('incorrect normalizing-vector size');
end

    wNorm = normalizingVector;
    wNorm(find(wNorm==0))=1;
    
    tic
    display(['normalization started']);
    splittingSize=50;
    
    elements=size(originalMatrix,direction);
    numSplittings=elements/splittingSize;
for i=1:ceil(numSplittings)
    beginInterval=splittingSize*(i-1) +1;
    endInterval=splittingSize*(i);
    if (endInterval>elements), endInterval=elements; end
    try
        if direction==2
            normMatrix(:,beginInterval : endInterval) = originalMatrix(:,beginInterval : endInterval)./wNorm(ones(1,size(originalMatrix(:,beginInterval : endInterval),1)),beginInterval : endInterval);
        else
            normMatrix(beginInterval : endInterval,:) = originalMatrix(beginInterval : endInterval,:)./wNorm(beginInterval : endInterval,ones(1,size(originalMatrix(beginInterval : endInterval,:),2)));
        end 
    catch e
       e
       i 
    end

end