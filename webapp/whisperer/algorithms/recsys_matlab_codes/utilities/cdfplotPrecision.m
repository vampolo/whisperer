function [handleCDF,stats] = cdfplotPrecision(samples,numItems)
% function [handleCDF,stats] = cdfplotPrecision(samples,numItems)

    if (~exist('numItems')) 
        numItems = 1000;
    end
    
    %x = samples(find(samples<=numItems+1 & samples>=0))-1;
    x = samples(find(samples<=numItems+1 & samples>=0));
    
    


% Get sample cdf, display error message if any
[yy,xx,n,emsg,eid] = cdfcalc(x);
yy = yy(2:end);
yy = yy./(xx);
xx = xx(2:end);
if ~isempty(eid)
   error(sprintf('stats:cdfplot:%s',eid),emsg);
end

% Create vectors for plotting
k = length(xx);
n = reshape(repmat(1:k, 2, 1), 2*k, 1);
xCDF    = [xx(n(2:end)); Inf];
yCDF    = [yy(n)];

%
% Now plot the sample (empirical) CDF staircase.
%

hCDF = plot(xCDF , yCDF);
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