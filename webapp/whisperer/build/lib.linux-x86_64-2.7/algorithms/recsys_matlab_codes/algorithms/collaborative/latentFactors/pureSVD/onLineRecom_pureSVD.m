function [recomList] = onLineRecom_pureSVD (userProfile, model,param)
%userProfile = vector with ratings of a single user
%model = model created with createModel function 
%param.ls = [optional] latent size
%param.postProcessingFunction = handle of post-processing function (e.g.,business-rules)

    vt = model.vt;
    if (nargin>=3)
        if (isfield(param,'ls'))
            vt=vt(1:param.ls,:); 
        end
    end
    recomList=userProfile*vt'*vt;
    
    if (nargin>=3)
        if(isfield(param,'postProcessingFunction'))
            recomList=feval(param.postProcessingFunction,recomList,param);
        end
    end
end