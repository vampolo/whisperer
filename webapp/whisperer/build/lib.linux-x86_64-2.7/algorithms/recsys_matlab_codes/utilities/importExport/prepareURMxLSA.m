function [adaptedMatrix,urmAdp,notfound] = prepareURMxLSA(itemId,urm,urmItemcacheFileName,direction, icmModel)
% function [urmAdapted] =
% prepareURMxLSA(itemId,urm,urmItemcacheFileName,direction)
%
% optional attributes:
% direction = 1 if URM is added ICM surplus-column (default value)
%           = 2 if ICM is removed ICM surplus-columns
% icmModel = used if direction = 2
%
% [icmItemModelAdp,urmAdp,notfound]=prepareURMxLSA(itemCacheICM(:,1),urm,'ITEMSCACHE_urm.mm',2,itemModel);


display ('WARNING: use prepareURMxLSAnew');

if (exist('direction')==0)
    direction = 1;
elseif (direction ==2 & exist('icmModel')==0)
    display ('missing icmModel.. required!');
	return;
end

itemcache = parseItemCache(urmItemcacheFileName);

if (direction==1)

    adaptedMatrix=sparse(size(urm,1),length(itemId));

    itemMapping=zeros(length(itemId),1);
    for i=1:size(urm,2)
       tmp=find(itemcache(:,2)==i);
       itemIdUrm = itemcache(tmp,1);
       itemMapping(i)=find(itemId==itemIdUrm); % in itemMapping(i) c'è la colonna corrispondente nella matrice ICM 
       adaptedMatrix(:,itemMapping(i))=urm(:,i);
    end
elseif (direction==2)
    
    %adaptedMatrix=sparse(size(icmModel,1),size(urm,2));

    itemMapping=zeros(size(urm,2),1);
    notfound=[];
    for i=1:size(urm,2)
       tmp=find(itemcache(:,2)==i);
       itemIdUrm = itemcache(tmp,1);
       mapresult = find(itemId==itemIdUrm);
       if isempty(mapresult)
           display(['Item ', num2str(i), ' non found!']);
           notfound=[notfound,i];
           itemMapping(i)=1;
           continue;
       end
       itemMapping(i)= mapresult;% in itemMapping(i) c'è la colonna corrispondente nella matrice ICM 
    end
    
    urmAdp=urm;
    urmAdp(:,notfound)=[];
    itemMapping(notfound)=[];
    adaptedMatrix=icmModel(:,itemMapping);
end

end