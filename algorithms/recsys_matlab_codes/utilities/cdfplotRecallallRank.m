function [handleCDF,stats] = cdfplotRecallallRank(numItems,varargin)
% function [handleCDF,stats] = cdfplotRecallallRank(numItems=1000,plotStr='')

    if (nargin<1) 
        numItems = 1000;
    end
    
    varlist = evalin('caller','who(''rank*'')');
    if ~isempty(varlist) 
        handleCDF=figure;
        hold on;
    end
    for i=1:length(varlist)
        eval(strcat('cdfplotRecall(evalin(''caller'',varlist{i}),numItems,varargin{:})'));
    end
    xlim([0 20]);
    legend(varlist);