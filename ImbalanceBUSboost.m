%% Classification with imbalanced data
clear all;
close all;

%% Obtain the data
% Import the data into your workspace. Extract the last data column into a
% variable name Y

gunzip('http://archive.ics.uci.edu/ml/machine-learning-databases/covtype/covtype.data.gz')
load covtype.data
Y = covtype(:,end);
covtype(:,end) = [];

%% Examine the response data
tabulate(Y)

%% Partition the data for quality assessment
% Use half the data to fit a classifier, and half to examine the quality of
% the resulting classfier

rng(10,'twister')         % For reproducibility
part = cvpartition(Y,'Holdout',0.5);
istrain = training(part); % Data for fitting
istest = test(part);      % Data for quality assessment
tabulate(Y(istrain))

%% Create the ensemble
% Use deep trees for higher ensemble accuracy. To do so, set the trees to
% have maximal number of decision splits of N, where N is the Number of
% observations in the training sample. Set LearnRate to 0.1 in order to
% achieve higher accuracy as well. The data is large, and with deep trees,
% creating the ensemble is time consuming.

N = sum(istrain);         % Number of observations in the training sample
t = templateTree('MaxNumSplits',N);
tic
rusTree = fitcensemble(covtype(istrain,:),Y(istrain),'Method','RUSBoost', ...
    'NumLearningCycles',1000,'Learners',t,'LearnRate',0.1,'nprint',100);
toc

%% Inspect the classification error
figure;
tic
plot(loss(rusTree,covtype(istest,:),Y(istest),'mode','cumulative'));
toc
grid on;
xlabel('Number of trees');
ylabel('Test classification error');

%% Examine the confution matrix of each class as a percentage of the true class

tic
Yfit = predict(rusTree,covtype(istest,:));
toc
tab = tabulate(Y(istest));
bsxfun(@rdivide,confusionmat(Y(istest),Yfit),tab(:,2))*100

%% Compact the ensemble
% The ensemble is large. Remove the data using the compact method

cmpctRus = compact(rusTree);

sz(1) = whos('rusTree');
sz(2) = whos('cmpctRus');
[sz(1).bytes sz(2).bytes]

% The compacted ensemble is about half the size of the original
% Remove half the trees from cmpctRus. This action is likely to have
% minimal effect on the predictive performance, based on the observation
% that 500 out of 1000 trees give nearly optimal accuracy
cmpctRus = removeLearners(cmpctRus,[500:1000]);

sz(3) = whos('cmpctRus');
sz(3).bytes

% The reduced compact ensemble takes about a quarter of the memory of the
% full ensemble. Its overall loss rate is under 19%
L = loss(cmpctRus,covtype(istest,:),Y(istest))