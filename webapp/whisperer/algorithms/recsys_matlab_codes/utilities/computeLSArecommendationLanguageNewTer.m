function [outR,out1,out2,out3] = computeLSArecommendationLanguageNewTer(userProfile, titles,d,N,ls,km, languageColumns, stems,icm,explPref,explInfluence)
% computeLSArecommendationLanguageNewTer(userProfile, titles,d,N,ls,km,explPref, 
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

if nargin>8
    outR=showTitles(titles,find(userProfile),languageColumns,stems,icm);
else
    outR=showTitles(titles,find(userProfile));
end

d=d(1:ls,:); % inner product
dnorm = normalizeShrinkageWordsMatrix(d,shrinkage,2); % cosine
%dshrink= normalizeShrinkageWordsMatrix(d,shrinkage,2); % shrinked cosine

if (exist('explPref')~=0)
    km=km(1:ls,:);
    
%     explPrefProj=explPref*km';
%     
%     for ii=1:length(explPrefProj)
%        up(ii)=up(ii)*(1-explInfluence)+explInfluence*explPrefProj(ii);
%     end
   
    

end


%display('--raccomandazione originale (senza expl pref)');
%recOrig = normalizeWordsMatrix(userProfile,1)*dnorm'*dnorm;

userProfileLSA = userProfile*dnorm';
if nargin>9
    userProfileLSA = applyExpliticPref (userProfileLSA, explPref,explInfluence,km);
end

recOrig = normalizeShrinkageWordsMatrix(userProfileLSA,shrinkage,1)*dnorm;
[i,j]=sort(-recOrig); j(1:N); 
if nargin>8
    out1=showTitles(titles,j(1:N),languageColumns,stems,icm);
else
    out1=showTitles(titles,j(1:N));
end

% display('--raccomandazione corretta (senza expl pref)');
% negativeRatings = find(userProfile<0);
% dNew=d;
% if (length(negativeRatings)>0)
%     dColsToModify = d(:,negativeRatings); % colonne di ItemProj che devono essere modificate perché si riferiscono a rating negativi
%     metadataSpaceDColsToModify = km'*dColsToModify; %dColstoModify proiettata nello spazio degli stemmi
%     metadataSpaceDColsToModify(languageColumns,:)=-metadataSpaceDColsToModify(languageColumns,:); %cambia segno ai metadati characterizing
%     dColsModified = km*metadataSpaceDColsToModify;
%     dNew(:,negativeRatings)=dColsModified; 
% end
% %rec=userProfile*dNew'*dNew;
% rec=normalizeWordsMatrix(userProfile,1)*dNew'*dNew;
% [i,j]=sort(-rec); j(1:N), titles(j(1:N),:)
% 
% display('--raccomandazione corretta shrinked normalized (senza expl pref)');
% dNewNorm=normalizeShrinkageWordsMatrix(dNew,0,2);
% recNorm = normalizeWordsMatrix(userProfile,1)*dNewNorm'*dNewNorm;
% [i,j]=sort(-recNorm); j(1:N), titles(j(1:N),:)


if isempty(languageColumns)
    out2='';
    out3='';
    return;
end


%display('--NUOVO METODO: ABS--');
km_s=km; km_s(:,languageColumns)=0;
km_c=sparse(size(km,1),size(km,2)); km_c(:,languageColumns)=km(:,languageColumns);

kms=km*km_s';
kmc=km*km_c';

%userProfileShifted = userProfile;
%userProfileShifted(find(userProfileShifted)) = userProfileShifted(find(userProfileShifted));
userProfileLSA = userProfile*(kms*dnorm)'...
                 + abs(userProfile)*(kmc*dnorm)';
             
if nargin>9
    userProfileLSA = applyExpliticPref (userProfileLSA, explPref,explInfluence,km);
end            


rec=normalizeShrinkageWordsMatrix(userProfileLSA,shrinkage,1)*dnorm;
[i,j]=sort(-rec); j(1:N);
if nargin>8
    out2=showTitles(titles,j(1:N),languageColumns,stems,icm);
else
    out2=showTitles(titles,j(1:N));
end


%display('--NUOVO METODO: SPONES--');
km_s=km; km_s(:,languageColumns)=0;
km_c=sparse(size(km,1),size(km,2)); km_c(:,languageColumns)=km(:,languageColumns);

kms=km*km_s';
kmc=km*km_c';

%userProfileShifted = userProfile;
%userProfileShifted(find(userProfileShifted)) = userProfileShifted(find(userProfileShifted));
userProfileLSA = userProfile*(kms*dnorm)'...
                 + spones(userProfile)*(kmc*dnorm)';
             
if nargin>9
    userProfileLSA = applyExpliticPref (userProfileLSA, explPref,explInfluence,km);
end


rec=normalizeShrinkageWordsMatrix(userProfileLSA,shrinkage,1)*dnorm;
[i,j]=sort(-rec); j(1:N); 
if nargin>8
    out3=showTitles(titles,j(1:N),languageColumns,stems,icm);
else
    out3=showTitles(titles,j(1:N));
end


end


function [modUserProfileLSA] = applyExpliticPref (userProfileLSA, explicitPref,explInfluence,km)
    explPrefLSA = explicitPref*km';
    modUserProfileLSA = (1-explInfluence)*userProfileLSA + explInfluence*explPrefLSA;
end    

function [outTxt] = showTitles (titles, indexes, languageColumns, stems,icm)
    outTxt='';
    if nargin>4
        for i=1:length(indexes)
           if iscell(stems)
                outTxt=strvcat(outTxt,([strcat(titles(indexes(i),:)),'  (',cell2mat(stems(intersect(find(icm(:,indexes(i))),languageColumns))'),')']));
           else
               outTxt=strvcat(outTxt,([strcat(titles(indexes(i),:)),'  (',(stems(intersect(find(icm(:,indexes(i))),languageColumns))'),')']));
           end
        end
    else
        outTxt=titles(indexes,:);
    end
end