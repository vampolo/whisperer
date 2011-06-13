function [matrix] = filterKNN (matrix, knn, diagonal)
% function [matrix] = filterKNN (matrix, knn, [diagonal])
%
% apply a knn filter to 'matrix', i.e., keep the largest 'knn' values 
% for each column. The output is a sparse matrix.
%
% the parameter 'diag' is optional. If 'diag' is true (1) all elements in 
% the main diagonal are set to zero. Default value is TRUE.
% 

if (exist('diagonal')~=1)
    diagonal = true;
end

    if (diagonal)
        for i=1:size(matrix,2) % annullo diagonale
            matrix(i,i)=0;  
        end  
    end
    II = sparse(size(matrix,1),size(matrix,2)); % creo matrice vuota (sparsa)     
    for i=1:size(II,2)
       colItem = matrix(:,i);
       try
            [r c] = sort(colItem,1,'descend');
       catch e
            display(['warning in filterKNN, column ',num2str(i)]);
            % display(e);
            [r c] = sort(full(colItem),1,'descend');
       end
        
       itemToKeep = c(1:knn);
       II(itemToKeep,i) = matrix(itemToKeep,i);
    end
    
    matrix = II; % return

end