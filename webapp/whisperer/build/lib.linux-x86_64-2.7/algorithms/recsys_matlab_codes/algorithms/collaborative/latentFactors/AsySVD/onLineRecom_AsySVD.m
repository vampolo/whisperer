function [recomList] = onLineRecom_AsySVD (userProfile, model,param)
%userProfile = vector with ratings of a single user
%model = model created with createModel function 
% model:    model.mu --> average rating
%           model.bu --> vector of the average rating for each user
%           model.bi --> vector of the average rating for each item
%           model.q 
%           model.x
%           model.y
%param.postProcessingFunction = handle of post-processing function (e.g., business-rules)
%param.userToTest

    try
        mu=model.mu;
        bu=model.bu;
        bi=model.bi;
        bu_precomputed=model.bu_precomputed;
        bi_precomputed=model.bi_precomputed;
        x=model.x;
        y=model.y;
        q=model.q;
        ls=size(x,1);
        user=param.userToTest;
    catch e
        display e
        error ('missing some model field');
    end        
    pu=zeros(ls,1);
    ratedItems = find(userProfile);
    numRatedItems = length(ratedItems);
    if (numRatedItems==0) 
       warning('empty user profile!');
    end        
    for i=1:numRatedItems
        item=ratedItems(i);
        pu = pu +  (userProfile(item) - (mu+bu_precomputed(user)+bi_precomputed(item)))*x(:,item);
        pu = pu +  y(:,item);
    end
    pu = pu / sqrt(numRatedItems);   
    
    recomList = mu + bu(user) + bi + q'*pu; %r_hat_ui = mu + bu(u) + bi(item) + q(:,item)'*pu; 
        

    
    %if (nargin>=3)
    if(isfield(param,'postProcessingFunction'))
        if(strcmp(class(param.postProcessingFunction),'function_handle'))
            recomList=feval(param.postProcessingFunction,recomList,param);
        end
    end
    
end