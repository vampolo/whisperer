function [recomListFiltered] = onlineRatingBias (recomList,param)
% [recomListFiltered] = onlineRatingBias (recomList,param)
% - recomList=vector (length: number of items) with predicted ratings for
% each item
% - param.valueToPreMultiplyFor= ratings are multiplyed for this value
% before any other processing
% - param.valueToAdd= value to add to all ratings
% - param.valueToPostMultiplyFor= ratings are multiplyed for this value
% after any other processing
%
    
if (~isstruct(param))
   error('param must be a struct!'); 
end

if (~isfield(param,'valueToPreMultiplyFor') && ~isfield(param,'valueToAdd') && ~isfield(param,'valueToPostMultiplyFor'))
    error('param misses the required field');
end
if (~isfield(param,'valueToPreMultiplyFor'))
    param.valueToPreMultiplyFor=1;
end
if (~isfield(param,'valueToPostMultiplyFor'))
    param.valueToPostMultiplyFor=1;
end
if (~isfield(param,'valueToAdd'))
    param.valueToAdd=0;
end


recomListFiltered=((recomList*param.valueToPreMultiplyFor)+param.valueToAdd)*param.valueToPostMultiplyFor;

end