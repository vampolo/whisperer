function [recomList] = onLineRecom_CosNgbr_II (userProfile, model,param)
%userProfile = vector with ratings of a single user
%model = model created with createModel function 
%param
%param.postProcessingFunction = handle of post-processing function (e.g., business-rules)

    drCos = model.drCos;
    normVector=sum(drCos(find(userProfile),:),1);
    normVector(isnan(normVector))=1;
    recomList=(userProfile*drCos)./normVector;
    
    if (nargin>=3)
        if(isfield(param,'postProcessingFunction'))
            recomList=feval(param.postProcessingFunction,recomList,param);
        end
    end
    
    
    
end