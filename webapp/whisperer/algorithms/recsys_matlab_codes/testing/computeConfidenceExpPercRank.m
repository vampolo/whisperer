function [avg,intervalBegin, intervalEnd] = computeConfidenceExpPercRank(results,urm,indexesFolds)
%% function [avg,intervalBegin, intervalEnd] =
%% computeConfidenceExpPercRank(results,urm,[indexesFolds])

if (nargin==2)
    for fold=1:length(indexesFolds)
        pos = results(indexesFolds(fold).begin:indexesFolds(fold).end);
        expPercRank(fold)=computeExpPercRank(pos,urm);
    end
elseif (nargin==3)
    expPercRank=computeExpPercRank(results,urm);
    intervalBegin=-1;
    intervalEnd=-1;    
else
    avg=-1;
    intervalBegin=-1;
    intervalEnd=-1;
end

avg=mean(expPercRank);
stdDev=std(expPercRank);
intervalBegin = avg-2*stdDev;
intervalEnd = avg+2*stdDev;

end