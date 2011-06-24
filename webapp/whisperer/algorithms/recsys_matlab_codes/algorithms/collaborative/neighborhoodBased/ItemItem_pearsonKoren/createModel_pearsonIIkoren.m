function [model] = createModel_pearsonIIkoren (URM,ICM,param)
% URM = matrix with user-ratings
% param: 	[param.model] --> opzionale, contiene gi� la matrice dr e i bias
%			param.knn --> K similar items
%           [param.lambdaS] -->  shrinking factor per s_{ij}
%           [param.lambdaI] -->  shrinking factor per media item b_{i}
%           [param.lambdaU] -->  shrinking factor per media user b_{u}
%           [param.Cdisabled] --> DISABLE C-compiled execution
%           [param.similarityOnResidual] --> set the way similarity 
%               is computed: 1 (DEFAULT): computes similarity on 
%                                           residuals' URM (i.e., after
%                                           removing global effects)
%                            0          : computes similarity on
%                                           original URM
%
%
% model:    model.mu --> average rating
%           model.bu --> vector of the average rating for each user
%           model.bi --> vector of the average rating for each item
%           model.dr --> item-item similarity matrix
%           model.lambdaS -->  shrinking factor USED per s_{ij}
%           model.lambdaI -->  shrinking factor USED per media item b_{i}
%           model.lambdaU -->  shrinking factor USED per media user b_{u}
%			model.knn --> Knn USED
%			model.similarityOnResidual --> similarityOnResidual USED
%
% reference paper: 
% "Factor in the Neighbors: Scalable and Accurate Collaborative Filtering"
% Yehuda Koren, AT&T Labs - Research

    if (~exist('param')) 
        param=struct();
    end

    if (isfield(param,'model'))
        model=param.model;
        return;
    end
    
    if (isfield(param,'knn'))
        knn = param.knn;
    else 
        knn= 200;
    end    
    if (isfield(param,'lambdaS'))
        lambdaS = param.lambdaS;
    else 
        lambdaS=100;
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
    
    Cdisabled=false;
    if (isfield(param,'Cdisabled'))
        if (islogical(param.Cdisabled))
            Cdisabled = param.Cdisabled;
        end
    end
    
    similarityOnResidual = true;
    if (isfield(param,'similarityOnResidual'))
        similarityOnResidual = param.similarityOnResidual;
    end    
    if (~similarityOnResidual && isempty(inputname(1)))
        urmSimilarity = URM;
    else
        urmSimilarity = [];
    end
    
tic
%display('Pearson IIkoren: computing URM transpose');
    URMt=URM';
display(['Pearson IIkoren: transpose computed in ',num2str(toc),' sec']);


display(' - Pearson IIkoren: computing biases - ');
    mu = full(sum(sum(URM,1),2));
    mu = mu/nnz(URM);
    nnzI=zeros(1,size(URM,2));
    nnzU=zeros(1,size(URM,1));
    
    timeHandleBiases=tic;
    for i=1:length(nnzI)
        nnzI(i)=nnz(URM(:,i)); 
        if (mod(i,2000)==0),
            displayRemainingTime(i, length(nnzI),timeHandleBiases);           
        end       
    end
    bi = (sum(URM,1) - mu*(nnzI)) ./ (lambdaI + nnzI);
    
    for i=1:length(nnzU)
        nnzU(i)=nnz(URMt(:,i)); 
        if (mod(i,20000)==0),
            displayRemainingTime(i, length(nnzU),timeHandleBiases);           
        end       
    end   

    timeHandleBiases=tic;
    splitSize=100;
    splitNum=ceil(size(URM,1)/splitSize);
    tosub=zeros(1,size(URM,1));
    for i=1:splitNum
        maxRowNum=min([i*splitSize,size(URM,1)]);
        rowIndexes=splitSize*(i-1)+1:maxRowNum;
        
        %tosub(rowIndexes)=sum(spones(URMt(:,rowIndexes)'.*(ones(length(rowIndexes),1)*bi)),2);
        tosub(rowIndexes)=sum(spones(URMt(:,rowIndexes)').*(ones(length(rowIndexes),1)*bi),2);

        if (mod(i,50000)==0),
            displayRemainingTime(i, splitNum,timeHandleBiases);           
        end          
    end
    bu = (sum(URM,2)' - mu*nnzU - tosub) ./ (lambdaU + nnzU);
    
    clear URMt;
  
display(' - Pearson IIkoren: normalize URM - ');
    timeHandleNormalize=tic;
    successful = false;
    if (~Cdisabled)
        try
            URM = provaNormalize(URM,mu+bi);
            successful = true;
        catch e
            display('C-compiled code failed!');
            display(e);
        end
    end
    if (~successful)
        for i=1:length(bi)
            itemVector=URM(:,i); 
            nnzIndexes=find(itemVector);
            URM(nnzIndexes,i) = itemVector(nnzIndexes)-mu-bi(i);
            if (mod(i,1000)==0),
                displayRemainingTime(i, length(bi),timeHandleNormalize);           
            end       
        end
    end
display(['Item bias normalized in ',num2str(toc(timeHandleNormalize)),' sec']);    
    
tic;
%display('Pearson IIkoren: computing URM transpose');
    URMt=URM';
    clear URM;
display(['Pearson IIkoren: transpose computed in ',num2str(toc),' sec']);
timeHandleNormalize=tic;
    for i=1:length(bu)
        userVector=URMt(:,i); 
        nnzIndexes=find(userVector);
        URMt(nnzIndexes,i) = userVector(nnzIndexes)-bu(i);
        if (mod(i,50000)==0),
            displayRemainingTime(i, length(bu),timeHandleNormalize);           
        end       
    end    

tic;    
%display('Pearson IIkoren: computing URM'' transpose');
    URM=URMt';
display(['Pearson IIkoren: URM'' transpose computed in ',num2str(toc),' sec']);    
clear URMt;  
    

    if (~similarityOnResidual)
        display('Pearson-r computed on original URM');
        if (isempty(urmSimilarity))
            II = computePearsonSimilarity (evalin('caller', inputname(1)), knn, lambdaS, Cdisabled);
        else
            II = computePearsonSimilarity (urmSimilarity, knn, lambdaS, Cdisabled);
        end
    else
        display('Pearson-r computed on residuals');
        II = computePearsonSimilarity (URM, knn, lambdaS, Cdisabled);
    end

    model.mu = mu;
    model.bu = bu;
    model.bi = bi;
    model.dr = II; 
    
    model.lambdaS = lambdaS;
	model.lambdaI = lambdaI;
    model.lambdaU = lambdaU;    
    model.knn = knn;    
    model.similarityOnResidual = similarityOnResidual;
end




% function [URM] = normalizeColsMatrix (URM)
%     tic
%     display(['Cosine IIknn: normalization started']);
%     splittingSize=100;
%     
%     items=size(URM,2);
%     numSplittings=items/splittingSize;
%     
%     for i=1:ceil(numSplittings)
%         beginInterval=splittingSize*(i-1) +1;
%         endInterval=splittingSize*(i);
%         if (endInterval>items), endInterval=items; end
%         URM(:,beginInterval : endInterval)= normalizeWordsMatrix(URM(:,beginInterval : endInterval),2);
%     end
%     display(['Pearson IIknn: normalization completed in ',num2str(toc),' sec']);
% end