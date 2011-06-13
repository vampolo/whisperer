function [icm_idf] = normalizeICMwithIDF (icm)
% normalize the Item-Content matrix using a simple IDF (inverse document frequency) schema

    stemOcc = log10(size(icm,2) ./ full(sum(icm,2)));
    icm_idf = normalizeMatrixWithVector(icm,1./stemOcc,1);


end