function [positive,negative,skipped]=extractTestSets (urm,percentagePos,percentageNeg)
% function [positive,negative]=extractTestSets (URMpath,percentagePos,percentageNeg)
%
% - urm = urm users x items matrix
% - percentagePos,percentageNeg = percentage of positive (negative)ratings
% to fill the test sets with

if (exist('percentageNeg')==0)
   percentageNeg=1; 
end
if (exist('percentagePos')==0)
   percentagePos=1; 
end

if (percentageNeg <0)
% estrae solo positivi
    [posI,posJ]=find(urm);
    indexPos=length(posI);
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
        if (rating>=3 && rating>userAvg(user))
            indexPos = indexPos +1;
            posI(indexPos)=user;
            posJ(indexPos)=item;
            else
            if (rating<3 && rating<userAvg(user) && rating>0)
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