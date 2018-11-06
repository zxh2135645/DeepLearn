clear all;
close all;

addpath('C:\Users\ZhangX1\Documents\MATLAB\cviParser\');
addpath('C:\Users\ZhangX1\Documents\MATLAB\InfarctDetector\');

BaseDir = 'C:/Users/ZhangX1/Documents/MATLAB/CNNTrainingCrop64/';

%% 
TargetFolder = 'LabelData';

file_glob = glob(fullfile(BaseDir, TargetFolder, '*'));
OutDir = cat(2, BaseDir, TargetFolder, '_Visualize/');
if ~exist(OutDir, 'dir')
    mkdir(OutDir);
end

for i = 1:length(file_glob)
    im = imread(file_glob{i});
    strings = split(file_glob{i}, '\');
    fname = strings{end};
    
    im2 = zeros(size(im));
    im2(im == 1) = 0;
    im2(im == 2) = 255;
    im2 = uint8(im2);
    imwrite(im2, cat(2, BaseDir, TargetFolder, '_Visualize/', fname));
    
end

%% Prediction
TargetFolder = 'LabelPred';

file_glob = glob(fullfile(BaseDir, TargetFolder, '*'));
OutDir = cat(2, BaseDir, TargetFolder, '_Visualize/');
if ~exist(OutDir, 'dir')
    mkdir(OutDir);
end

for i = 1:length(file_glob)
    im = imread(file_glob{i});
    strings = split(file_glob{i}, '\');
    fname = strings{end};
    
    im2 = zeros(size(im));
    im2(im == 1) = 0;
    im2(im == 2) = 255;
    im2 = uint8(im2);
    imwrite(im2, cat(2, BaseDir, TargetFolder, '_Visualize/', fname));
    
end

%% Prediction
TargetFolder = 'HeartLabelPred';

file_glob = glob(fullfile(BaseDir, TargetFolder, '*'));
OutDir = cat(2, BaseDir, TargetFolder, '_Visualize/');
if ~exist(OutDir, 'dir')
    mkdir(OutDir);
end

for i = 1:length(file_glob)
    im = imread(file_glob{i});
    strings = split(file_glob{i}, '\');
    fname = strings{end};
    
    im2 = zeros(size(im));
    im2(im == 1) = 0;
    im2(im == 2) = 255;
    im2 = uint8(im2);
    imwrite(im2, cat(2, BaseDir, TargetFolder, '_Visualize/', fname));
    
end

%% Prediction composite
TargetFolder = 'CompositeLabelPred';

file_glob = glob(fullfile(BaseDir, TargetFolder, '*'));
OutDir = cat(2, BaseDir, TargetFolder, '_Visualize/');
if ~exist(OutDir, 'dir')
    mkdir(OutDir);
end

for i = 1:length(file_glob)
    im = imread(file_glob{i});
    strings = split(file_glob{i}, '\');
    fname = strings{end};
    
    im2 = zeros(size(im));
    im2(im == 1) = 85;
    im2(im == 2) = 170;
    im2(im == 3) = 255;
    im2 = uint8(im2);
    imwrite(im2, cat(2, BaseDir, TargetFolder, '_Visualize/', fname));
    
end

%% Prediction composite
TargetFolder = 'CompositeLabelPred2';

file_glob = glob(fullfile(BaseDir, TargetFolder, '*'));
OutDir = cat(2, BaseDir, TargetFolder, '_Visualize/');
if ~exist(OutDir, 'dir')
    mkdir(OutDir);
end

for i = 1:length(file_glob)
    im = imread(file_glob{i});
    strings = split(file_glob{i}, '\');
    fname = strings{end};
    
    im2 = zeros(size(im));
    im2(im == 1) = 64;
    im2(im == 2) = 128;
    im2(im == 3) = 192;
    im2(im == 4) = 255;
    im2 = uint8(im2);
    imwrite(im2, cat(2, BaseDir, TargetFolder, '_Visualize/', fname));
    
end