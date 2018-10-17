clear all;
close all;

% downloading the data
addpath('C:\Program Files\MATLAB\R2018a\examples\images\main');
imageDir = tempdir;
url = 'http://www.cis.rit.edu/~rmk6217/rit18_data.mat';
downloadHamlinBeachMSIData(url,imageDir);

trainedUnet_url = 'https://www.mathworks.com/supportfiles/vision/data/multispectralUnet.mat';
downloadTrainedUnet(trainedUnet_url,imageDir);

%% Load the data set into the MATLAB® workspace.
imageDir = tempdir;
load(fullfile(imageDir,'rit18_data','rit18_data.mat'));

%% Examine the structure of the data.
whos train_data val_data test_data

%% The multispectral image data is arranged as numChannels-by-width-by-height arrays.
train_data = switchChannelsToThirdPlane(train_data);
val_data   = switchChannelsToThirdPlane(val_data);
test_data  = switchChannelsToThirdPlane(test_data);

%% The RGB color channels are the 4th, 5th, and 6th image channels.
figure
montage(...
    {histeq(train_data(:,:,4:6)), ...
    histeq(val_data(:,:,4:6)), ...
    histeq(test_data(:,:,4:6))}, ...
    'BorderSize',10,'BackgroundColor','white')
title('RGB Component of Training Image (Left), Validation Image (Center), and Test Image (Right)')

%% Display the first three histogram-equalized channels of the training data as a montage.
figure
montage(...
    {histeq(train_data(:,:,1)), ...
    histeq(train_data(:,:,2)), ...
    histeq(train_data(:,:,3))}, ...
    'BorderSize',10,'BackgroundColor','white')
title('IR Channels 1 (Left), 2, (Center), and 3 (Right) of Training Image')

%% Channel 7 is a mask that indicates the valid segmentation region. Display the mask for the training, validation, and test images.
figure
montage(...
    {train_data(:,:,7), ...
    val_data(:,:,7), ...
    test_data(:,:,7)}, ...
    'BorderSize',10,'BackgroundColor','white')
title('Mask of Training Image (Left), Validation Image (Center), and Test Image (Right)')

%% The labeled images contain the ground truth data for the segmentation, with each pixel assigned to one of the 18 classes. Get a list of the classes with their corresponding IDs.
disp(classes)

%% Create a vector of class names.
classNames = [ "RoadMarkings","Tree","Building","Vehicle","Person", ...
               "LifeguardChair","PicnicTable","BlackWoodPanel",...
               "WhiteWoodPanel","OrangeLandingPad","Buoy","Rocks",...
               "LowLevelVegetation","Grass_Lawn","Sand_Beach",...
               "Water_Lake","Water_Pond","Asphalt"]; 
           
%% Overlay the labels on the histogram-equalized RGB training image. Add a colorbar to the image.           
cmap = jet(numel(classNames));
B = labeloverlay(histeq(train_data(:,:,4:6)),train_labels,'Transparency',0.8,'Colormap',cmap);

figure
title('Training Labels')
imshow(B)

% Warning: Image is too big to fit on screen; displaying at 8%
N = numel(classNames);
ticks = 1/(N*2):1/N:1;
colorbar('TickLabels',cellstr(classNames),'Ticks',ticks,'TickLength',0,'TickLabelInterpreter','none');
colormap(cmap)

%% Save the training data as a .MAT file and the training labels as a .PNG file.
save('train_data.mat','train_data');
imwrite(train_labels,'train_labels.png');

%% A mini-batch datastore is used to feed the training data to the network
imds = imageDatastore('train_data.mat','FileExtensions','.mat','ReadFcn',@matReader);

%% Create a pixelLabelDatastore to store the label patches containing the 18 labeled regions.
pixelLabelIds = 1:18;
pxds = pixelLabelDatastore('train_labels.png',classNames,pixelLabelIds);

%% Create the PixelLabelImagePatchDatastore from the image datastore and the pixel label datastore.
ds = PixelLabelImagePatchDatastore(imds,pxds,'PatchSize',256,...
                                             'MiniBatchSize',16,...
                                             'BatchesPerImage',1000)  
                                         
%% To understand what gets passed into the network during training, read the first mini-batch from the PixelLabelImagePatchDatastore.
sampleBatch = read(ds)

%% Reset the datastore to its original state after reading the sample batch.
reset(ds)

%% Create U-Net Network Layers
inputTileSize = [256,256,6];
lgraph = createUnet(inputTileSize);
disp(lgraph.Layers)


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
doTraining = false; 
% doTraining = true;
if doTraining     
    [net,info] = trainNetwork(ds,lgraph,options); 
else 
    load(fullfile(imageDir,'trainedUnet','multispectralUnet.mat'));
end

%% Predict Results on Test Data
% To perform the forward pass on the trained network
predictPatchSize = [1024 1024];
gpuDevice(1)
segmentedImage = segmentImage(val_data,net,predictPatchSize);

%%
% To extract only the valid portion of the segmentation, multiply the segmented image by the mask channel of the validation data.
segmentedImage = uint8(val_data(:,:,7) ~= 0) .* segmentedImage;

figure();
imshow(segmentedImage, [])
title('Segmented Image')

%%
% The output of semantic segmentation is noisy. Perform post image processing to remove noise and stray pixels.
% Use the medfilt2 function to remove salt-and-pepper noise from the segmentation. 
% Visualize the segmented image with the noise removed.
segmentedImage = medfilt2(segmentedImage,[7,7]);
imshow(segmentedImage,[]);
title('Segmented Image  with Noise Removed')

%%
% Overlay the segmented image on the histogram-equalized RGB validation image.
B = labeloverlay(histeq(val_data(:,:,4:6)),segmentedImage,'Transparency',0.8,'Colormap',cmap);

figure
imshow(B)

title('Labeled Validation Image')
colorbar('TickLabels',cellstr(classNames),'Ticks',ticks,'TickLength',0,'TickLabelInterpreter','none');
colormap(cmap)

%%
% Save the segmented image and ground truth labels as .PNG files. 
% These will be used to compute accuracy metrics.
imwrite(segmentedImage,'results.png');
imwrite(val_labels,'gtruth.png');

%% Quantify Segmentation Accuracy
% Create a pixelLabelDatastore for the segmentation results and the ground truth labels.
pxdsResults = pixelLabelDatastore('results.png',classNames,pixelLabelIds);
pxdsTruth = pixelLabelDatastore('gtruth.png',classNames,pixelLabelIds);

% Measure the global accuracy of the semantic segmentation by using the evaluateSemanticSegmentation function.
ssm = evaluateSemanticSegmentation(pxdsResults,pxdsTruth,'Metrics','global-accuracy');

%% Calculate Extent of Vegetation Cover
% The final goal of this example is to calculate the extent of vegetation cover in the multispectral image.
% Find the number of pixels labeled vegetation. 
% The label IDs 2 ("Trees"), 13 ("LowLevelVegetation"), and 14 ("Grass_Lawn") are the vegetation classes. 
% Also find the total number of valid pixels by summing the pixels in the ROI of the mask image.

vegetationClassIds = uint8([2,13,14]);
vegetationPixels = ismember(segmentedImage(:),vegetationClassIds);
validPixels = (segmentedImage~=0);

numVegetationPixels = sum(vegetationPixels(:));
numValidPixels = sum(validPixels(:));

% Calculate the percentage of vegetation cover by dividing the number of vegetation pixels by the number of valid pixels.
percentVegetationCover = (numVegetationPixels/numValidPixels)*100;
fprintf('The percentage of vegetation cover is %3.2f%%.',percentVegetationCover);