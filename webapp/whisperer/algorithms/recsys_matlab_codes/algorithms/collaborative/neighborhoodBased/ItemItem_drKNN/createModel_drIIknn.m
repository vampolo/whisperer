function [model] = createModel (URM,param)
% URM = matrix with user-ratings

    if (exist('param')==0)
        drCos=full(URM'*URM);
        knn=size(URM,2);
    else
        if (isfield(param,'drCos'))
            drCos = full(param.drCos);
        else 
            drCos=full(URM'*URM);
        end
        if (isfield(param,'knn'))
            knn = param.knn;
        else 
            knn=size(URM,2);
        end
    end
    
 %% KNN  
    if (knn<size(drCos,2))
        for i=1:size(drCos,2), drCos(i,i)=0;  end   % annullo diagonale
        II = sparse(size(drCos,1),size(drCos,2));     % creo matrice vuota (sparsa)
        for i=1:size(II,2)
           colItem = drCos(:,i);
           [r c] = sort(colItem,'descend');
           itemToKeep = c(1:knn);
           II(itemToKeep,i) = drCos(itemToKeep,i);
        end
    else
        II=drCos;
    end
    model.II = II; 
end