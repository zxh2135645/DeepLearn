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
imageDir = 'C:/Users/ZhangX1/Documents/MATLAB/CNNTraining256/';
training_data = imageDatastore(cat(2, imageDir, 'TrainingData'));
label_data = imageDatastore(cat(2, imageDir, 'LabelData'));

classNames = ["NonInfarct","Infarct"];
pixelLabelIds = [0 255];
pxds = pixelLabelDatastore(cat(2, imageDir, 'LabelData'), classNames, pixelLabelIds);

%%
% classNames = [ "RoadMarkings","Tree","Building","Vehicle","Person", ...
%                "LifeguardChair","PicnicTable","BlackWoodPanel",...
%                "WhiteWoodPanel","OrangeLandingPad","Buoy","Rocks",...
%                "LowLevelVegetation","Grass_Lawn","Sand_Beach",...
%                "Water_Lake","Water_Pond","Asphalt"]; 
% pixelLabelIds = 1:18;
% pxds = pixelLabelDatastore('train_labels.png',classNames,pixelLabelIds);
%% Create the PixelLabelImagePatchDatastore from the image datastore and the pixel label datastore.
ds = PixelLabelImagePatchDatastore(training_data,pxds,'PatchSize',256,...
                                             'MiniBatchSize',16,...
                                             'BatchesPerImage',1000)  
         
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
minibatchSize = 16;
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
