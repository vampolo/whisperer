function [model] = createModel_cosineIIknn (URM,param)
% URM = matrix with user-ratings
% param: 	empty --> esegue classico coseno
%                   [param.model] --> opzionale, contiene già la matrice dr
%                   e i bias
%					param.drCos --> opzionale, contiene già la matrice DR=URM'*URM
%					param.knn --> contiene il numero di K da considerare nella matrice DR
%                   param.memoryProblem --> boolean, se true impone l'utilizzo della
%                                           versione ottimizzata per matrici sparse grandi
%                   param.computeBaseline --> compute mu, bu and bi
%                        .lambdaI
%                        .lambdaU
%                   param.SimilarityShrinkage --> enable shrinking for
%                                                 COSINE similarity (shrinking factor is lambdaS)
%                        .lambdaS --> shrinking factor
%                   param.noNormalization --> it does not normalize URM
%                                               (it's the same as DR KNN).
%                                               It works only with NO
%                                               external computation (not
%                                               compatible with param.shrinkNormalization)
%                   param.shrinkNormalization --> if greater than 0, it does normalized the
%                                                  URM using this parameter
%                                                  as shrinking constant (not
%                                                  compatible with param.noNormalization)

    if (exist('param')==0)
        param=struct;
        param.memoryProblem=false;
    else
        if (~isfield(param,'memoryProblem'))
            param.memoryProblem=false;
        end
    end
    
    if ~(isfield(param,'shrinkNormalization'))
        param.shrinkNormalization = 0;
    end
    if ((param.shrinkNormalization>0) && isfield(param,'noNormalization'))
        error('shrinkNormalization and noNormalization are NOT compatible');
    end
    display(['param.shrinkNormalization=',num2str(param.shrinkNormalization)]);
    
    if (isfield(param,'model'))
        display('COS: model loaded from file..');
        model = param.model;
        return;
    end
    
    SimilarityShrinkage = false;
    if (isfield(param,'SimilarityShrinkage'))
        if (islogical(param.SimilarityShrinkage))
            SimilarityShrinkage = param.SimilarityShrinkage;
        end
        lambdaS = 100;
        if (isfield(param,'lambdaS'))
            lambdaS = param.lambdaS;
        end
        display('shrinkage enabled');
    end    

    if (isfield(param,'lambdaI'))
        lambdaI = param.lambdaI;
    else 
        lambdaI=25;
    end
    if (isfield(param,'lambdaU'))
        lambdaU = param.lambdaU;
    else 
        lambdaU=10;
    end    
					
    if (isfield(param,'drCos'))
        if (~param.memoryProblem)
            try
                drCos = full(param.drCos);
            catch exception
               param.memoryProblem=true; 
            end                
        end
    else 
        if (exist('provaCosShrink')==3)
            display('mex-file provaCosShrink will be used');
        else
            if (~isfield(param,'noNormalization'))
                if param.shrinkNormalization>0 
                    display('matrix normalized by using shrinking cosine');
                    URM=normalizeShrinkageColsMatrix(URM,param.shrinkNormalization);
                else
                    display('matrix normalized by using cosine');
                    URM=normalizeColsMatrix(URM);
                end
            else
                display('urm will not be normalized');
            end
        end
        if (~param.memoryProblem)
            try
                drCos=full(URM'*URM);
            catch exception
               param.memoryProblem=true; 
            end
        end
    end
    if (isfield(param,'knn'))
        knn = param.knn;
    else 
        knn=size(URM,2);
    end
    
 %%% KNN  

timeHandle=tic;
 if (~param.memoryProblem)
display('Cosine IIknn: started knn-filtering');     
     if (knn<size(drCos,2))
%        for i=1:size(drCos,2), drCos(i,i)=0;  end   % annullo diagonale
        II = sparse(size(drCos,1),size(drCos,2));     % creo matrice vuota (sparsa)
        for i=1:size(II,2)
           colItem = drCos(:,i);
           [r c] = sort(colItem,'descend');
           itemToKeep = c(1:knn);
           II(itemToKeep,i) = drCos(itemToKeep,i);
        end
    else
        II=drCos;
    end
display(['Cosine IIknn: knn-filtering completed in ',num2str(toc),' sec']);
 else
tic;
display('Cosine IIknn: (MEMORY OPTIMIZATION) multiplication and knn-filtering will be comptuted together');     
    if (knn>=size(URM,2))     
        error('MEMORY ISSUE: knn must be smaller'); 
    end
    II = sparse(size(URM,2),size(URM,2));     % creo matrice vuota (sparsa)
    
    splitSize=500;
    splitNum=ceil(size(II,2)/splitSize);
    cfailed=false;
    for j=1:splitNum
        maxNumOfCols=min([j*splitSize,size(II,2)]);
        colIndexes=splitSize*(j-1)+1:maxNumOfCols;
        
        commonEl=false;
        if ~cfailed
            try
                [colItems,commonElementsC] = provaCosShrink (URM,URM(:,colIndexes));
                commonEl=true;
            catch e
                %display(e);
                display('C-compiled code failed! --> using approximated matlab function');            
                cfailed=true;
            end
        end    
        if cfailed
            colItems=(URM'*URM(:,colIndexes));
        end
        
        colItems=full(colItems);
        colItems(find(isnan(colItems))) = 0;
        
        if (SimilarityShrinkage)
            if (~commonEl)
                commonElements=zeros(size(URM,2),length(colIndexes));
                otherSplitSize=100;
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
            commonElements=commonElements./(commonElements+lambdaS);
            colItems=colItems.*commonElements;          
        end

        [r c]= sort(full(colItems),'descend');
     %{
        itemsToDelete=sub2ind([size(colItems,1) size(colItems,2)],c(knn+1:end,:),[[1:length(colIndexes)]'*ones(1,size(II,2)-knn)]');
        colItems(itemsToDelete)=0;
        II(:,colIndexes) = colItems;
      %}
        itemsToKeep=sub2ind([size(colItems,1) size(colItems,2)],c(1:knn+1,:),[[1:length(colIndexes)]'*ones(1,knn+1)]');        
        filteredColItems=zeros(size(colItems));
        filteredColItems(itemsToKeep)=colItems(itemsToKeep);
        II(:,colIndexes) = filteredColItems;
    
        if (mod(j,1)==0)
            timeHandle=displayRemainingTime(maxNumOfCols, size(II,2),timeHandle);           
        end
    end
    %II(sub2ind(size(II),[1:size(II,2)],[1:size(II,2)]))=0;
    
display(['Cosine IIknn: multiplication and knn-filtering completed in ',num2str(toc),' sec']);
 end

     if isfield(param,'computeBaseline')
         if islogical(param.computeBaseline)
             if param.computeBaseline
                 [mu,bu,bi] = computeRatingBiases (URM,lambdaU,lambdaI);
                 model.mu = mu;
                 model.bu = bu;
                 model.bi = bi;
             end
         end
     end
     model.II = II;
     model.SimilarityShrinkage = SimilarityShrinkage;
end