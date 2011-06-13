function [URM] = sponesURM(URM)
% URM spones for avoid memory problems
    splitSize = 100;
    numCol = size(URM,2);
    splitNum=ceil(numCol/splitSize);
    for i=1:splitNum
        maxNumOfCols=min([i*splitSize,numCol]);
        colIndexes=splitSize*(i-1)+1:maxNumOfCols;
        URM(:,colIndexes) = spones(URM(:,colIndexes));
    end
end