function [Gx,Gy] = computeImageGradients(I)
%%computeImageGradient Horizontal and vertical gradient approximation.
%   [GX,GY] = computeImageGradients(I) approximates the horizontal and vertical
%   gradient images GX and GY from I using convolution and the Prewitt operator.
%
%   Replaced convolveImage with conv2.
%
%   Contact:        wu.kevi@northeastern.edu
%   Last updated:   April 13, 2023


% Prewitt masks
h = [+1  0 -1;
     +1  0 -1;
     +1  0 -1];
v = [+1 +1 +1;
      0  0  0;
     -1 -1 -1];


% Gradients
Gx = conv2(I,h,'same');
Gy = conv2(I,v,'same');


end