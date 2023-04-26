%%runPart1 Find correspondences between both stereo pairs.
%   This script finds correspondences between the two image sets -- in the
%   'cast' and 'image' sub-folders -- for the first part of Project 3.
%
%   Contact:        wu.kevi@northeastern.edu
%   Last updated:   April 14, 2023


% Workspace set-up
clear;
close all;
clc;
addpath('functions'); % library of functions


% Read in data
% - Cast
disp('# Reading in cast...');
castCellArray = readImageDirIntoCellArray('cast');
Cast(1).rgb = castCellArray{1};
    Cast(1).gray = im2gray(Cast(1).rgb);
    Cast(1).dim = size(Cast(1).gray);
Cast(2).rgb = castCellArray{2};
    Cast(2).gray = im2gray(Cast(2).rgb);
    Cast(2).dim = size(Cast(2).gray);
% - Image
disp('# Reading in image...');
imageCellArray = readImageDirIntoCellArray('image');
Image(1).rgb = imageCellArray{1};
    Image(1).gray = im2gray(Image(1).rgb);
    Image(1).dim = size(Image(1).gray);
Image(2).rgb = imageCellArray{2};
    Image(2).gray = im2gray(Image(2).rgb);
    Image(2).dim = size(Image(2).gray);


% Apply Harris corner detector to both images
disp('# Running Harris corner detection...');
% - Set design parameters
wsigma = 2.2; % Gaussian sigma for windowing
k = 0.06; % k value for Harris response
numFeature = 100; % max number of features
% - Send both stereo pairs through Harris corner detection
for i = 1:2
    % - Harris responses
    Cast(i).R = harrisCornerResponse(Cast(i).gray,k,wsigma);
    Image(i).R = harrisCornerResponse(Image(i).gray,k,wsigma);
    % - Top feature detections (with automated thresholding)
    [Cast(i).features,Cast(i).threshold] = getTopFeatures(Cast(i).R,numFeature);
    [Image(i).features,Image(i).threshold] = getTopFeatures(Image(i).R, ...
                                                            numFeature);
end
% - Plot
figure('Name','Cast 1, Features');
    imshow(Cast(1).gray);
    hold on;
    showFeatures(Cast(1).features);
figure('Name','Image 1, Features');
    imshow(Image(1).gray);
    hold on;
    showFeatures(Image(1).features);


% Perform feature matching using NXC (don't reuse aggregateMatching from P2)
% - Design parameters
searchRatio = 0.1; % controls nxc patch size
scoreThreshold = 0.7; % toss out pairs below this
% - Cast
disp('# Matching features for cast...');
CastPair.patchSize = round(searchRatio*Cast(1).dim);
[CastPair.match,CastPair.score] = nxcFeatureMatching(CastPair.patchSize, ...
                                    Cast(1).features,Cast(2).features, ...
                                    Cast(1).gray,Cast(2).gray);
% - Image
disp('# Matching features for image...');
ImagePair.patchSize = round(searchRatio*Image(1).dim);
[ImagePair.match,ImagePair.score] = nxcFeatureMatching(ImagePair.patchSize, ...
                                    Image(1).features,Image(2).features, ...
                                    Image(1).gray,Image(2).gray);
% - Thresholding
CastPair.pair = {CastPair.match{1}(CastPair.score >= scoreThreshold,:) ...
                 CastPair.match{2}(CastPair.score >= scoreThreshold,:)};
ImagePair.pair = {ImagePair.match{1}(ImagePair.score >= scoreThreshold,:) ...
                  ImagePair.match{2}(ImagePair.score >= scoreThreshold,:)};


% Use this to iterate through each correspondence
% % - Cast
% disp('# Displaying each feature pair for cast.');
% plotFeaturePairs(CastPair.pair, ...
%                  Cast(1).features,Cast(2).features, ...
%                  Cast(1).gray,Cast(2).gray, ...
%                  'iterate');
% close(gcf);
% % - Image
% disp('# Displaying each feature pair for image.');
% plotFeaturePairs(ImagePair.pair, ...
%                  Image(1).features,Image(2).features, ...
%                  Image(1).gray,Image(2).gray, ...
%                  'iterate');
% close(gcf);


% Plot pairs
% - Cast
disp('# Displaying each feature pair for cast.');
plotFeaturePairs(CastPair.pair, ...
                 Cast(1).features,Cast(2).features, ...
                 Cast(1).gray,Cast(2).gray);
set(gcf,'Name','Correspondences, Cast');
    % -- Adjust markers
    ax = gca;
    ax.Children(1).CData = [0 0 1];
        ax.Children(1).MarkerFaceColor = [0 1 0];
    ax.Children(2).CData = [0 0 1];
        ax.Children(2).MarkerFaceColor = [1 0 0];
        ax.Children(2).Marker = 's';
    % -- Re-color lines by row position
    colors = lines;
    axlines = allchild(ax);
        axtype = arrayfun(@class,axlines,'UniformOutput',false);
        isLine = strcmp(axtype,'matlab.graphics.chart.primitive.Line');
        axlines = axlines(isLine);
    yLineVal = arrayfun(@(x) max(x.YData),axlines);
        [~,sortdx] = sort(yLineVal);
    for i = 1:length(axlines)
        axlines(i).Color = colors(sortdx(i),:);
    end
% - Image
disp('# Displaying each feature pair for image.');
plotFeaturePairs(ImagePair.pair, ...
                 Image(1).features,Image(2).features, ...
                 Image(1).gray,Image(2).gray);
set(gcf,'Name','Correspondences, Image');
    % -- Adjust markers
    ax = gca;
    ax.Children(1).CData = [0 0 1];
        ax.Children(1).MarkerFaceColor = [0 1 0];
    ax.Children(2).CData = [0 0 1];
        ax.Children(2).MarkerFaceColor = [1 0 0];
        ax.Children(2).Marker = 's';
    % -- Re-color lines by row position
    axlines = allchild(ax);
        axtype = arrayfun(@class,axlines,'UniformOutput',false);
        isLine = strcmp(axtype,'matlab.graphics.chart.primitive.Line');
        axlines = axlines(isLine);
    yLineVal = arrayfun(@(x) max(x.YData),axlines);
        [~,sortdx] = sort(yLineVal);
    for i = 1:length(axlines)
        axlines(i).Color = colors(sortdx(i),:);
    end


% Save
if ~isfile('results\part1.mat')
    save('results\part1.mat');
end