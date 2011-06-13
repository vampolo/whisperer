function [avg,intervalBegin, intervalEnd] = computeConfidenceRecall(results,N,indexesFolds)

for fold=1:length(indexesFolds)
    
    pos = results(indexesFolds(fold).begin:indexesFolds(fold).end);
    
    recall(fold)=computeRecall(pos,N);
    
end

recall=recall(find(recall~=-1));

avg=mean(recall);
stdDev=std(recall);
intervalBegin = avg-2*stdDev;
intervalEnd = avg+2*stdDev;

end