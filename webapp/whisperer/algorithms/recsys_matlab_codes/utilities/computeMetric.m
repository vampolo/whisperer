function [metric]=computeMetric(testResults, N)
% 'testResults' è il vettore contenente le posizioni degli item testati nella
%   lista di raccomandazione (un valore per ogni test effettuato
% 'N' è la Top su cui calcolare la recall (top-N)
%
% 'metric' è il valore di recall restituito

if (prod(size(testResults))>length(testResults))
    metric = -1
    exit function
end

metric = length(find(testResults<=N))/length(testResults);

end