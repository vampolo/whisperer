function [model] = createModel_drII (URM,ICM,param)
% URM = matrix with user-ratings

    if (exist('param')==0)
        dr=URM'*URM;
    else
        dr = param.dr;
    end
    
    model.dr = dr; 
end