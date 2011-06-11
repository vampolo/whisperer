function [handleCDF,stats] = cdfplotRecall(samples,numItems,varargin)
% function [handleCDF,stats] = cdfplotRecall(samples,numItems=1000,plotStr='')

    if (nargin<2) 
        numItems = 1000;
    end
        
    
    %x = samples(find(samples<=numItems+1 & samples>=0))-1;
    x = samples(find(samples<=numItems+1 & samples>=0));

% Copyright 1993-2004 The MathWorks, Inc. 
% $Revision: 1.5.2.1 $   $ Date: 1998/01/30 13:45:34 $

% Get sample cdf, display error message if any
[yy,xx,n,emsg,eid] = cdfcalc(x);
if ~isempty(eid)
   error(sprintf('stats:cdfplot:%s',eid),emsg);
end

% Create vectors for plotting
%%%k = length(xx);
%%%n = reshape(repmat(1:k, 2, 1), 2*k, 1);
%%%xCDF    = [-Inf; xx(n); Inf];
%%%yCDF    = [0; 0; yy(1+n)];
xCDF = xx;
yCDF = (yy(1:end-1) + yy(2:end))/2;

%
% Now plot the sample (empirical) CDF staircase.
%

hCDF = plot(xCDF , yCDF,varargin{:});
if (nargout>0), handleCDF=hCDF; end
grid  ('on')
xlabel('x')
ylabel('F(x)')
%title ('Empirical CDF')

%
% Compute summary statistics if requested.
%

if nargout > 1
   stats.min    =  min(x);
   stats.max    =  max(x);
   stats.mean   =  mean(x);
   stats.median =  median(x);
   stats.std    =  std(x);
end