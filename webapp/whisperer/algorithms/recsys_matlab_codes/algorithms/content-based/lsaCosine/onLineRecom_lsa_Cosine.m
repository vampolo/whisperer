function [recomList] = onLineRecom_lsa_Cosine (userProfile, model,param)
%userProfile = vector with ratings of a single user
%model = model created with createModel function 
%param
%param.bias = bias to add to each rating in order to get the predicted
%           rating value. The same bias is subtracted to the userprofile
%           before getting the recommendations.
%param.postProcessingFunction = handle of post-processing function (e.g., business-rules)
   
    bias = 0;
    if (nargin>=3)
        if (isfield(param,'bias'))
            bias = param.bias;
        end
    end
    
    if (bias ~= 0)
        ratedItems = find(userProfile);
        userProfile(ratedItems) = userProfile(ratedItems)-bias;
    end

    dnorm = model.dnorm;
    itemitem=dnorm'*dnorm;
    normVector=sum(itemitem(find(userProfile),:),1);
    recomList=(userProfile*itemitem)./normVector + bias;
    
    if (nargin>=3)
        if(isfield(param,'postProcessingFunction'))
            recomList=feval(param.postProcessingFunction,recomList,param);
        end
    end
    
end