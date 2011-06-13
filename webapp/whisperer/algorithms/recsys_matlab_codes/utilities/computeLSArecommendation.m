function [j] = computeLSArecommendation(userProfile, titles,d,N,ls,km,explPref,explInfluence,icm,stems)
% raccomanda item, secondo un modello Content-based LSA
%
% Attributi:
% - userProfile = vettore riga con i rating dell'utente
% - titles = vettore colonna con i titoli dei film
% - d = modello dell'algoritmo. In genere, x l'algoritmo LSA, d=s*v' (s e v
% derivano dalla SVD), oppure anche semplicente ICM (nb: la memoria potrebbe 
% costituire un problema).
% - N = numero di item simili ad 'item' che si vogliono estrarre
% - ls = latent size (dimensione latente della svd). Indica quante feature
% (cioè righe) considerare del modello d
%
% attributi OPZIONALI: 
% - km = km=*u'
% - explPref = vettore di preferenze esplicite (size: 1 x stem)
% - explInfluence = peso del vettore di preferenze esplicite
% - icm = matrice ICM (stems x items)
% - stems =  vettore colonna con gli STEM
% se presenti sia 'icm' che 'stems', visualizza dettagli di correlazione di
% ogni coppia di item. (ancora DA IMPLEMENTARE!)
% 
% NB: if GLOBAL VARIABLE 'liveItemId' exists, non-lived items are filtered
% out from the recommendation list.
% The variable liveItemId must be a moviex2 matrix, where 
%  - col 1 represents the itemID (actually this col is not used here)
%  - col 2 represents the itemCol in the model matrices (this is the
%  important column)
%
% esempio di esecuzione:
% computeLSArecommendation(userProfile,titles,d,10,1,u',explPref,0.9,icm,stems);

shrinkage = 0.5;

if (exist('N')==0)
    N=5;
end

if (exist('ls')==0)
    ls=size(d,1);
end

if (exist('explInfluence')==0)
    explInfluence=0.5;
end

if (exist('stems')==0)
    detail=false;
else
    detail=true;
end

%%% aggiunge indice item nel titolo
%%titles(:,2)=titles(:,1);
%%titles(:,1)=num2str(1:size(titles,1));
%%%

display([titles(find(userProfile),:), num2str(userProfile(find(userProfile))')]);
display(['latent size=',num2str(ls)]);

d=d(1:ls,:); % inner product
dnorm = normalizeWordsMatrix(d,2); % cosine
dshrink= normalizeShrinkageWordsMatrix(d,shrinkage,2); % shrinked cosine

up = userProfile*dnorm';
upbck = up;

if (exist('explPref')~=0)
    km=km(1:ls,:);
    
%     explPrefProj=explPref*km';
%     
%     for ii=1:length(explPrefProj)
%        up(ii)=up(ii)*(1-explInfluence)+explInfluence*explPrefProj(ii);
%     end
   
    
    upp=up*km;

    toedit = find(explPref~=0);
    
    for ii=1:length(toedit) 
       thevalue=sign(explPref(toedit(ii))) * max([ abs(explPref(toedit(ii))), upp(toedit(ii))]);
       display([thevalue, upp(toedit(ii)), explPref(toedit(ii))]);
       upp(toedit(ii))=thevalue;
    end
    up=upp*km';

end

newup=normalizeWordsMatrix(up,1);
recDnorm=newup*dnorm;
[i,j]=sort(-recDnorm); i=-i;
[i,j]=filterViewed(i,j,userProfile);
display(' -- -- TUTTI i contenuti -- --');
display(' ==Item columns==');
display(num2str(j(1:N)));
% display(' ==Recommended-items predicted ratings==');
% display(i(1:N));
display(' ==Recommended items==');
titlesAndValues = titles(j(1:N),:);
titlesAndValues=[titlesAndValues,num2str(i(1:N)')];
display(titlesAndValues);

pause;
explainLSA (up,dnorm,ls,j(1:N),titles);

% % display(' -- -- Solo contenuti LIVE -- --');
% % [i,j] = filterLive(i,j);
% % j(1:N), -i(1:N), titles(j(1:N),:)

%% begin da rimuovere
return
%% end da rimuovere

newupSh=userProfile*dshrink';
recDnormShrink=newupSh*dshrink;
[i,j]=sort(-recDnormShrink); 
[i,j] = filterLive(i,j);
j(1:N), -i(1:N), titles(j(1:N),:)

if (exist('explPref')==0)
    return;
end

hei = explInfluence;
explProj=explPref*km';

maxup = (1-hei)*newup+hei*explProj;
maxup=normalizeWordsMatrix(maxup,1);
recDnorm=maxup*dnorm;
[i,j]=sort(-recDnorm); j(1:N), titles(j(1:N),:)

upbck=normalizeWordsMatrix(upbck,1);
upbck=(1-hei)*upbck+hei*explProj;
upbck=normalizeWordsMatrix(upbck,1);
recDnorm=upbck*dnorm;
[i,j]=sort(-recDnorm); j(1:N), titles(j(1:N),:)

if detail    
        disp('---');
%    [i,j]=sort(-recD); titles(j(1:N),:);
%    explain(icm,N,j,item,stems,titles);
%        disp('---');
    [i,j]=sort(-recDnorm); titles(j(1:N),:);
    
    return;
    %% DA IMPLEMENTARE %%
    
    explain(icm,N,j,item,stems,titles);
%        disp('---');
%    [i,j]=sort(-recDshrink); titles(j(1:N),:);
%    explain(icm,N,j,item,stems,titles);
end

end

function [] = explain (icm,N,j,item,stems,titles)
    for a=1:N
       % if (j(a)==item) continue; end
        disp(titles(j(a),:))
        disp(stems(find(icm(:,item)&icm(:,j(a))),:))
        disp(' ');
        pause
    end
end

function [ii,jj] = filterLive (i,j)
    if (~isempty(whos('global','liveItemId')))
        global liveItemId; 
        ee=0; jj=zeros(1,size(j,2)); ii=zeros(1,size(i,2));
        for eee=1:size(j,2), 
            if (ismember(j(eee),liveItemId(:,2))), 
                ee=ee+1;
                jj(ee)=j(eee); 
                ii(ee)=i(eee); 
            end; 
        end;
        if (ee>1) 
            jj=jj(1:ee);
            ii=ii(1:ee);
        else
            display('Check live items! Appear to be empty');
            ii=i; jj=j;
            return
        end
    else
        ii=i; jj=j;
    end
end

function [ii,jj] = filterViewed (i,j,userProfile)
    ee=0; jj=zeros(1,size(j,2)); ii=zeros(1,size(i,2));
    activeItems=find(userProfile);
    for eee=1:size(j,2), 
        if (~ismember(j(eee),activeItems)), 
            ee=ee+1;
            jj(ee)=j(eee); 
            ii(ee)=i(eee); 
        end; 
    end;    
end

function [explainingTxt] = explainLSA (up,dnorm,ls,itemsToExplain,titles)
    explainingTxt='';
    if (~isempty(whos('global','dictionary_stem')) && ~isempty(whos('global','dictionary_stemRow')) && ~isempty(whos('global','km')))
        global km dictionary_stem dictionary_stemRow;
        if (size(km,1)<size(km,2))
            warning ('check the global variable km');
        end
        upp=up*km(:,1:ls)';
        for itemIndex=1:length(itemsToExplain)
           itemPP(itemIndex,:)=dnorm(:,itemsToExplain(itemIndex))'*km(:,1:ls)';
           simVector=normalizeWordsMatrix(upp,1).*normalizeWordsMatrix(itemPP(itemIndex,:),1);
           display('');
           if nargin==5
               display(['-- explaining: ', titles(itemsToExplain(itemIndex),:), ' --']);
           end
           explainingTxt = strvcat(explainingTxt,displayStems(simVector,dictionary_stem,dictionary_stemRow,10));
        end 
        
        %% rimuovere per fare PLOT %%
        return;
        %% %%
        
        lss=50;
        [ii,jj]=sort(-abs(up));
        maxDnorm=dnorm(jj,:);
        maxUp=up(jj);
        maxKm=km(:,jj);
        % plot nello spazio SVD
        figure;
        pcolor([abs(normalizeWordsMatrix(maxUp(1:lss),1))' abs(maxDnorm(1:lss, itemsToExplain))]);
        [a,b]=max(abs(maxKm),[],1);
        textLabel = cell(1,lss);
        for i=1:lss-1
            textLabel{i}=dictionary_stem(find(dictionary_stemRow==b(i)),:);
        end
        set(gca,'YTick',1.5:1:lss-0.5);
        set(gca,'YTickLabel',textLabel,'fontsize',8);
        titleLabel = cell(1,length(itemsToExplain));
        titleLabel{1}='UserProfile';
        for i=1:length(itemsToExplain)-1
            titleLabel{i+1}=titles(itemsToExplain(i),:);
        end
        set(gca,'XTick',1.5:1:length(itemsToExplain)+0.5);
        set(gca,'XTickLabel',titleLabel);
        colorbar;
        
        % plot nello spazio degli stem
        [ii,jj]=sort(-upp);
        maxUpp=upp(jj);
        maxItemPP=itemPP(:,jj)';
        figure;
        pcolor([normalizeWordsMatrix(maxUpp(1:lss),1)' normalizeWordsMatrix(maxItemPP(1:lss,:),2)]);        
        set(gca,'XTick',1.5:1:length(itemsToExplain)+0.5);
        set(gca,'XTickLabel',titleLabel);
        textLabel = cell(1,lss);
        for i=1:lss-1
            textLabel{i}=dictionary_stem(find(dictionary_stemRow==jj(i)),:);
        end
        set(gca,'YTick',1.5:1:lss-0.5);
        set(gca,'YTickLabel',textLabel,'fontsize',8);     
        colorbar;
    end
end