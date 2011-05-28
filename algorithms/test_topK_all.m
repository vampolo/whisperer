function [] = test_topK_all (urmTraining,urmTest,icm,testPercentage,mode)
% function [] = test_topK_all (urmTraining,urmTest,icm,testPercentage,mode)
% 
% urmTraining = training ratings
% urmTest = test ratings
% icm = item content matrix
% testPercentage = percentage of the test ratings that is to be tested
% mode = {'recall','fallout'}
%
% e.g.,
% test_topK_all(urmTraining,urmTest,icm,0.5,'recall');

%% param check
if (nargin<5)
    help test_topK_all;
    return;
end

if ischar(mode)
    if ~(strcmpi(mode,'recall') || strcmpi(mode,'fallout'))
        error('mode can be either ''recall'' or ''fallout''');
    end
else
    error('mode can be either ''recall'' or ''fallout''');
end

%% test set extraction
addpath(genpath('algorithms'));
addpath(genpath('utilities'));
addpath(genpath('testing'));

    display(['starting ', mode, ' tests']);
    if strcmpi(mode,'recall')
        [a,b]=find(urmTest==5); %recall
    else
        [a,b]=find(urmTest==1); %fallout
    end

    testSet=sparse(a,b,1);
    display(['size testSet=',num2str(nnz(testSet))]);

    [positiveTestsetReturn,negativeTestsetReturn]=extractTestSets (testSet,testPercentage,-1);

%% starting tests

%%    
%%%%%% MOVIE AVERAGE (non-personalized)
disp(' started MovieAvg');

    algoName = 'MovieAVG';
    fileNameRANK = ['rank',mode,algoName,'_','','.mat'];    
    if fileExist(fileNameRANK) load(fileNameRANK); end 
    
    onlineParamMovieAVG.postProcessingFunction=@keep1000randomItems;
    onlineParamMovieAVG.filterViewedItems=true;
    tic
    [positiveTests,negativeTests]=leaveOneOut('algorithms/non-personalized/movieAvg', @createModel_movieAvg, @onLineRecom_movieAvg,urmTraining,urmTraining,positiveTestsetReturn,negativeTestsetReturn,[],onlineParamMovieAVG);
    eval([ '[rank',mode,algoName,'',']=computeRank(positiveTests);' ]); 
    save(fileNameRANK,['rank',mode,algoName,'*']);
    toc

%%
%%%%%% TOP RATED
disp(' started TopRated');

    algoName = 'TopRated';
    fileNameRANK = ['rank',mode,algoName,'_','','.mat'];
    if fileExist(fileNameRANK) load(fileNameRANK); end 

    onlineParamTopRated.postProcessingFunction=@keep1000randomItems;
    onlineParamTopRated.filterViewedItems=true;
    tic
    [positiveTests,negativeTests]=leaveOneOut('algorithms/non-personalized/topRated', @createModel_toprated, @onLineRecom_toprated,urmTraining,urmTraining,positiveTestsetReturn,negativeTestsetReturn,1,onlineParamTopRated);
    eval([ '[rank',mode,algoName,'',']=computeRank(positiveTests);' ]); 
    save(fileNameRANK,['rank',mode,algoName,'*']);
    toc


%%
%%%%%% LSA 
disp(' started LSA');

    algoName = 'LSA';
    fileNameRANK = ['rank',mode,algoName,'_','','.mat'];
    if fileExist(fileNameRANK) load(fileNameRANK); end 

    onlineParamLSA.postProcessingFunction=@keep1000randomItems;
    onlineParamLSA.filterViewedItems=true;
    modelParamLSA.icm=icm;
    modelParamLSA.ls=50;
    tic
    [positiveTests,negativeTests]=leaveOneOut('algorithms/content-based/lsaCosine', @createModel_lsaCosine, @onLineRecom_lsa_NNCosine,urmTraining,urmTraining,positiveTestsetReturn,negativeTestsetReturn,modelParamLSA,onlineParamLSA);
    eval([ '[rank',mode,algoName,'',']=computeRank(positiveTests);' ]); 
    save(fileNameRANK,['rank',mode,algoName,'*']);
    toc    
    

%%    
%%%%%%% NNCosNgbr
disp(' started NNCOSNgbr knn');  

    knnn=[50 200];

    algoName = 'COS';
    fileNameRANK = ['rank',mode,algoName,'_','','.mat'];
    if fileExist(fileNameRANK) load(fileNameRANK); end 
    
    onlineParamCOS.postProcessingFunction=@keep1000randomItems;
    onlineParamCOS.filterViewedItems=true;
for i=1:length(knnn)
    tic
    modelCOS.knn=knnn(i)
    [positiveTests,negativeTests]=leaveOneOut('algorithms/collaborative/neighborhoodBased/ItemItem_cosineKNN', @createModel_cosineIIknn, @onLineRecom_NNCosNgbr_II_knn,urmTraining,urmTraining,positiveTestsetReturn,negativeTestsetReturn,modelCOS,onlineParamCOS);
    eval([ '[rank',mode,algoName,'',']=computeRank(positiveTests);' ]); 
    save(fileNameRANK,['rank',mode,algoName,'*']);    
    toc
end


%%    
%%%%%%% AsySVD
disp(' started AsySVD');  

    lss=[50];

    algoName = 'AsySVD';
    fileNameRANK = ['rank',mode,algoName,'_','','.mat'];
    if fileExist(fileNameRANK) load(fileNameRANK); end 
    
    onlineParamAsySVD.postProcessingFunction=@keep1000randomItems;
    onlineParamAsySVD.filterViewedItems=true;
for i=1:length(lss)
    tic
    modelAsySVD.ls=lss(i)
    %modelAsySVD.iterations=1;
    [positiveTests,negativeTests]=leaveOneOut('algorithms/collaborative/latentFactors/AsySVD', @createModel_AsySVD, @onLineRecom_AsySVD,urmTraining,urmTraining,positiveTestsetReturn,negativeTestsetReturn,modelAsySVD,onlineParamAsySVD);
    eval([ '[rank',mode,algoName,'',']=computeRank(positiveTests);' ]); 
    save(fileNameRANK,['rank',mode,algoName,'*']);     
    toc
end


%%
%%%%%%%% LOAD and PLOT
fdir=dir('rank*.mat');
for ff=1:length(fdir); load(fdir(ff).name); end
cdfplotRecallallRank;
ylabel(mode);
xlabel('N');

end