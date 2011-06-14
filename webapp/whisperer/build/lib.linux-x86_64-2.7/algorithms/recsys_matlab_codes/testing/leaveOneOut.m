function [positiveTests,negativeTests]=leaveOneOut(algoPath, modelFunction, onLineFunction,urm,urmTrain,positiveTestset,negativeTestset,modelParam,onlineParam)
% function [testedUsers]=leaveOneOut
% (algoPath,urm,urmTrain,positiveTestset,negativeTestset,metricPath,modelParam,onlineParam,metricParam)
% 
% - algoPath = path of algorithm functions
% - modelFunction and onLineFunction = algorithms path,where createModel.m and onLineRecom.m are saved
% - urm = matrix users x items
% - urmTrain = matrix used to train the model. It can correspond to urm
% - positivbeTestset = positive testsets, i.e., the
% indexes of ratings (pairs of user-item) to test. testsetPath must contain
% two test set. They are computed by means of extractTestSets.m function
% and have a struct format. positiveTestset.i and positiveTestset.j are the
% row and column indeces
% - negativeTestset
% - parameters of the algorithm (model and online) and of the metric. The
% format of each parameter is a struct
% !NB!: if modelParam.builtinModel exists, then the test uses the model embedded in this FIELD 

addpath(algoPath);

%popolarity=full(sum(spones(urm),1));

if (exist('modelParam')==0 || (nargin(modelFunction)<2))
    model = feval(modelFunction,urmTrain);
else
    if isfield(modelParam,'builtinModel') 
        model = modelParam.builtinModel;
    else
        model = feval(modelFunction,urmTrain,modelParam);
    end
end


%%positiveTests = struct{'item','user','pos','rating'};
%%negativeTests = struct{'item','user','pos','rating'};

% positive instances
if (exist('onlineParam')==0)
    positiveTests = buildVectorTest(positiveTestset,urm,model,onLineFunction);
    negativeTests = buildVectorTest(negativeTestset,urm,model,onLineFunction);
elseif (isstruct(onlineParam))
    positiveTests = buildVectorTest(positiveTestset,urm,model,onLineFunction,onlineParam);
    negativeTests = buildVectorTest(negativeTestset,urm,model,onLineFunction,onlineParam);
else 
    positiveTests = buildVectorTest(positiveTestset,urm,model,onLineFunction);
    negativeTests = buildVectorTest(negativeTestset,urm,model,onLineFunction);    
end

rmpath(algoPath);

end


function [vectorTest] = buildVectorTest(testset,urm,model,onLineFunction,onlineParam)
if isempty(testset.i)
    vectorTest =[];
    return
end
refTime=tic;
vectorTest(length(testset.i)).rating=-1;
for test=1:length(testset.i)
    user=testset.i(test);
    item=testset.j(test);
    vettoreActiveUser = urm(user,:);
    vettoreActiveUser(item) = 0;
    viewedItems = find(vettoreActiveUser);
    if (length(viewedItems)<2)
        vectorTest(test).item=item;
        vectorTest(test).user=user;
        vectorTest(test).pos=1000;
        vectorTest(test).rating=-1;
       continue; 
    end
    %if (exist('onlineParam')==0)
    %    recList = feval(onLineFunction,vettoreActiveUser, model);
    %else
        onlineParam.userToTest=user;
        onlineParam.itemToTest=item;
        onlineParam.viewedItems=viewedItems;
        recList = feval(onLineFunction,vettoreActiveUser, model,onlineParam);
    %end
    recList(viewedItems) = -inf;
    [rows,cols]=sort(-recList);
    pos = find(cols==item);
    rating = recList(item);
    vectorTest(test).item=item;
    vectorTest(test).user=user;
    vectorTest(test).pos=pos;
    vectorTest(test).rating=rating;
    if (mod(test,100)==0)
        %save tmp vectorTest;
        displayRemainingTime(test, length(testset.i),refTime);
    end
end
end