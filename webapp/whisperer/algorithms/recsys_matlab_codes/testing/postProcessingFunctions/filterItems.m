function [recomListFiltered] = filterItems (recomList,param)
% [recomListFiltered] = filterItems (recomList,param)
% - recomList=vector (length: number of items) with predicted ratings for
% each item
% - param.itemsToKeep= vector with items that are allowed to be recommended
%
    
if (~isstruct(param))
   error('param must be a struct!'); 
end

if (~isfield(param,'itemsToKeep'))
    error('param misses the required field: itemsToKeep');
end

recomListFiltered=ones(size(recomList))*(-inf);
recomListFiltered(param.itemsToKeep)=recomList(param.itemsToKeep);

end