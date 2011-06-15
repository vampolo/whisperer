function [rank] = computeRank(pos)
    if (size(pos,2)>0)
	    for a=1:size(pos,2), r(a)=pos(a).pos; rating(a)=pos(a).rating; end;
	    rank=r(find(rating~=-1));
    else
         rank=-1;
    end
end