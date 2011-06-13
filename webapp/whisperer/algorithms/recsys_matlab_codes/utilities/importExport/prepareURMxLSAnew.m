function [adaptedMatrix,adaptedItemModel] = prepareURMxLSAnew(itemcacheICM,itemcacheURM,urm,direction,itemModel,icm)
% [adaptedMatrix,adaptedItemModel] = 
% prepareURMxLSAnew(itemcacheICM,itemcacheURM,urm,direction,itemModel,icm)
%
% optional attributes:
% direction = 1 if URM is added ICM surplus-column (default value)
%           = 2 if ICM is removed ICM surplus-columns
% icmItemModel = used if direction = 2
% icm = used if direction = 2 (always optional)
%
% OUTPUT: 
%  - adaptedMatrix
%  - adaptedItemModel is mandatory only if direction=2
%  
% [adaptedURM] = prepareURMxLSAnew(itemcacheICM,itemcacheURM,urm,1);
% [adaptedICM,adaptedItemModel] =
% prepareURMxLSAnew(itemcacheICM,itemcacheURM,urm,2,itemModel,icm);

if (exist('direction')==0)
    direction = 1;
elseif (direction ==2 & nargin<5 )
    display ('check icmModel.. required!');
	return;
end

if (max(diff(itemcacheICM(:,2)))~=1 || min(diff(itemcacheICM(:,2)))~=1)
   error('check ITEMCACHEICM'); 
end

if (max(diff(itemcacheURM(:,2)))~=1 || min(diff(itemcacheURM(:,2)))~=1)
   error('check ITEMCACHEURM'); 
end

itemId=itemcacheICM(:,1);
itemcache = itemcacheURM;

if (direction==1)

    adaptedMatrix=sparse(size(urm,1),length(itemId));

    itemMapping=zeros(length(itemId),1);
    colindex=1;
    for i=1:size(urm,2)
       tmp=find(itemcache(:,2)==i);
       itemIdUrm = itemcache(tmp,1);
       tmpMapping = find(itemId==itemIdUrm);
       if (~isempty(tmpMapping))
            itemMapping(colindex)=tmpMapping; % in itemMapping(i) c'è la colonna corrispondente nella matrice ICM 
            adaptedMatrix(:,itemMapping(colindex))=urm(:,i);
            colindex=colindex+1;
       else
           display(['ID(urm) ', num2str(itemIdUrm), ' not found in ICM']);
       end
    end
elseif (direction==2)
    
    adaptedItemModel=sparse(size(itemModel,1),size(urm,2));
    if (nargin>=6)
        adaptedMatrix=sparse(size(icm,1),size(urm,2));
    else
        adaptedMatrix=0;
    end

    itemMapping=zeros(size(urm,2),1);
    for i=1:size(urm,2)
       tmp=find(itemcache(:,2)==i);
       itemIdUrm = itemcache(tmp,1);
       itemMapping(i)=find(itemId==itemIdUrm); % in itemMapping(i) c'è la colonna corrispondente nella matrice ICM 
       
       adaptedItemModel(:,i)=itemModel(:,itemMapping(i));
       if (nargin>=6)
          adaptedMatrix(:,i)=icm(:,itemMapping(i));
       end
    end
end

end