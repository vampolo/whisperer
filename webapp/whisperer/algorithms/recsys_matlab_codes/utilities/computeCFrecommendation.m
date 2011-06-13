function [j,i] = computeCFrecommendation(userProfile, titles,onLineFunction,CFmodel,onLineParam,N,liveItemId)
% computeCFrecommendation(userProfile,
% titles,onLineFunction,CFmodel,onLineParam,N, [liveItemId])
%
% raccomanda item, secondo un modello Collaborativo
%
%
% Attributi:
% - userProfile = vettore riga con i rating dell'utente
% - titles = vettore colonna con i titoli dei film
% - onLineFunction = handle per funzione online di raccomandazione. Vedere
% documentazione della funzione per dettagli su CFmodel e onLineParam
% - CFmodel = modello collaborativo usato dalla funzione onLineFunction
% - onLineParam = parametri usati dalla funzione onLineFunction
% - N = numero di item simili ad 'item' che si vogliono estrarre
% - [liveItemId] = [OPTIONAL] numItemsx2 matrix of live item. Used to
% filter non-live items out of the profile.
%
% esempi:
% computeCFrecommendation(userProfileCF,
% ItemTitle_urm,@onLineRecom_sarwar,CFmodelSarwar,onLineParamSarwar,5);
%  userProfileCF=zeros(1,size(urm,2)); userProfileCF(2)=2.5;
%  CFmodelSarwar.vt=urm_v';
%  onLineParamSarwar.ls=300;
%
% computeCFrecommendation(userProfileCF,
% ItemTitle_urm,@onLineRecom_drII,CFmodelDR,onLineParamDR,5);
%  userProfileCF=zeros(1,size(urm,2)); userProfileCF(2)=2.5;
%  CFmodelDR.dr=urm'*urm;
%  onLineParamDR.knn=50;
%
% computeCFrecommendation(userProfileCF,
% ItemTitle_urm,@onLineRecom_cosineIIknn,CFmodelCOS,onLineParamCOS,5);
%  userProfileCF=zeros(1,size(urm,2)); userProfileCF(2)=2.5;
%  CFmodelCOS= feval(@createModel_cosineIIknn,urm);
%  onLineParamCOS.knn=50;

if (exist('N')==0)
    N=5;
end

display([char(titles(find(userProfile),:)), num2str(userProfile(find(userProfile))')]);
if (exist('onLineParam'))
    if (isstruct(onLineParam))
        display(['onLine Parameters=';struct2cell(onLineParam)]);
    end
end


if (exist('onLineParam')==0)
    recList = feval(onLineFunction,userProfile, CFmodel);
else
    if (isstruct(onLineParam))
        recList = feval(onLineFunction,userProfile, CFmodel,onLineParam);
    else
        recList = feval(onLineFunction,userProfile, CFmodel);
    end
end

[i,j]=sort(-recList); i=-i;
[i,j]=filterViewed(i,j,userProfile);
if (nargin>6)
    display(' -- -- Solo contenuti LIVE -- --');
    [i,j] = filterLive(i,j);
else
    display(' -- -- TUTTI i contenuti -- --');
end
display(' ==Item columns==');
display(num2str(j(1:N)));
% display(' ==Recommended-items predicted ratings==');
% display(i(1:N));
display(' ==Recommended items==');
titlesAndValues = char(titles(j(1:N),:));
titlesAndValues=[titlesAndValues,num2str(i(1:N)')];
display(titlesAndValues);

% % display(' -- -- Solo contenuti LIVE -- --');
% % [i,j] = filterLive(i,j);
% % j(1:N), -i(1:N), titles(j(1:N),:)


end


function [ii,jj] = filterLive (i,j)
    %if (~isempty(whos('global','liveItemId')))
    %    global liveItemId; 
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
    %else
    %    ii=i; jj=j;
    %end
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

