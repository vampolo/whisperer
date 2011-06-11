function [expPercRank] = computeExpPercRank(pos,urm)
% [expPercRank] = computeExpPercRank(pos,urm)
% Compute the quality metric expected Percentage Ranking for
% implicit-feedback URM 
%
% See
% "Collaborative Filtering for Implicit Feedback Datasets" 
% Yifan Hu, Yehuda Koren, Chris Volinsky [ICDM 2008]
%
%
% - pos = struct with .item
%                     .user
%                     .pos
%                     .rating
% - urm = URM (dataset).


    numItems=size(urm,2);
    userViews=sum(spones(urm),2);


    r=zeros(size(pos,2),1);
    rating=zeros(size(pos,2),1);
    views=ones(size(pos,2),1);
    if (size(pos,2)>0)
	    for a=1:size(pos,2)
            r(a)=pos(a).pos; 
            if (pos(a).rating~=-1)
                rating(a)=urm(pos(a).user,pos(a).item); 
            else
                rating(a)=pos(a).rating;
            end
            views(a)=userViews(pos(a).user);
        end
        toConsider=find(rating~=-1);
        r=r(toConsider);
        rating=rating(toConsider); 
        views=views(toConsider); 
	    expPercRank=(sum(rating.*((r-1)./(numItems-views))))/sum(rating);  
        %total number of items is substracted by views in order to remove the number of items not proposed to user
    else
        expPercRank=-1;
    end
end