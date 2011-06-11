function [j] = computeLSArecommendationLanguage(userProfile, titles,d,N,ls,km,explPref,explInfluence, icm, languageColumns)
% computeLSArecommendationLanguage(userProfile,
% titles,d,N,ls,km,explPref,explInfluence,languageArray)
%
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
% - icm = matrice icm (stems x items)
% - languageColumns = colonne della icm riguardanti la lingua, per forzare
% linguaggio item
%
% esempio di esecuzione:
% computeLSArecommendation(userProfile,titles,d,10,1,u',explPref,0.9,icm,stems);

shrinkage = 1;

if (exist('N')==0)
    N=5;
end

if (exist('ls')==0)
    ls=size(d,1);
end

if (exist('explInfluence')==0)
    explInfluence=0.5;
end

%%% aggiunge indice item nel titolo
%%titles(:,2)=titles(:,1);
%%titles(:,1)=num2str(1:size(titles,1));
%%%

languageArray=zeros(size(explPref));
if sum(spones(languageColumns))
    langItemCount = sum(spones(icm(languageColumns,find(userProfile))),2);
    languageArray(languageColumns)=langItemCount/max(langItemCount);
    languageArray=languageArray*.5;
end

%explPref(languageColumns)=languageArray(languageColumns);

titles(find(userProfile),:)

d=d(1:ls,:); % inner product
dnorm = normalizeWordsMatrix(d,2); % cosine
%dshrink= normalizeShrinkageWordsMatrix(d,shrinkage,2); % shrinked cosine

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

    toedit = find(languageArray~=0);
    
    for ii=1:length(toedit) 
       thevalue=sign(languageArray(toedit(ii))) * max([ abs(languageArray(toedit(ii))), upp(toedit(ii))]);
       display([thevalue, upp(toedit(ii)), languageArray(toedit(ii))]);
       upp(toedit(ii))=thevalue;
    end
    up=upp*km';

end

display('--solo language');
newup=normalizeWordsMatrix(up,1);
recDnorm=newup*dnorm;
[i,j]=sort(-recDnorm); j(1:N), titles(j(1:N),:)

display('--solo explPref');
hei = explInfluence;
explProj=explPref*km';

upbck=normalizeWordsMatrix(upbck,1);
explPrefUp = (1-hei)*upbck+hei*explProj;
explPrefUp=normalizeWordsMatrix(explPrefUp,1);
recDnorm=explPrefUp*dnorm;
[i,j]=sort(-recDnorm); j(1:N), titles(j(1:N),:)

display('--completo: language+explPref');
newup=(1-hei)*up+hei*explProj;
newup=normalizeWordsMatrix(newup,1);
recDnorm=newup*dnorm;
[i,j]=sort(-recDnorm); j(1:N), titles(j(1:N),:)

end