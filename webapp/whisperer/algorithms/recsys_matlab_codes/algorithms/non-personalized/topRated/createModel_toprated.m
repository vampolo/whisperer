function [model] = createModel_toprated (URM,ICM,modelParam)
% URM = matrix with user-ratings
    try
        URM=spones(URM);
    catch
        URM=sponesURM(URM);
    end
    topList = sum(URM,1);
    model.topList = topList; %first variable of the model 
    %model.secondVariable = xxx;
end