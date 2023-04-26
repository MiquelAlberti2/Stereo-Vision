%%testPart2 Fundamental matrix estimation using hand-selected correspondences.
%   Performs part 2 (i.e. fundamental matrix estimation) using 8
%   manually-determined feature pairs that represent a "truth" set.
%
%   Contact:        wu.kevi@northeastern.edu
%   Last updated:   April 17, 2023


% Workspace set-up
clear;
close all;
clc;
addpath('functions'); % library of functions


% Manully-determined feature pairs [ROWA COLA ROWB COLB]
correspondences = [77 177 77 114;
    361 128 362  63;
    200 262 200 200;
    254 375 254 312;
    198 422 198 359;
    365 518 363 451;
     28 120  27  55;
     27 240  27 177];


% Fundamental matrix
% - Compute using pre-conditioning and SVD
featureA = correspondences(:,1:2);
featureB = correspondences(:,3:4);
F = fundamentalMatrix(featureA,featureB);
% - Check results
checkFundamentalMatrix(F,featureA,featureB);


% Test fundamental
% - Vectors
xA = CastPair.pair{1}(:,2)'; % rows
    yA = CastPair.pair{1}(:,1)';
    vectA = [xA; yA; ones(1,length(xA))];
xB = CastPair.pair{2}(:,2)';
    yB = CastPair.pair{2}(:,2)';
    vectB = [xB; yB; ones(1,length(xB))];
% - Test
lineB = F*vectA;

% Save
if ~isfile('results\part2.mat')
    save('results\part2.mat');
end