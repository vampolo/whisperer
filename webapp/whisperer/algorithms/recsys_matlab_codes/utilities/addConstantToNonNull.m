function [matrix] = addConstantToNonNull (matrix,constantToAdd)
% function [matrix] = addConstantToNonNull (matrix,constantToAdd)
% add a constant value to all non-null value of a given matrix
    
    [a,b,c] = find(matrix);
    
    c=c+constantToAdd;
    matrix=sparse(a,b,c);
end