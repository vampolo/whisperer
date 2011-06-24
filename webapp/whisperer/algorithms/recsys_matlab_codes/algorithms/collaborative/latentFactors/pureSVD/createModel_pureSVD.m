function [model] = createModel_pureSVD (URM, ICM, modelParam)
% URM = matrix with user-ratings
% modelParam = modelParam.ls specifies the latenSize

ls=50;
if (exist('modelParam')~=0)
    if (isstruct(modelParam))
        if (isfield(modelParam,'ls')) 
            ls = modelParam.ls;
        end
    end
end

    [u,s,v]=svds(URM,ls);
    model.vt=v';     
end