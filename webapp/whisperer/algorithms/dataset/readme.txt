The dataset is a subset of NETFLIX, with additional content information (mainly extracted from IMDB)

- urmFull: contains the ORIGINAL user rating matrix

- urmTraining: contains the TRAINING ratings (only the ratings related to half the items are used as training set)
- urmTest: contains the TEST ratings (5% of the full set of ratings are used as test set)

- icm: contains the item-content matrix
       in addition, it contains the dictionary, a struct where content information are available (e.g., the stem, the metadata type,...)

- titles: contains the item titles, in the same order as in the urm and in the icm columns




urmTraining and urmTest have been created started from the original 'user rating matrix' urm by the following code:

[r,c,v]=find(urm);
testSetIndex = randsample(length(r),ceil(length(r)*0.05));
urmTest=sparse(r(testSetIndex),c(testSetIndex),v(testSetIndex));
trainingSetIndex = setdiff(1:length(r),testSetIndex);
urmTrainingFull=sparse(r(trainingSetIndex),c(trainingSetIndex),v(trainingSetIndex));
subsetItemsForTraining = randsample(size(urm,2),ceil(size(urm,2)*0.5));
urmTraining=sparse(size(urmTrainingFull,1),size(urmTrainingFull,2));
urmTraining(:,subsetItemsForTraining)=urmTrainingFull(:,subsetItemsForTraining);


