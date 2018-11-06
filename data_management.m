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

dsts = {'Heart', 'Myocardium', 'excludeContour', 'MyoReference', 'MI', 'noReflowAreaContour', 'BloodPool'};
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

OutPath = cat(2, OutputPath, '/TrainingDataTotal/');
if ~exist(OutPath, 'dir')
   mkdir(OutPath)
end

HeartOutPath = cat(2, OutputPath, 'HeartLabelTotal/');
if ~exist(HeartOutPath, 'dir')
   mkdir(HeartOutPath)
end

count1 = 1;
SliceNum = cell(length(Names), 1);
clear x_centroid_array y_centroid_array centroids
for i = 1:length(Name_labels)
    if Name_labels(i) ~= 0
        mat_glob = glob(cat(2, base_dir, Names{Name_labels(i)}, '/', label, '/', dsts{2}, '/*.mat'));
        heart_glob = glob(cat(2, base_dir, Names{Name_labels(i)}, '/', label, '/', dsts{1}, '/*.mat'));
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
                load(heart_glob{j});
                mask_heart = mask_heart > 0;
                s = regionprops(mask_heart,'centroid');
                %                 [x_heart, y_heart] = find(volume_image(:,:,idx_array(j)) ~= 0);
                %                 x_centroid_array(count1) = round(mean(x_heart),1);
                %                 y_centroid_array(count1) = round(mean(y_heart),1);
                % mask_heart = uint8(mask_heart.*255);
                mask_heart2 = zeros(size(mask_heart));
                mask_heart2(mask_heart == 0) = 1;
                mask_heart2(mask_heart == 1) = 2;
                mask_heart2 = uint8(mask_heart2);
                imwrite(mask_heart2, cat(2, OutputPath, 'HeartLabelTotal/', num2str(count1), '.tif'))
                imwrite(volume_image(:,:,idx_array(j)), cat(2, OutPath, num2str(count1), '.tif'))
                centroids{count1} = s.Centroid;
                count1 = count1 + 1;
            end
        else
            disp(Names{Name_labels(i)});
        end
    end
end

centroid_OutPathFile = cat(2, OutputPath, '/centroids.mat');
save(centroid_OutPathFile, 'centroids')

OutPath = cat(2, OutputPath, '/LabelDataTotal/');
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
                im2 = zeros(size(mask_heart));
                im2(im == 0) = 1;
                im2(im == 255) = 2;
                im2 = uint8(im2);
                imwrite(im2, cat(2, OutPath, num2str(count2), '.tif'))
                count2 = count2 + 1;
            else
                disp(Names{Name_labels(i)});
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

%% Generate composite images
OutPath = cat(2, OutputPath, '/CompositeLabelTotal2/');
if ~exist(OutPath, 'dir')
   mkdir(OutPath)
end

count2 = 1;
for i = 1:length(Name_labels)
    if Name_labels(i) ~= 0
        tiff_glob = glob(cat(2, base_dir, Names{Name_labels(i)}, '/', label, '/', dsts{5}, '/*.tif'));
        heart_glob = glob(cat(2, base_dir, Names{Name_labels(i)}, '/', label, '/', dsts{1}, '/*.mat'));
        blood_glob = glob(cat(2, base_dir, Names{Name_labels(i)}, '/', label, '/', dsts{7}, '/*.mat'));
        
        for j = 1:length(tiff_glob)
            im = imread(tiff_glob{j});
            if size(im, 1) == 256 && size(im, 2) == 218
                load(heart_glob{j});
                load(blood_glob{j});
                mask_heart = mask_heart > 0;
                mask_blood = mask_blood > 0;
                im2 = zeros(size(mask_heart));
                im2(mask_heart == 1) = 2;
                im2(mask_blood == 1) = 3;
                im2(im == 255) = 4;
                im2(im2 == 0) = 1;
                im2 = uint8(im2);
                imwrite(im2, cat(2, OutPath, num2str(count2), '.tif'))
                count2 = count2 + 1;
            else
                disp(Names{Name_labels(i)});
            end
        end
    end
end

%% Generate null background images
OutPath = cat(2, OutputPath, '/NulBkgdTrainingTotal/');
if ~exist(OutPath, 'dir')
   mkdir(OutPath)
end

count3 = 1;
for i = 1:length(Name_labels)
    if Name_labels(i) ~= 0
        heart_glob = glob(cat(2, base_dir, Names{Name_labels(i)}, '/', label, '/', dsts{1}, '/*.mat'));
        % Reordering
        idx_array = zeros(length(heart_glob), 1);
        dicom = dicom_glob{i};
        load(dicom);
        if size(volume_image, 1) == 256 && size(volume_image, 2) == 218
            for j = 1:length(heart_glob)
                B = regexp(heart_glob(j),'\d*','Match');
                
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
            
            volume_image = uint8(volume_image / max(volume_image(:)) * 255);
            
            for j = 1:length(heart_glob)
                load(heart_glob{j});
                mask_heart = mask_heart > 0;
                mask_heart2 = mask_heart .* double(volume_image(:,:,idx_array(j)));
                mask_heart2 = uint8(mask_heart2);
                imwrite(mask_heart2, cat(2, OutPath, num2str(count3), '.tif'))
                count3 = count3 + 1;
            end
        else
            disp(Names{Name_labels(i)});
        end
    end
end

%% Generate random numbers, separate into 5 groups
randperm_5groups = struct;
idx = randperm(count1-1);
n = mod(count1, 5);
m = fix(count1/5);
if n ~= 0
    m = m + 1;
end
indexToGroup1 = (idx<=m);
indexToGroup2 = (idx>m & idx <=m*2);
indexToGroup3 = (idx>m*2 & idx <=m*3);
indexToGroup4 = (idx>m*3 & idx <=m*4);
indexToGroup5 = (idx>m*4);

randperm_5groups.indexToGroup1 = indexToGroup1;
randperm_5groups.indexToGroup2 = indexToGroup2;
randperm_5groups.indexToGroup3 = indexToGroup3;
randperm_5groups.indexToGroup4 = indexToGroup4;
randperm_5groups.indexToGroup5 = indexToGroup5;
OutPathFile = cat(2, OutputPath, '/randperm_5groups.mat');
save(OutPathFile, 'randperm_5groups')

