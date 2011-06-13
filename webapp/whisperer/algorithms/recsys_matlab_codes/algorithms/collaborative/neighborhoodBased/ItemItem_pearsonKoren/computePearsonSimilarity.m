function [II] = computePearsonSimilarity (URM, knn, lambdaS,Cdisabled)
% function [II] = computePearsonSimilarity (URM, knn, lambdaS,Cdisabled)
%
% URM
% knn
% lamdbaS
% Cdisabled
%

if (nargin<3)
    help computePearsonSimilarity
    return
end

if (nargin<4) 
    Cdisabled=false;
end

timeHandle=tic;
display(' - Pearson IIkoren: pearson-r and knn-filtering will be comptuted together - ');     
    if (knn>=size(URM,2))     
        warning('MEMORY ISSUE: the knn parameter should be smaller'); 
        knn=size(URM,2)-1;
    end
    II = sparse(size(URM,2),size(URM,2));     % creo matrice vuota (sparsa)
    
    splitSize=150;
    splitNum=ceil(size(II,2)/splitSize);
    for j=1:splitNum
        maxNumOfCols=min([j*splitSize,size(II,2)]);
        colIndexes=splitSize*(j-1)+1:maxNumOfCols;
        
        if (Cdisabled)
            colItems=corr(URM,URM(:,colIndexes));
        else
            try
                %display('trying C-compiled code...');
                [colItems,commonElementsC]=pearsonCoeff(URM,URM(:,colIndexes));
            catch e
                display(e);
                error('C-compiled code failed! --> change parameter Cdisabled to use approximated matlab function');
                Cdisabled=true;
                colItems=corr(URM,URM(:,colIndexes));
            end
        end
        try 
            colItems=full(colItems);
        catch e
            display(e);
        end
        
        colItems(find(isnan(colItems))) = 0;
        
        if (Cdisabled)
            commonElements=zeros(size(URM,2),length(colIndexes));
            otherSplitSize=50;
            otherSplitNum=ceil(size(URM,2)/otherSplitSize);
            for a=1:otherSplitNum
                otherColMax=min([a*otherSplitSize,size(URM,2)]);
                otherColIndexes=otherSplitSize*(a-1)+1:otherColMax;
                for b=1:length(colIndexes)
                    commonElements(otherColIndexes,b)=sum(spones(URM(:,otherColIndexes).*(URM(:,colIndexes(b))*ones(1,length(otherColIndexes)))),1);
                end

            end
        else
           commonElements = commonElementsC;
        end

        if (lambdaS>0)
            commonElements=commonElements./(commonElements+lambdaS);
            colItems=colItems.*commonElements;        
        end
        
        try
            [r c]= sort(full(colItems),'descend');
        catch errorcatched
            display(errorcatched.message);
            display(['error while sorting: size colItems= ' num2str(size(colItems))]);
        end

        itemsToKeep=sub2ind([size(colItems,1) size(colItems,2)],c(1:knn+1,:),[[1:length(colIndexes)]'*ones(1,knn+1)]');        
        filteredColItems=zeros(size(colItems));
        filteredColItems(itemsToKeep)=colItems(itemsToKeep);
        II(:,colIndexes) = filteredColItems;
    
        if (mod(j,2)==0)
            timeHandle=displayRemainingTime(maxNumOfCols, size(II,2),timeHandle);           
        end
    end
    II(sub2ind(size(II),[1:size(II,2)],[1:size(II,2)]))=0;
    
display([' - Pearson IIkoren: pearson-r and knn-filtering completed in ',num2str(toc(timeHandle)),' sec - ']);


end