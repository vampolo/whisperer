function [indexes] = getIndexFromID (cache,IDs)
% function [indexes] = getIndexFromID (cache,IDs)
% 
% convert a set of itemIDs (or userIDs) from CW in the related row/col
% (here referred to as index) of a matlab matrix.
%
% cache = can be either a usercache or an itemcache
% IDs = vector of itemIDs (or userIDs)
% indexes = returned vector of converted row/col indexes
    indexes = zeros(length(IDs),1);
    for i=1:length(IDs)
        index = find (cache(:,1)==IDs(i));
        if (index>0)
            indexes(i) = cache(index,2);
        else
            indexes(i) = -1;
            warning(strcat('ID ', num2str(IDs(i)), ' not found'));
        end
    end