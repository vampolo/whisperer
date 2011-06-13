function [itemPivot,numRatingsItemPivot] = findRatingPercentile(urm, percentile)
% function [itemPivot,numRatingsItemPivot] = findRatingPercentile(urm, percentile)
% trova il percentile per separare items in popolari e non popolari
%
% urm: matrice urm (users x items)
% percentile: [0 1] indicante il percentile da considerare
%
% output: 
% - itemPivot: item che separa tra popolari e non popolari, in base al
% percentile scelto
% - numRatingsItemPivot: numero di rating ricevuti dall'itemPivot
%
% esempio: [itemPivot,numRatingsItemPivot]=findRatingPercentile(urm, percentile);

    sortedItems=sort(full(sum(sponesURM(urm),1)),'descend');
    cumItems=cumsum(sortedItems);
    itemPivot=searchclosest(cumItems,cumItems(end)*percentile);
    numRatingsItemPivot=sortedItems(itemPivot);
end