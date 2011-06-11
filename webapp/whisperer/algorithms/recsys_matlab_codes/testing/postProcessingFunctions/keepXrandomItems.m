function [recomListFiltered] = keepXrandomItems (recomList,param)
% [recomListFiltered] = keepXrandomItems (recomList,param)
% - recomList=vector (length: number of items) with predicted ratings for
% each item.
% - param.itemToTest = item being tested. The function keeps X random
% items plus the itemToTest.
% - param.numberOfItems = the number X of items for creating the
% recommendation list
% - [param.filterViewedItems] = optional parameter which enables the use of
% the next following (param.viewedItems)
% - [param.viewedItems] = optional parameter which lists the number of
% items belonging to the user profile. If the parameter is given 
% (and the optinal param.filterViewedItems is true) the X-random items 
% are selected from the set {allItems \ viewedItems}, instead of from the
% set of allItems.
%
    
if (~isstruct(param))
   error('param must be a struct!'); 
end

if (~isfield(param,'itemToTest'))
    error('param misses the required field: itemToTest');
end

if (~isfield(param,'numberOfItems'))
    error('param misses the required field: numberOfItems');
end

itemSet = [1:param.itemToTest-1, param.itemToTest+1:length(recomList)];

if (isfield(param,'filterViewedItems') && (param.filterViewedItems))
    if (isfield(param,'viewedItems'))
        itemSet=setdiff(itemSet,param.viewedItems);
    else
        warning('param misses the required field: filterViewedItems');
    end
end

recomListFiltered=ones(size(recomList))*(-inf);
try
    itemsToKeep=[param.itemToTest, randsample(itemSet, param.numberOfItems)];
    recomListFiltered(itemsToKeep)=recomList(itemsToKeep);
catch e
    display e;
end

end