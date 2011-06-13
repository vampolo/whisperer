function [recomList] = onLineRecom__CosNgbr_II_knn (userProfile, model,param)
%userProfile = vector with ratings of a single user
%model = model created with createModel function 
%param.knn = [optional] k-nearest neighbors
%param.postProcessingFunction = handle of post-processing function (e.g., business-rules)

    dr = model.II;
    
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

    normVector=sum(dr(find(userProfile),:),1);
    normVector(isnan(normVector))=1;
    recomList=(userProfile*dr)./normVector;
    
%{    
    %param.replaceNaN = value replacing NaN in recomList
    if (nargin>=3)
       if(isfield(param,'replaceNaN'))
           recomList(isnan(recomList))=param.replaceNaN;
       end
    end
%}
    
    if (nargin>=3)
        if(strcmp(class(param.postProcessingFunction),'function_handle'))
            recomList=feval(param.postProcessingFunction,recomList,param);
        end
    end
    
end