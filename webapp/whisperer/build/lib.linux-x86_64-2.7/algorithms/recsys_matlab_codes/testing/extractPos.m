function [pos1,pos2] = extractPos(urm_1half,urm_2half)
    [pos1.i,pos1.j]=find(urm_1half);
    indexes=randsample(length(pos1.i),5000);
    pos1.i=pos1.i(indexes);
    pos1.j=pos1.j(indexes);

    if (exist('urm_2half')==0)
       return 
    end

    [pos2.i,pos2.j]=find(urm_2half);
    
    indexes=randsample(length(pos2.i),2000);
    pos2.i=pos2.i(indexes);
    
    pos2.j=pos2.j(indexes);
    pos2.i=pos2.i+size(urm_1half,1);

end