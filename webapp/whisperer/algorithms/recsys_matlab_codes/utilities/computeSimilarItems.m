function [] = computeSimilarItems(titles,d,item,N,ls,icm,stems)
% computeSimilarItems(titles,d,item,N,ls,icm,stems)
% Visualizza gli item simili ad uno dato, secondo un modello Content-based
%
% Attributi:
% - titles = vettore colonna con i titoli dei film
% - d = modello dell'algoritmo. In genere, x l'algoritmo LSA, d=s*v' (s e v
% derivano dalla SVD), oppure anche semplicente ICM (la memoria potrebbe 
% costituire un problema).
% - item = item di cui si vuole calcolare la similarità
% - N = numero di item simili ad 'item' che si vogliono estrarre
% - ls = latent size (dimensione latente della svd). Indica quante feature
% (cioè righe) considerare del modello d
%
% attributi OPZIONALI: 
% - icm = matrice ICM (stems x items)
% - stems =  vettore colonna con gli STEM
% se presenti sia 'icm' che 'stems', visualizza dettagli di correlazione di
% ogni coppia di item.
%
% esempio: computeSimilarItems(titles,d,304,10,140)
% esempio: computeSimilarItems(titles,d,304,10,140,icm,stems)

shrinkage = 1;

if (exist('N')==0)
    N=5;
end

if (exist('ls')==0)
    ls=size(d,1);
end

if (exist('stems')==0)
    detail=false;
else
    detail=true;
end

% aggiunge indice item nel titolo
%%titles(:,2)=titles(:,1);
%%titles(:,1)=num2str(1:size(titles,1));
%%%

titles(item,:)

d=d(1:ls,:); % inner product
dnorm = normalizeWordsMatrix(d,2); % cosine
dshrink= normalizeShrinkageWordsMatrix(d,shrinkage,2); % shrinked cosine

%recD=d(:,item)'*d;
recDnorm=dnorm(:,item)'*dnorm;
%recDshrink=dshrink(:,item)'*dshrink;

%[i,j]=sort(-recD); titles(j(1:N),:)
[i,j]=sort(-recDnorm); titles(j(1:N),:)
%[i,j]=sort(-recDshrink); titles(j(1:N),:)

if detail
        disp('---');
%    [i,j]=sort(-recD); titles(j(1:N),:);
%    explain(icm,N,j,item,stems,titles);
%        disp('---');
    [i,j]=sort(-recDnorm); titles(j(1:N),:);
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