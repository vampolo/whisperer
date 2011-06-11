function [C,E] = pearsonCoeff (A,B,mode)
%    [C, [E]] = pearsonCoeff (A,B), computes Corr(A,B), where A and B must be sparse.
%    [C, [E]] = pearsonCoeff (A,B,mode) computes Corr(A,b). If mode=0, the column average is calculated on common elements, otherwise column average is calculated on all non-zeros elements (DEFAULT)
%        E is a matrix contaninng the number of common elements

error ('cs_transpose mexFunction not found') ;


