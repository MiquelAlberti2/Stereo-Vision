%%runPart3 Dense disparity mapping.
%   TBD
%
%   Contact:        wu.kevi@northeastern.edu
%   Last updated:   April 13, 2023


% Workspace set-up
clear;
close all;
clc;
addpath('functions'); % library of functions


% Data
load('results\part2.mat');


% Cast
% - Search each epipolar
CastSearch.xSpan = 1:576;
[CastSearch.vectA,CastSearch.vectB,CastSearch.lineB] ...
    = searchAlongEpipolar(CastSearch.xSpan, ...
                          CastPair.F, ...
                          Cast(1).gray, ...
                          Cast(2).gray);
% - Compute disparities
CastSearch.dx = reshape(CastSearch.vectA(1,:) - CastSearch.vectB(1,:), ...
                        Cast(1).dim(1),Cast(1).dim(2));
CastSearch.dy = reshape(CastSearch.vectA(2,:) - CastSearch.vectB(2,:), ...
                        Cast(1).dim(1),Cast(1).dim(2));
% - Zero out non-finite data points
zeroMe = ~isfinite(CastSearch.dx) | ~isfinite(CastSearch.dy);
CastSearch.dx(zeroMe) = 0;
CastSearch.dy(zeroMe) = 0;
% - Scale
CastSearch.DX = CastSearch.dx - min([CastSearch.dx(:); CastSearch.dy(:)]);
CastSearch.DY = CastSearch.dy - min([CastSearch.dx(:); CastSearch.dy(:)]);
CastSearch.scaleFactor = max([CastSearch.DX(:); CastSearch.DY(:)]);
CastSearch.DX = uint8(CastSearch.DX/CastSearch.scaleFactor*255);
CastSearch.DY = uint8(CastSearch.DY/CastSearch.scaleFactor*255);
% - Plot grayscale
figure('Name','Horizontal Disparity, Grayscale, Cast');
    imshow(CastSearch.DX);
    title('\DeltaX (Cast, Gray)');
figure('Name','Vertical Disparity, Grayscale, Cast');
    imshow(CastSearch.DY);
    title('\DeltaY (Cast, Gray)');
% - Compute disparity orientation and magnitude
CastSearch.orientation = atan2(CastSearch.dy,CastSearch.dx);
CastSearch.magnitude = sqrt(CastSearch.dx.^2 + CastSearch.dy.^2);
% - Scale to hue and saturation
CastSearch.hsv(:,:,1) = (CastSearch.orientation - -pi)/pi;
CastSearch.hsv(:,:,2) = CastSearch.magnitude - min(CastSearch.magnitude(:));
    CastSearch.hsv(:,:,2) = CastSearch.magnitude/max(CastSearch.magnitude(:));
CastSearch.hsv(:,:,3) = ones(size(CastSearch.hsv(:,:,1)));
CastSearch.rgb = uint8(hsv2rgb(CastSearch.hsv)*255);
% - Plot hue and saturation
figure('Name','Disparity, HSV, Cast');
    imshow(CastSearch.rgb);
    title('Disparity Vector (Cast, HSV)');


% Image
% - Search each epipolar
ImageSearch.xSpan = 1:576;
[ImageSearch.vectA,ImageSearch.vectB,ImageSearch.lineB] ...
    = searchAlongEpipolar(ImageSearch.xSpan, ...
                          ImagePair.F, ...
                          Image(1).gray, ...
                          Image(2).gray);
% - Compute disparities
ImageSearch.dx = reshape(ImageSearch.vectA(1,:) - ImageSearch.vectB(1,:), ...
                         Image(1).dim(1),Image(1).dim(2));
ImageSearch.dy = reshape(ImageSearch.vectA(2,:) - ImageSearch.vectB(2,:), ...
                         Image(1).dim(1),Image(1).dim(2));
% - Zero out non-finite data points
zeroMe = ~isfinite(ImageSearch.dx) | ~isfinite(ImageSearch.dy);
ImageSearch.dx(zeroMe) = 0;
ImageSearch.dy(zeroMe) = 0;
% - Scale
ImageSearch.DX = ImageSearch.dx - min([ImageSearch.dx(:); ImageSearch.dy(:)]);
ImageSearch.DY = ImageSearch.dy - min([ImageSearch.dx(:); ImageSearch.dy(:)]);
ImageSearch.scaleFactor = max([ImageSearch.DX(:); ImageSearch.DY(:)]);
ImageSearch.DX = uint8(ImageSearch.DX/ImageSearch.scaleFactor*255);
ImageSearch.DY = uint8(ImageSearch.DY/ImageSearch.scaleFactor*255);
% - Plot grayscale
figure('Name','Horizontal Disparity, Grayscale, Image');
    imshow(ImageSearch.DX);
    title('\DeltaX (Image, Gray)');
figure('Name','Vertical Disparity, Grayscale, Image');
    imshow(ImageSearch.DY);
    title('\DeltaY (Image, Gray)');
% - Compute disparity orientation and magnitude
ImageSearch.orientation = atan2(ImageSearch.dy,ImageSearch.dx);
ImageSearch.magnitude = sqrt(ImageSearch.dx.^2 + ImageSearch.dy.^2);
% - Scale to hue and saturation
ImageSearch.hsv(:,:,1) = (ImageSearch.orientation - -pi)/pi;
ImageSearch.hsv(:,:,2) = ImageSearch.magnitude - min(ImageSearch.magnitude(:));
    ImageSearch.hsv(:,:,2) = ImageSearch.magnitude ...
                             /max(ImageSearch.magnitude(:));
ImageSearch.hsv(:,:,3) = ones(size(ImageSearch.hsv(:,:,1)));
ImageSearch.rgb = uint8(hsv2rgb(ImageSearch.hsv)*255);
% - Plot hue and saturation
figure('Name','Disparity, HSV, Image');
    imshow(ImageSearch.rgb);
    title('Disparity Vector (Image, HSV)');


% Save
if ~isfile('results\part3.mat')
    save('results\part3.mat');
end