function [recomList] = onLineRecom (userProfile, model,param)
%userProfile = vector with ratings of a single user
%model = model created with createModel function 
    II = model.II;
    recomList=userProfile*II;
    
    if (nargin>=3)
        if(isfield(param,'postProcessingFunction'))
            recomList=feval(param.postProcessingFunction,recomList,param);
        end
    end
    
end