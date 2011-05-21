function [recomList] = onLineRecom_pearsonIIkoren (userProfile, model,param)
%userProfile = vector with ratings of a single user
%model = model created with createModel function 
%model  .dr
%       .mu
%       .bi
%       .lambdaU -->  shrinking factor per media user b_{u}
%param.knn = [optional] k-nearest neighbors>
%param.postProcessingFunction = handle of post-processing function (e.g., business-rules)

    try
        dr = model.dr;
        mu = model.mu;
        bi = model.bi;
        lambdaU = model.lambdaU;            
        if (isfield(model,'knn'))
            knnModel=model.knn;
        else
            knnModel=inf;
        end
    catch e
        error(' -- onLineRecom_pearsonIIkoren: missing fields in the model!');
    end
    
    ratedItems = find(userProfile);
    userProfileNormalized = full(userProfile);
    userProfileNormalized(ratedItems) = userProfileNormalized(ratedItems) -mu - bi(ratedItems);
    bu_currentUser = sum(userProfileNormalized) / (lambdaU + length(ratedItems));
    userProfileNormalized(ratedItems) = userProfileNormalized(ratedItems) - bu_currentUser;
    
    % filtering KNN!
    if (nargin>=3)
        if (isfield(param,'knn'))
            knn=param.knn;
            if (knn<size(dr,2) && knn<knnModel)
                dr = filterKnn(matrix,knn);
            end
        end
    end
    
    normVector = sum(dr(ratedItems,:),1);
    normVector(isnan(normVector)) = 1;
    recomList = ((mu + bu_currentUser) + bi) + ((userProfileNormalized*dr) ./ normVector);
    
    if (nargin>=3)
        if(strcmp(class(param.postProcessingFunction),'function_handle'))
            recomList=feval(param.postProcessingFunction,recomList,param);
        end
    end
    
end