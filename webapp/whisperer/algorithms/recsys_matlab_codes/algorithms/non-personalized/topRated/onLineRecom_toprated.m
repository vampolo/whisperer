function [recomList] = onLineRecom_toprated (userProfile, model,param)
%userProfile = vector with ratings of a single user
%model = model created with createModel function 
%param
%param.postProcessingFunction = handle of post-processing function (e.g.,business-rules)

    topList = model.topList;
    recomList = topList;
    
    if (nargin>=3)
        if(isfield(param,'postProcessingFunction'))
            recomList=feval(param.postProcessingFunction,recomList,param);
        end
    end
    
end