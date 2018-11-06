close all;
clear all;
 
addpath('C:\Users\ZhangX1\Documents\MATLAB\cviParser');
InDir = 'C:/Users/ZhangX1/Documents/MATLAB/CNNTraining256/';
OutDir = 'C:/Users/ZhangX1/Documents/MATLAB/CNNTraining128/';

%%
% img_glob = glob(cat(2, InDir, 'TrainingData/*'));
% im = imread(img_glob{1});
% im_resize = imresize(im, [128, 128]);
% figure();
% imagesc(im)
% 
% figure();
% imagesc(im_resize)

%%
img_glob = glob(cat(2, InDir, 'TrainingData/*'));
if ~exist(cat(2, OutDir, 'TrainingData/'), 'dir')
    mkdir(cat(2, OutDir, 'TrainingData/'));
end
for i = 1:length(img_glob)
   im = imread(img_glob{i});
   strings = split(img_glob{i}, '\');
   fname = strings{end};
   im_resize = imresize(im, [128, 128]);
   imwrite(im_resize, cat(2, OutDir, 'TrainingData/', fname));
end

%%
img_glob = glob(cat(2, InDir, 'TestingData/*'));
if ~exist(cat(2, OutDir, 'TestingData/'), 'dir')
    mkdir(cat(2, OutDir, 'TestingData/'));
end
for i = 1:length(img_glob)
   im = imread(img_glob{i});
   strings = split(img_glob{i}, '\');
   fname = strings{end};
   im_resize = imresize(im, [128, 128]);
   imwrite(im_resize, cat(2, OutDir, 'TestingData/', fname));
end

%%
img_glob = glob(cat(2, InDir, 'TestingData/*'));
if ~exist(cat(2, OutDir, 'TestingData/'), 'dir')
    mkdir(cat(2, OutDir, 'TestingData/'));
end
for i = 1:length(img_glob)
   im = imread(img_glob{i});
   strings = split(img_glob{i}, '\');
   fname = strings{end};
   im_resize = imresize(im, [128, 128]);
   imwrite(im_resize, cat(2, OutDir, 'TestingData/', fname));
end

%%
img_glob = glob(cat(2, InDir, 'LabelData/*'));
if ~exist(cat(2, OutDir, 'LabelData/'), 'dir')
    mkdir(cat(2, OutDir, 'LabelData/'));
end
for i = 1:length(img_glob)
   im = imread(img_glob{i});
   strings = split(img_glob{i}, '\');
   fname = strings{end};
   im_resize = imresize(im, [128, 128]);
   imwrite(im_resize, cat(2, OutDir, 'LabelData/', fname));
end

%%
img_glob = glob(cat(2, InDir, 'LabelTest/*'));
if ~exist(cat(2, OutDir, 'LabelTest/'), 'dir')
    mkdir(cat(2, OutDir, 'LabelTest/'));
end
for i = 1:length(img_glob)
   im = imread(img_glob{i});
   strings = split(img_glob{i}, '\');
   fname = strings{end};
   im_resize = imresize(im, [128, 128]);
   imwrite(im_resize, cat(2, OutDir, 'LabelTest/', fname));
end