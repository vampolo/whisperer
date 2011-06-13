function [handleCDF,stats] = cdfplotRecall_vs_Precision(samples,numItems)
% function [handleCDF,stats] = cdfplotRecall_vs_Precision(samples,numItems)

    if (~exist('numItems')) 
        numItems = 1000;
    end
    
    %x = samples(find(samples<=numItems+1 & samples>=0))-1;
    x = samples(find(samples<=numItems+1 & samples>=0));


% Get sample cdf, display error message if any
[yyp,xxp,n,emsg,eid] = cdfcalc(x);
yyp = (yyp(1:end-1) + yyp(2:end))/2;
%yyp = yyp(2:end);
yyp = yyp./(xxp);
if ~isempty(eid)
   error(sprintf('stats:cdfplot:%s',eid),emsg);
end

[yyr,xxr,n,emsg,eid] = cdfcalc(x);
yyr = (yyr(1:end-1) + yyr(2:end))/2;
%yyr = yyr(2:end);
if ~isempty(eid)
   error(sprintf('stats:cdfplot:%s',eid),emsg);
end

% Create vectors for plotting
xCDF    = yyr;
yCDF    = yyp;

%
% Now plot the sample (empirical) CDF staircase.
%

hCDF = plot(xCDF , yCDF);
if (nargout>0), handleCDF=hCDF; end
grid  ('on')
xlabel('recall')
ylabel('precision')
%title ('Empirical graph')

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