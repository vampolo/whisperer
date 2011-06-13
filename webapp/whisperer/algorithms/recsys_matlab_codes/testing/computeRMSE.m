function [rmse] = computeRMSE(testdata,urm)
    if (size(testdata,2)>0)
        tmpSum=0;
        tmpCount=0;
        for i=1:size(testdata,2), 
            estimatedrating=testdata(i).rating; 
            actualrating=urm(testdata(i).user,testdata(i).item);
            if (estimatedrating~=-1 && ~isnan(estimatedrating))
                tmpSum=tmpSum+((estimatedrating-actualrating)^2);
                tmpCount=tmpCount+1;
            end
        end
        rmse=sqrt(tmpSum/tmpCount);	    
    else
         rmse=-1;
    end
end