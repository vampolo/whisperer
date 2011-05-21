function [recomListFiltered] = keep1000randomItems (recomList,param)
% [recomListFiltered] = keep1000randomItems (recomList,param)
% - recomList=vector (length: number of items) with predicted ratings for
% each item.
% - param.itemToTest= item being tested. The function keeps 1000 random
% items plus the itemToTest.
%

if (~isstruct(param))
   error('param must be a struct!'); 
end

if (~isfield(param,'itemToTest'))
    error('param misses the required field: itemToTest');
end

param.numberOfItems=1000;
recomListFiltered=keepXrandomItems(recomList,param);

end