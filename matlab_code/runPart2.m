%%runPart2 Fundamental matrix estimation using hand-selected correspondences.
%   Performs part 2 (i.e. fundamental matrix estimation) using feature pairs
%   generated from part 1.
%
%   Contact:        wu.kevi@northeastern.edu
%   Last updated:   April 18, 2023


% Workspace set-up
clear;
close all;
clc;
addpath('functions'); % library of functions


% Data
load('results\part1.mat');


% Do only one F estimation (using all pairs) for now to test part 3
CastPair.F = fundamentalMatrix(CastPair.pair{2},CastPair.pair{1});
ImagePair.F = fundamentalMatrix(ImagePair.pair{2},ImagePair.pair{1});


% Form feature vectors
CastPair.vectA = [CastPair.pair{1}(:,2)'; ...
    CastPair.pair{1}(:,1)'; ...
    ones(1,size(CastPair.pair{1},1))];
CastPair.vectB = [CastPair.pair{2}(:,2)'; ...
    CastPair.pair{2}(:,1)'; ...
    ones(1,size(CastPair.pair{2},1))];
ImagePair.vectA = [ImagePair.pair{1}(:,2)'; ...
    ImagePair.pair{1}(:,1)'; ...
    ones(1,size(ImagePair.pair{1},1))];
ImagePair.vectB = [ImagePair.pair{2}(:,2)'; ...
    ImagePair.pair{2}(:,1)'; ...
    ones(1,size(ImagePair.pair{2},1))];


% Visualize epipolar line
whichCastPair = 8;
% 5
whichImagePair = [];
for i = 1:length(whichCastPair)
    visualizeEpipolar(CastPair.F,CastPair.pair{1}(whichCastPair(i),:), ...
        Cast(1).gray,Cast(2).gray);
    visualizeEpipolar(ImagePair.F,ImagePair.pair{1}(whichCastPair(i),:), ...
        Image(1).gray,Image(2).gray);
end


% Save
if ~isfile('results\part2.mat')
    save('results\part2.mat');
end