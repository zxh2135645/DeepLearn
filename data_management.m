clear all;
close all;

addpath('C:\Users\ZhangX1\Documents\MATLAB\cviParser\');
addpath('C:\Users\ZhangX1\Documents\MATLAB\InfarctDetector\');
sequence_label = {'LGE', 'T1'};
label = char(sequence_label(2));
base_dir = 'C:/Users/ZhangX1/Documents/MATLAB/CNNData/';

name_glob = glob(cat(2, base_dir, '*'));
dicom_glob = glob(cat(2, 'C:/Users/ZhangX1/Desktop/contour_exporting_Guan/*/', label, '/*/*/VOLUME_IMAGE.mat'));
CurrentFolder = pwd;
OutputPath = GetFullPath(cat(2, CurrentFolder, '/../CNNTraining/'));

dsts = {'Heart', 'Myocardium', 'excludeContour', 'MyoReference', 'MI', 'noReflowAreaContour'};
Names = cell(length(name_glob), 1);
for i = 1:length(name_glob)
    strings = strsplit(name_glob{i},'\');
    Names{i} = strings{end-1};
end

RuleOutLabel = NameRuleOutFunc(Names);
Names = Names(RuleOutLabel == 0);

FullNames = cell(length(dicom_glob), 1);
for i = 1:length(dicom_glob)
    strings = strsplit(dicom_glob{i},'\');
    name = strings{end-4};
    FullNames{i} = name;
end

Name_labels = zeros(length(FullNames), 1);
for i = 1:length(Names)
    idx = find(strcmp(Names{i}, FullNames));
    Name_labels(idx) = i;
end

OutPath = cat(2, OutputPath, '/TrainingData/');
if ~exist(OutPath, 'dir')
   mkdir(OutPath)
end

count1 = 1;
SliceNum = cell(length(Names), 1);
for i = 1:length(Name_labels)
    if Name_labels(i) ~= 0
        mat_glob = glob(cat(2, base_dir, Names{Name_labels(i)}, '/', label, '/', dsts{2}, '/*.mat'));
        % Reordering
        idx_array = zeros(length(mat_glob), 1);
        dicom = dicom_glob{i};
        load(dicom);
        
        if size(volume_image, 1) == 256 && size(volume_image, 2) == 218
            for j = 1:length(mat_glob)
                B = regexp(mat_glob(j),'\d*','Match');
                
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
            
            SliceNum{Name_labels(i)} = idx_array;
            volume_image = uint8(volume_image / max(volume_image(:)) * 255);
            
            for j = 1:length(mat_glob)
                imwrite(volume_image(:,:,idx_array(j)), cat(2, OutPath, num2str(count1), '.tif'))
                count1 = count1 + 1;
            end
        end
    end
end

OutPath = cat(2, OutputPath, '/LabelData/');
if ~exist(OutPath, 'dir')
   mkdir(OutPath)
end

count2 = 1;
for i = 1:length(Name_labels)
    if Name_labels(i) ~= 0
        tiff_glob = glob(cat(2, base_dir, Names{Name_labels(i)}, '/', label, '/', dsts{5}, '/*.tif'));
        
        for j = 1:length(tiff_glob)
            im = imread(tiff_glob{j});
            if size(im, 1) == 256 && size(im, 2) == 218
                imwrite(im, cat(2, OutPath, num2str(count2), '.tif'))
                count2 = count2 + 1;
            end
        end
    end
end

OutPathFile = cat(2, OutputPath, '/SliceNum.mat');
if count1 ~= count2
    error("The number of labels are different from its original image")
else
    save(OutPathFile, 'SliceNum')
end
