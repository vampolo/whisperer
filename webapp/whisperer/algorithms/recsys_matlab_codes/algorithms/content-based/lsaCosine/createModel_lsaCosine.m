function [model] = createModel_lsaCosine (URM,param)
% URM = matrix with user-ratings
% param.ls = latent size
% [param.itemModel] = matrice projItem=s*v' (non necessariamente normalizzata)
% [param.icm] = Item-content matrix

    if isfield(param,'itemModel')
        d=param.itemModel;
        if isfield(param,'ls')
            ls=param.ls;
            d=d(1:ls,:);
        end        
    else
        if isfield(param,'icm')
            if isfield(param,'ls')
                ls=param.ls;
            else
                ls=300;
            end                  
            [u,s,v]=svds(param.icm,ls);
            d = s*v';
        else
            warning('lsa: not enough parameters..');
        end
    end
    
    if isfield(param,'shrinking')
        shrinking = param.shrinking;
    else
        shrinking = 0;
    end
    display(['shrinking=',num2str(shrinking)]);
    
    if shrinking>0
        dnorm = normalizeShrinkageColsMatrix(d,shrinking); %shrinked cosine
    else
        dnorm = normalizeColsMatrix(d); % cosine
    end
    model.dnorm = dnorm; 
end