clear all;
close all;

addpath('C:\Users\ZhangX1\Documents\MATLAB\cviParser');
InDir = 'C:/Users/ZhangX1/Documents/MATLAB/CNNTraining/';
OutDir = 'C:/Users/ZhangX1/Documents/MATLAB/CNNTrainingCrop64/';

load(fullfile(InDir, 'centroids.mat'));

%%
x = round(centroids{1}(1));
y = round(centroids{1}(2));
img_glob = glob(cat(2, InDir, 'TrainingDataTotal/*'));
im = imread(img_glob{1});
im_crop = imcrop(im, [x-32, y-32, 64, 64]); % [xmin ymin width height]
figure();
imagesc(im)

figure();
imagesc(im_crop)

% im_crop2 = imcrop(im, [y-32, x-32, 64, 64]); % [xmin ymin width height]
% figure();
% imagesc(im_crop2)
% This is not correct
%%
img_glob = glob(cat(2, InDir, 'TrainingDataTotal/*'));
if ~exist(cat(2, OutDir, 'TrainingDataTotal/'), 'dir')
    mkdir(cat(2, OutDir, 'TrainingDataTotal/'));
end
for i = 1:length(img_glob)

   idx_array = zeros(length(img_glob), 1);
   
   for j = 1:length(img_glob)
       B = regexp(img_glob(j),'\d*','Match');
       
       for ii= 1:length(B)
           if ~isempty(B{ii})
               Num(ii,1)=str2double(B{ii}(end));
           else
               Num(ii,1)=NaN;
           end
       end
       % fprintf('%d\n', Num)
       idx_array(j) = Num;
   end
   
   im = imread(img_glob{i});
   strings = split(img_glob{i}, '\');
   fname = strings{end};
   
   x = round(centroids{idx_array(i)}(1));
   y = round(centroids{idx_array(i)}(2));
   
   im_crop = imcrop(im, [x-32, y-32, 63, 63]);
   imwrite(im_crop, cat(2, OutDir, 'TrainingDataTotal/', fname));
end

%% Null Backrground
img_glob = glob(cat(2, InDir, 'NulBkgdTrainingTotal/*'));
if ~exist(cat(2, OutDir, 'NulBkgdTrainingTotal/'), 'dir')
    mkdir(cat(2, OutDir, 'NulBkgdTrainingTotal/'));
end
idx_array = GetGlobIndex(img_glob);
for i = 1:length(img_glob)

   im = imread(img_glob{i});
   strings = split(img_glob{i}, '\');
   fname = strings{end};
   
   x = round(centroids{idx_array(i)}(1));
   y = round(centroids{idx_array(i)}(2));
   
   im_crop = imcrop(im, [x-32, y-32, 63, 63]);
   imwrite(im_crop, cat(2, OutDir, 'NulBkgdTrainingTotal/', fname));
end

%%
img_glob = glob(cat(2, InDir, 'LabelDataTotal/*'));
if ~exist(cat(2, OutDir, 'LabelDataTotal/'), 'dir')
    mkdir(cat(2, OutDir, 'LabelDataTotal/'));
end
idx_array = GetGlobIndex(img_glob);
for i = 1:length(img_glob)

   im = imread(img_glob{i});
   strings = split(img_glob{i}, '\');
   fname = strings{end};
   
   x = round(centroids{idx_array(i)}(1));
   y = round(centroids{idx_array(i)}(2));
   
   im_crop = imcrop(im, [x-32, y-32, 63, 63]);
   imwrite(im_crop, cat(2, OutDir, 'LabelDataTotal/', fname));
end
%% To have heart label (for test)
img_glob = glob(cat(2, InDir, 'HeartLabelTotal/*'));
if ~exist(cat(2, OutDir, 'HeartLabelTotal/'), 'dir')
    mkdir(cat(2, OutDir, 'HeartLabelTotal/'));
end
idx_array = GetGlobIndex(img_glob);
for i = 1:length(img_glob)

   im = imread(img_glob{i});
   strings = split(img_glob{i}, '\');
   fname = strings{end};
   
   x = round(centroids{idx_array(i)}(1));
   y = round(centroids{idx_array(i)}(2));
   
   im_crop = imcrop(im, [x-32, y-32, 63, 63]);
   imwrite(im_crop, cat(2, OutDir, 'HeartLabelTotal/', fname));
end

%% CompositeLabelTotal
img_glob = glob(cat(2, InDir, 'CompositeLabelTotal/*'));
if ~exist(cat(2, OutDir, 'CompositeLabelTotal/'), 'dir')
    mkdir(cat(2, OutDir, 'CompositeLabelTotal/'));
end
idx_array = GetGlobIndex(img_glob);
for i = 1:length(img_glob)

   im = imread(img_glob{i});
   strings = split(img_glob{i}, '\');
   fname = strings{end};
   
   x = round(centroids{idx_array(i)}(1));
   y = round(centroids{idx_array(i)}(2));
   
   im_crop = imcrop(im, [x-32, y-32, 63, 63]);
   imwrite(im_crop, cat(2, OutDir, 'CompositeLabelTotal/', fname));
end

%% CompositeLabelTotal 2
img_glob = glob(cat(2, InDir, 'CompositeLabelTotal2/*'));
if ~exist(cat(2, OutDir, 'CompositeLabelTotal2/'), 'dir')
    mkdir(cat(2, OutDir, 'CompositeLabelTotal2/'));
end
idx_array = GetGlobIndex(img_glob);
for i = 1:length(img_glob)

   im = imread(img_glob{i});
   strings = split(img_glob{i}, '\');
   fname = strings{end};
   
   x = round(centroids{idx_array(i)}(1));
   y = round(centroids{idx_array(i)}(2));
   
   im_crop = imcrop(im, [x-32, y-32, 63, 63]);
   imwrite(im_crop, cat(2, OutDir, 'CompositeLabelTotal2/', fname));
end

%% Allocate to crop64
load(fullfile(InDir, 'randperm_5groups.mat'))
img_glob = glob(cat(2, OutDir, 'TrainingDataTotal/*'));
test_glob = img_glob(randperm_5groups.indexToGroup1);
train_glob = img_glob(~randperm_5groups.indexToGroup1);
if ~exist(cat(2, OutDir, 'TrainingData/'), 'dir')
    mkdir(cat(2, OutDir, 'TrainingData/'));
end

for i = 1:length(train_glob)
    copyfile(train_glob{i}, cat(2, OutDir, 'TrainingData/'));
end


if ~exist(cat(2, OutDir, 'TestingData/'), 'dir')
    mkdir(cat(2, OutDir, 'TestingData/'));
end

for i = 1:length(test_glob)
    copyfile(test_glob{i}, cat(2, OutDir, 'TestingData/'));
end

%% Allocate to crop64 (Null Background)
load(fullfile(InDir, 'randperm_5groups.mat'))
img_glob = glob(cat(2, OutDir, 'NulBkgdTrainingTotal/*'));
test_glob = img_glob(randperm_5groups.indexToGroup1);
train_glob = img_glob(~randperm_5groups.indexToGroup1);
if ~exist(cat(2, OutDir, 'NulBkgdTrainingData/'), 'dir')
    mkdir(cat(2, OutDir, 'NulBkgdTrainingData/'));
end

for i = 1:length(train_glob)
    copyfile(train_glob{i}, cat(2, OutDir, 'NulBkgdTrainingData/'));
end


if ~exist(cat(2, OutDir, 'NulBkgdTestingData/'), 'dir')
    mkdir(cat(2, OutDir, 'NulBkgdTestingData/'));
end

for i = 1:length(test_glob)
    copyfile(test_glob{i}, cat(2, OutDir, 'NulBkgdTestingData/'));
end

%% Labels
load(fullfile(InDir, 'randperm_5groups.mat'))
img_glob = glob(cat(2, OutDir, 'LabelDataTotal/*'));
test_glob = img_glob(randperm_5groups.indexToGroup1);
train_glob = img_glob(~randperm_5groups.indexToGroup1);
if ~exist(cat(2, OutDir, 'LabelData/'), 'dir')
    mkdir(cat(2, OutDir, 'LabelData/'));
end

for i = 1:length(train_glob)
    copyfile(train_glob{i}, cat(2, OutDir, 'LabelData/'));
end


if ~exist(cat(2, OutDir, 'LabelTest/'), 'dir')
    mkdir(cat(2, OutDir, 'LabelTest/'));
end

for i = 1:length(test_glob)
    copyfile(test_glob{i}, cat(2, OutDir, 'LabelTest/'));
end

%% To have heart label (for test)
load(fullfile(InDir, 'randperm_5groups.mat'))
img_glob = glob(cat(2, OutDir, 'HeartLabelTotal/*'));
test_glob = img_glob(randperm_5groups.indexToGroup1);
train_glob = img_glob(~randperm_5groups.indexToGroup1);
if ~exist(cat(2, OutDir, 'HeartLabel/'), 'dir')
    mkdir(cat(2, OutDir, 'HeartLabel/'));
end

for i = 1:length(train_glob)
    copyfile(train_glob{i}, cat(2, OutDir, 'HeartLabel/'));
end


if ~exist(cat(2, OutDir, 'HeartLabelTest/'), 'dir')
    mkdir(cat(2, OutDir, 'HeartLabelTest/'));
end

for i = 1:length(test_glob)
    copyfile(test_glob{i}, cat(2, OutDir, 'HeartLabelTest/'));
end

%% To have composite label (for test)
load(fullfile(InDir, 'randperm_5groups.mat'))
img_glob = glob(cat(2, OutDir, 'CompositeLabelTotal/*'));
test_glob = img_glob(randperm_5groups.indexToGroup1);
train_glob = img_glob(~randperm_5groups.indexToGroup1);
if ~exist(cat(2, OutDir, 'CompositeLabel/'), 'dir')
    mkdir(cat(2, OutDir, 'CompositeLabel/'));
end

for i = 1:length(train_glob)
    copyfile(train_glob{i}, cat(2, OutDir, 'CompositeLabel/'));
end


if ~exist(cat(2, OutDir, 'CompositeLabelTest/'), 'dir')
    mkdir(cat(2, OutDir, 'CompositeLabelTest/'));
end

for i = 1:length(test_glob)
    copyfile(test_glob{i}, cat(2, OutDir, 'CompositeLabelTest/'));
end

%% To have composite label2 (for test)
load(fullfile(InDir, 'randperm_5groups.mat'))
img_glob = glob(cat(2, OutDir, 'CompositeLabelTotal2/*'));
test_glob = img_glob(randperm_5groups.indexToGroup1);
train_glob = img_glob(~randperm_5groups.indexToGroup1);
if ~exist(cat(2, OutDir, 'CompositeLabel2/'), 'dir')
    mkdir(cat(2, OutDir, 'CompositeLabel2/'));
end

for i = 1:length(train_glob)
    copyfile(train_glob{i}, cat(2, OutDir, 'CompositeLabel2/'));
end


if ~exist(cat(2, OutDir, 'CompositeLabelTest2/'), 'dir')
    mkdir(cat(2, OutDir, 'CompositeLabelTest2/'));
end

for i = 1:length(test_glob)
    copyfile(test_glob{i}, cat(2, OutDir, 'CompositeLabelTest2/'));
end