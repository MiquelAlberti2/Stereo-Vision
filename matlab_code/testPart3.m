%%testPart3 Check dense disparity mapping.
%   This script checks the dense disparity functions using a "truth" fundamental
%   matrix determined from assuming only a horizontal translation between the
%   stereo image pair.
%
%   With that assumption for some given feature A, the fundamental matrix must
%   returning the corresponding line coefficients B for a horizontal epipolar
%   line at the same height (i.e. row or y-coordinate) of that feature A.
%
%   Contact:        wu.kevi@northeastern.edu
%   Last updated:   April 17, 2023


% Workspace set-up
clear;
close all;
clc;
addpath('functions'); % library of functions


% Data
load('results\part1.mat','CastPair','ImagePair','Cast','Image');


% "Truth" fundamental matrix
F = [0 0  0;
     0 0 -1;
     0 1  0];


% Visual check for epipolar lines
whichPair = randi([1 size(CastPair.pair{1},1)],1,3);
for i = 1:length(whichPair)
    visualizeEpipolar(F,CastPair.pair{1}(whichPair(i),:), ...
        Cast(1).gray,Cast(2).gray);
end


% Epipolar line search
xSpan = 1:576;
[vectA,vectB,lineB] = searchAlongEpipolar(xSpan,F,Cast(1).gray,Cast(2).gray);
matchFound = isfinite(vectB(1,:));
    vectA = vectA(:,matchFound);
    vectB = vectB(:,matchFound);
    lineB = lineB(:,matchFound);


% Disparities
dx = vectA(1,:) - vectB(1,:);
dy = vectA(2,:) - vectB(2,:);


% Disparity interpolation over image
[X,Y] = meshgrid(1:Cast(1).dim(2),1:Cast(1).dim(1));
DX = nan(size(X));
DY = nan(size(Y));
for i = 1:size(vectA,2)
    DX(vectA(2,i),vectA(1,i)) = dx(i);
    DY(vectA(2,i),vectA(1,i)) = dy(i);
end
FDX = DX;
    FDY = DY;
    FX = X;
    FY = Y;
idx = isfinite(FDX); 
    FDX = FDX(:,~all(~idx,1));
    FDY = FDY(:,~all(~idx,1));
    FX = FX(:,~all(~idx,1));
    FY = FY(:,~all(~idx,1));
idx = isfinite(FDX); 
    FDX = FDX(~all(~idx,2),:);
    FDY = FDY(~all(~idx,2),:);
    FX = FX(~all(~idx,2),:);
    FY = FY(~all(~idx,2),:);

q = interp2(FX,FY,FDX,X,Y,'linear',0);
p = interp2(FX,FY,FDY,X,Y,'linear',0);

figure;
    q = q - min(q(:));
    q = q./max(q(:))*255;
    q = uint8(q);
    imshow(q);
figure;
    p = p - min(p(:));
    p = p./max(p(:))*255;
    p = uint8(p);
    imshow(p);

% 
% 
% % Plot
% figure('Name','Horizontal Disparity, Cast');
%     imshow(dx);
%     title('\DeltaX (Cast)');
% figure('Name','Vertical Disparity, Cast');
%     imshow(dy);
%     title('\DeltaY (Cast)');
% figure('Name','Magnitude Disparity, Cast');
%     imshow(d);
%     title('Magnitude (Cast)');
% 
% 
% 
