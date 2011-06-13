function [recomList] = onLineRecom_NNCosNgbr_II (userProfile, model,param)
%userProfile = vector with ratings of a single user
%model = model created with createModel function 
%param
%param.postProcessingFunction = handle of post-processing function (e.g., business-rules)

    drCos = model.drCos;
    recomList=userProfile*drCos;
    
    if (nargin>=3)
        if(isfield(param,'postProcessingFunction'))
            recomList=feval(param.postProcessingFunction,recomList,param);
        end
    end
    
    
    
end