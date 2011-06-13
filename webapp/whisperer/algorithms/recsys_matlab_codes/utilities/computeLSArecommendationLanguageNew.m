function [j] = computeLSArecommendationLanguageNew(userProfile, titles,d,N,ls,km,explPref,explInfluence, icm, languageColumns)
% computeLSArecommendationLanguageNew(userProfile, titles,d,N,ls,km,explPref, 
% explInfluence, icm, languageColumns)
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
% computeLSArecommendationLanguageNew(userProfile,titles,d,10,1,u',explPref,0.9,icm,stems);

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

titles(find(userProfile),:)

d=d(1:ls,:); % inner product
dnorm = normalizeWordsMatrix(d,2); % cosine
%dshrink= normalizeShrinkageWordsMatrix(d,shrinkage,2); % shrinked cosine

if (exist('explPref')~=0)
    km=km(1:ls,:);
    
%     explPrefProj=explPref*km';
%     
%     for ii=1:length(explPrefProj)
%        up(ii)=up(ii)*(1-explInfluence)+explInfluence*explPrefProj(ii);
%     end
   
    

end


display('--raccomandazione originale (senza expl pref)');
recOrig = normalizeWordsMatrix(userProfile,1)*dnorm'*dnorm;
[i,j]=sort(-recOrig); j(1:N), titles(j(1:N),:)

display('--raccomandazione corretta (senza expl pref)');
icmCharact = icm(languageColumns,:);
negativeUserProfile = userProfile;
negativeUserProfile(find(negativeUserProfile>0))=0;
dChar=zeros(size(dnorm));
if (~isempty(find(negativeUserProfile)))
    dChar(:,find(negativeUserProfile)) = ((-icmCharact(:,find(negativeUserProfile))')*km(:,languageColumns)')';
end
dNew=d+2*dChar;
rec=userProfile*dNew'*dNew;
[i,j]=sort(-rec); j(1:N), titles(j(1:N),:)

display('--raccomandazione corretta shrinked normalized (senza expl pref)');
dNewNorm=normalizeShrinkageWordsMatrix(dNew,15,2);
recNorm = normalizeWordsMatrix(userProfile,1)*dNewNorm'*dNewNorm;
[i,j]=sort(-recNorm); j(1:N), titles(j(1:N),:)

end