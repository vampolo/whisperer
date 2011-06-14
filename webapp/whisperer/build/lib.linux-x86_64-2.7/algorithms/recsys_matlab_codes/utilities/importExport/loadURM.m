function [urm] = loadURM (URMpath,nameVariable)
% function [urm] loadURM (URMpath,nameVariable)

if (exist('nameVariable')==0)
    nameVariable='urm';
end

urm=getfield(load('prova.mat'),nameVariable);
end