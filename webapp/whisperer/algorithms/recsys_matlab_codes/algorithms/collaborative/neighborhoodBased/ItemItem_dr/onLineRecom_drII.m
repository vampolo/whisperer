function [recomList] = onLineRecom_drII (userProfile, model,param)
%userProfile = vector with ratings of a single user
%model = model created with createModel function 
%param.knn = [optional] k-nearest neighbors
%param.postProcessingFunction = handle of post-processing function (e.g., business-rules)

    dr = model.dr;

    % filtering KNN!
    if (nargin>=3)
        if (isfield(param,'knn'))
            knn=param.knn;
            if (knn<size(dr,2))
                for i=1:size(dr,2), dr(i,i)=0;  end   % annullo diagonale
                II = sparse(size(dr,1),size(dr,2));     % creo matrice vuota (sparsa)
                for i=1:size(II,2)
                   colItem = dr(:,i);
                   [r c] = sort(colItem,1,'descend');
                   itemToKeep = c(1:knn);
                   II(itemToKeep,i) = dr(itemToKeep,i);
                end
                dr = II;
            end
        end
    end
    
    recomList=userProfile*dr;
    
    if (nargin>=3)
        if(isfield(param,'postProcessingFunction'))
            recomList=feval(param.postProcessingFunction,recomList,param);
        end
    end
    
end