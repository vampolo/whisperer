function [timeHandle] = displayRemainingTime(computedElements,elementsToCompute,timeHandle)
% function [timeHandle] = displayRemainingTime(elementsToCompute,computedElements,timeHandle)
    try
        tend=toc(timeHandle);
    catch
        timeHandle=tic;
        return;
    end
    perItemTime=(tend)/computedElements;
    remainingTime=perItemTime*(elementsToCompute-computedElements);        
    disp([num2str(computedElements),'/',num2str(elementsToCompute), ' - remainingTime for task=',num2str(round(remainingTime)),' sec']);
end