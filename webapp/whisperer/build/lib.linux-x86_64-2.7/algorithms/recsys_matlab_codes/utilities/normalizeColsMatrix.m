function [URM] = normalizeColsMatrix (URM)
    tic
    display(['normalization started']);
    splittingSize=50;
    
    items=size(URM,2);
    numSplittings=items/splittingSize;
    
    for i=1:ceil(numSplittings)
        beginInterval=splittingSize*(i-1) +1;
        endInterval=splittingSize*(i);
        if (endInterval>items), endInterval=items; end
        URM(:,beginInterval : endInterval)= normalizeWordsMatrix(URM(:,beginInterval : endInterval),2);
    end
    display(['normalization completed in ',num2str(toc),' sec']);
end