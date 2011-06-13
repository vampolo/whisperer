function [recomList] = onLineRecom_lsa_NNCosine (userProfile, model,param)
%userProfile = vector with ratings of a single user
%model = model created with createModel function 
%param
%param.postProcessingFunction = handle of post-processing function (e.g., business-rules)
    dnorm = model.dnorm;
    if nargin>=3
        if isfield(param,'shrinking')
            shrinking = param.shrinking;
        else
            shrinking = 0;
        end
    else
        shrinking = 0;
    end
    if shrinking>0
        userProj=normalizeShrinkageWordsMatrix(userProfile*dnorm',shrinking,1);
    else
        userProj=normalizeWordsMatrix(userProfile*dnorm',1);
    end
    recomList=userProj*dnorm;
    
    if (nargin>=3)
        if(isfield(param,'postProcessingFunction'))
            recomList=feval(param.postProcessingFunction,recomList,param);
        end
    end
    
end