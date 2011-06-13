function [recall] = computeRecall(pos,N)
    if (size(pos,2)>0)
	    for a=1:size(pos,2), r(a)=pos(a).pos; rating(a)=pos(a).rating; end;
	    recall=length(find(r<=N & rating~=-1))/length(find(rating~=-1));
    else
         recall=-1;
    end
end