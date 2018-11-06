clear all;
close all;

addpath('C:\Users\ZhangX1\Documents\MATLAB\cviParser\');
addpath('C:\Users\ZhangX1\Documents\MATLAB\InfarctDetector\');

% Implement Nameparser
CurrentFolder = pwd;
SliceNumFile = GetFullPath(cat(2, CurrentFolder, '/../CNNTraining/SliceNum.mat'));
load(SliceNumFile);

base_dir = 'C:/Users/ZhangX1/Documents/MATLAB/CNNData/';
name_glob = glob(cat(2, base_dir, '*'));

Names = cell(length(name_glob), 1);
for i = 1:length(name_glob)
    strings = strsplit(name_glob{i},'\');
    Names{i} = strings{end-1};
end

RuleOutLabel = NameRuleOutFunc(Names);
Names = Names(RuleOutLabel == 0);

% Exclude that does not work
count = 1;
for i = 1:length(SliceNum)
    if ~isempty(SliceNum{i})
        NewSliceNum{count} = SliceNum{i};
        NewNames{count} = Names{i};
        count = count + 1;
    end
end

%% Check subject name and slice number
NumParser(Names, SliceNum)


