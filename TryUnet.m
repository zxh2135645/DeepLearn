clear all;
close all;

% downloading the data
addpath('C:\Program Files\MATLAB\R2018a\examples\images\main');
% imageDir = tempdir;
imageDir = 'C:/Users/ZhangX1/Documents/MATLAB/CNNTraining256/';
%imageDir = 'C:/Users/ZhangX1/Documents/MATLAB/CNNTraining/';
% trainedUnet_url = 'https://www.mathworks.com/supportfiles/vision/data/multispectralUnet.mat';
% downloadTrainedUnet(trainedUnet_url,imageDir);

%%
%imageDir = 'C:/Users/ZhangX1/Documents/MATLAB/CNNTraining256/';
imageDir = 'C:/Users/ZhangX1/Documents/MATLAB/CNNTraining128/';
imageDir = 'C:/Users/ZhangX1/Documents/MATLAB/CNNTrainingCrop64/';
training_data = imageDatastore(cat(2, imageDir, 'TrainingData'));
training_data = imageDatastore(cat(2, imageDir, 'NulBkgdTrainingData'));
% label_data = imageDatastore(cat(2, imageDir, 'LabelData'));
label_data = imageDatastore(cat(2, imageDir, 'CompositeLabel2'));

%classNames = ["NonInfarct","Infarct"];
%classNames = ["Backgroud", "Heart"];
%pixelLabelIds = [1, 2];

classNames = ["Background", "Myocardium", "BloodPool", "Infarct"];
pixelLabelIds = [1, 2, 3, 4];
pxds = pixelLabelDatastore(cat(2, imageDir, 'CompositeLabel2'), classNames, pixelLabelIds);

%%
% classNames = [ "RoadMarkings","Tree","Building","Vehicle","Person", ...
%                "LifeguardChair","PicnicTable","BlackWoodPanel",...
%                "WhiteWoodPanel","OrangeLandingPad","Buoy","Rocks",...
%                "LowLevelVegetation","Grass_Lawn","Sand_Beach",...
%                "Water_Lake","Water_Pond","Asphalt"]; 
% pixelLabelIds = 1:18;
% pxds = pixelLabelDatastore('train_labels.png',classNames,pixelLabelIds);
%% Create the PixelLabelImagePatchDatastore from the image datastore and the pixel label datastore.
ds = PixelLabelImagePatchDatastore(training_data,pxds,'PatchSize',64,...
                                             'MiniBatchSize', 2,...
                                             'BatchesPerImage',1)  
         
%[imd1, imd2, imd3, imd4, imd5] = splitEachLabel(ds, 0.2, 0.2, 0.2, 0.2, 0.2, 'randomize'); 

%%
lgraph = createUnet();

%% Create U-Net Network Layers
% inputTileSize = [256, 256, 1];
% lgraph = createUnet(inputTileSize);
% disp(lgraph.Layers)
% 
% layersTransfer = lgraph.Layers(1:end-3);
% numClasses = 2;
% layers = [
%     layersTransfer
%     fullyConnectedLayer(numClasses,'WeightLearnRateFactor',1,'BiasLearnRateFactor',1, 'Name', 'Final-ConvolutionLayer')
%     softmaxLayer('Name', 'Softmax-Layer');
%     classificationLayer('Name', 'Segmentation-Layer')];
% 
% lgraph2 = layerGraph(layers);
% lgraph2 = connectLayers(lgraph2, 'Encoder-Section-1-ReLU-2', 'Decoder-Section-4-DepthConcatenation/in2');
% lgraph2 = connectLayers(lgraph2, 'Encoder-Section-2-ReLU-2', 'Decoder-Section-3-DepthConcatenation/in2');
% lgraph2 = connectLayers(lgraph2, 'Encoder-Section-3-ReLU-2', 'Decoder-Section-2-DepthConcatenation/in2');
% lgraph2 = connectLayers(lgraph2, 'Encoder-Section-4-DropOut', 'Decoder-Section-1-DepthConcatenation/in2');
% 
% figure()
% plot(lgraph2)
%%
% layers_self = [
%     imageInputLayer([192, 192, 1], 'Name', 'ImageInputLayer')
%     convolution2dLayer(3, 64, 'Padding', 'same', 'Name', 'Encoder-Section-1-Conv-1')];
% figure
% plot(lgraph2)

%% Select Training Options
initialLearningRate = 0.05;
maxEpochs = 150;
minibatchSize = 2;
l2reg = 0.0001;

options = trainingOptions('sgdm',...
    'InitialLearnRate', initialLearningRate, ...
    'Momentum',0.9,...
    'L2Regularization',l2reg,...
    'MaxEpochs',maxEpochs,...
    'MiniBatchSize',minibatchSize,...
    'VerboseFrequency',20,...
    'LearnRateSchedule','piecewise',...    
    'Shuffle','every-epoch',...
    'Plots','training-progress',...
    'GradientThresholdMethod','l2norm',...
    'GradientThreshold',0.05);

%% Train the Network
doTraining = true; 
if doTraining     
    [net,info] = trainNetwork(ds,lgraph,options); 
else 
    load(fullfile(imageDir,'trainedUnet','multispectralUnet.mat'));
end

%% Save the network
save(cat(2, imageDir, 'UnetCrop64CompositeNB.mat'), 'net');

%% Evaluate Segmentation results
imageDir = 'C:/Users/ZhangX1/Documents/MATLAB/CNNTrainingCrop64/';
load(cat(2, imageDir, 'UnetCrop64CompositeNB.mat'));
classNames = ["Background", "Myocardium", "BloodPool", "Infarct"];
pixelLabelIds = [1, 2, 3, 4];

testImagesDir = fullfile(imageDir, 'NulBkgdTestingData');
%testLabelsDir = fullfile(imageDir, 'HeartLabelTest');
% testImagesDir = fullfile(imageDir, 'TestingData');
testLabelsDir = fullfile(imageDir, 'CompositeLabelTest2');
% OutDir = fullfile(imageDir, 'HeartLabelPred');
OutDir = fullfile(imageDir, 'NulBkgdLabelPred');
% OutDir = fullfile(imageDir, 'CompositeLabel2');
if ~exist(OutDir, 'dir')
    mkdir(OutDir)
end

imds_test = imageDatastore(testImagesDir);
pxdsTruth = pixelLabelDatastore(testLabelsDir, classNames, pixelLabelIds);
pxdsResults = semanticseg(imds_test, net, "WriteLocation", OutDir);

%% Compute confusion matrix and Segmentation Metrics
metrics = evaluateSemanticSegmentation(pxdsResults,pxdsTruth);
metrics.ClassMetrics
metrics.NormalizedConfusionMatrix

%% Plot confusion matrix
T = metrics.NormalizedConfusionMatrix;
t = zeros(size(T));
for i = 1:size(T, 1)
    for j = 1:size(T, 2)
        t(i,j) = T{i,j};
    end
end

figure();
imagesc(t)
set(gca,'XtickLabel',{'', 'Background', '', 'Myocardium', '', 'BloodPool', '', 'Infarct', ''})
set(gca,'YtickLabel',{'', 'Background', '', 'Myocardium', '', 'BloodPool', '', 'Infarct', ''})

color_spec = cell(size(t));
for i = 1:size(T, 1)
    for j = 1:size(T, 2)
        if t(i,j) > 0.5
            color_spec{i,j} = [0 0 0];
        else
            color_spec{i,j} = [1 1 1];
        end
    end
end

for i = 1:size(T, 1)
    for j = 1:size(T, 2)
        text(i, j, num2str(round(t(j,i),2, 'significant')), 'HorizontalAlignment', 'center', 'Color', color_spec{i,j}, 'FontSize', 12);
    end
end