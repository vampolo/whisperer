function [mu,bu,bi] = computeRatingBiases (URM,lambdaU,lambdaI)
% function [mu,bu,bi] = computeRatingBiases (URM,lambdaU,lambdaI)
% 
% Compute baseline estimates of a given URM

    tic;
    display(['baseline estimates: started ']);
    URMt=URM';
    display(['baseline estimates: transpose computed in ',num2str(toc),' sec']);

    display(' - baseline estimates: computing biases - ');
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
        
        tosub(rowIndexes)=sum(spones(URMt(:,rowIndexes)'.*(ones(length(rowIndexes),1)*bi)),2);

        if (mod(i,50000)==0),
            displayRemainingTime(i, splitNum,timeHandleBiases);           
        end          
    end
    bu = (sum(URM,2)' - mu*nnzU - tosub) ./ (lambdaU + nnzU);
    
    clear URMt;