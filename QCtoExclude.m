clear all;
close all;

addpath('C:\Users\ZhangX1\Documents\MATLAB\cviParser\');
addpath('C:\Users\ZhangX1\Documents\MATLAB\InfarctDetector\');
base_dir = 'C:/Users/ZhangX1/Documents/MATLAB/CNNTraining/';

tif_glob = glob(cat(2, base_dir, 'TrainingDataTotal/*'));

idx_array = GetGlobIndex(tif_glob);

idx_to_exclude = [8, 9, 132];

exclude_array = zeros(length(idx_array), 1);
for i = 1:length(idx_array)
    if find(idx_to_exclude == idx_array(i))
        exclude_array(i) = 1;
    end
end

OutPathFile = cat(2, base_dir, '/QCtoExclude.mat');
save(OutPathFile, 'exclude_array')