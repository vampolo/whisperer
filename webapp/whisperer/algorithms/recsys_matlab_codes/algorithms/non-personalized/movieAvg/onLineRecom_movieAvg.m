function [recomList] = onLineRecom_movieAvg (userProfile, model,param)
%userProfile = vector with ratings of a single user
%model = model created with createModel function 
%model.movieAvg = average rating of movies (size: 1 x #items)
%param
%param.postProcessingFunction = handle of post-processing function (e.g., business-rules)

    recomList=model.movieAvg;
    
    if (nargin>=3)
        if(isfield(param,'postProcessingFunction'))
            recomList=feval(param.postProcessingFunction,recomList,param);
        end
    end
    
    
    
end