function [model] = createModel_movieAvg (URM,param)
% URM = matrix with user-ratings
%
% output: model.movieAvg

    thandle=tic;
    items=size(URM,2);
    average=zeros(1,items);
    for i=1:items
        nonZerosValues = nonzeros(URM(:,i));
        average(i) = mean(nonZerosValues);
        if (mod(i,100)==0)
            thandle=displayRemainingTime(i, items,thandle);           
        end
    end
    
    model.movieAvg = average; 
end