function [positive,negative]=extractTestSetsUnpopular (urm,percentagePos,percentageNeg, unpopularThreshold, kfolder, itemsViews)
% function [positive,negative]=extractTestSets (urm,percentagePos,percentageNeg, unpopularThreshold, kfolder, [itemsViews])
%
% - urm = urm users x items matrix
% - percentagePos,percentageNeg = percentage of positive (negative)ratings
% to fill the test sets with
%
% - unpopularThreshold = create test sets discarding popular items, i.e.,
% items in the TOP N, where N=unpopularThreshold
% - kfolder. If k-folder is non-null positive/negative tests are generated
% for each fold (as used by the k-folder function)
% - [itemsViews] = (optional) distribution of items'
%                   views. If not specified the computation is done on urm.

display('extracting unpopular test-set');

if (exist('kfolder')==0)
    kfolder = 1;
end

if (exist('itemsViews')~=1)
    itemsViews=full(sum(sponesURM(urm),1));
else
    if (length(itemsViews)~=size(urm,2))
        error(['itemsViews has wrong size:', num2str(length(itemsViews))]);
    end
end

numUsers=size(urm,1);
numRowsToTest = floor(numUsers/kfolder);

for fold=1:kfolder
%suddivido in parte di test (urmTest) e parte di train (urmTrain)

    maxIndexRowTest = numRowsToTest * fold;
    %urmTrain = [urm(1 : maxIndexRowTest - numRowsToTest, :) ; urm(maxIndexRowTest + 1:end ,:)];
    urmTest = urm(maxIndexRowTest - numRowsToTest + 1 : maxIndexRowTest , :);
    
    [poss,negg]=extractTestSetsUnpopularIn (urmTest,percentagePos,percentageNeg, unpopularThreshold, itemsViews);        
    poss.i=poss.i + maxIndexRowTest - numRowsToTest;
    negg.i=negg.i + maxIndexRowTest - numRowsToTest;
    
    positive(fold)=poss;
    negative(fold)=negg;
%    skipped(fold)=skippedtmp;
    
end

end


function [positive,negative,skipped]=extractTestSetsUnpopularIn (urm,percentagePos,percentageNeg, unpopularThreshold, itemsViews)

    if (exist('percentageNeg')==0)
       percentageNeg=1; 
    end
    if (exist('percentagePos')==0)
       percentagePos=1; 
    end
    
    skipped=[];
    
    %usersViews=sum(urmspones,2);

    if (unpopularThreshold>0)
        orderedItemsViews = sort(itemsViews,2,'descend');
        viewsThreshold = orderedItemsViews(unpopularThreshold);
    else
        viewsThreshold = max(itemsViews)+1;
    end 

    display(['unpopular test set selection - threshold = ', num2str(viewsThreshold),' ratings']);

    if (percentageNeg <0)
    % estrae solo positivi
        [posItmp,posJtmp]=find(urm);

        posI=zeros(size(posItmp));
        posJ=zeros(size(posJtmp));

        indexPos=0;
        for i=1:length(posItmp)
            user = posItmp(i);
            item = posJtmp(i);
            if (itemsViews(item)<viewsThreshold )
                indexPos = indexPos +1;
                posI(indexPos)=user;
                posJ(indexPos)=item;
            end
        end    

        numPos=ceil(indexPos*percentagePos);
        posIndex = randsample(indexPos,numPos);
        positive.i=posI(posIndex);
        positive.j=posJ(posIndex);
        negative.i=[];
        negative.j=[];
    else

        userAvg=zeros(1,size(urm,1));
        itemAvg=zeros(1,size(urm,2));
        skipped=[];

        h = waitbar(0,'Please wait...');
        for i=1:size(urm,1)
            if (~isempty(find(urm(i,:))))
                userAvg(i)=mean(urm(i,find(urm(i,:))));
            else
                skipped=[skipped;i];
            end
            if mod(i,100)==0
                waitbar(i/size(urm,1),h,num2str(i))
            end
        end
        close(h);
        drawnow;
        % for i=1:size(urm,2)
        %     itemAvg(i)=mean(urm(find(urm(:,i)),i));
        % end

        [urmI,urmJ]=find(urm);

        posI=zeros(size(urmI));
        posJ=zeros(size(urmI));
        negI=zeros(size(urmI));
        negJ=zeros(size(urmI));

        indexPos=0;
        indexNeg=0;
        for i=1:length(urmI)
            user = urmI(i);
            item = urmJ(i);
            rating = urm(user,item);
            if (rating>=3 && rating>userAvg(user) && itemsViews(item)<viewsThreshold )
                indexPos = indexPos +1;
                posI(indexPos)=user;
                posJ(indexPos)=item;
                else
                if (rating<3 && rating<userAvg(user) && rating>0 && itemsViews(item)<viewsThreshold)
                    indexNeg = indexNeg +1;
                    negI(indexNeg)=user;
                    negJ(indexNeg)=item;  
                end
            end
        end
        

        posI=posI(1:indexPos);
        posJ=posJ(1:indexPos);
        negI=negI(1:indexNeg);
        negJ=negJ(1:indexNeg);

        if (percentageNeg==1 && percentagePos==1)
            positive.i=posI;
            positive.j=posJ;
            negative.i=negI;
            negative.j=negJ;
            return
        end

        numPos=ceil(indexPos*percentagePos);
        numNeg=ceil(indexNeg*percentageNeg);

        posIndex = randsample(indexPos,numPos);
        negIndex = randsample(indexNeg,numNeg);

        positive.i=posI(posIndex);
        positive.j=posJ(posIndex);
        negative.i=negI(negIndex);
        negative.j=negJ(negIndex);
    end
end