function R = harrisCornerResponse(I,k,wsigma)
%%harrisCornerResponse Harris corner detection algorithm.
%   R = harrisCornerDetection(I) computes the non-max suppresed response to the
%   Harris corner detection algorithm from each pixel in the image I using
%   Gaussian window averaging.
%   
%   harrisCornerDetection(I,K,WSIGMA) adjusts the design parameters K and
%   WSIGMA, which are set to 0.04 and 1 by default.
%
%   K is the Harris corner free parameter empirically determined between 0.04 to
%   0.06.  A larger K increases precision at the expenses of recall, meaning
%   fewer false positives, as well as fewer true positives.
%
%   WSIGMA is the standard deviation of the Gaussian mask for the windowing
%   function used in the Harris corner response calculation.  Its value
%   determines the windowing size as well as the neighborhood block size in
%   non-max suppression, which are set to the smallest odd integer greater than
%   or equal to (GEQ) 5 times WSIGMA.
%
%   harrisCornerResponse summarily has the following constraints:
%       - its spatial derivations use 3-by-3 Prewitt masks,
%       - it uses both a Gaussian windowing and non-max suppression,
%       - the neighborhood block sizes for suppression are the same size as the
%       Gaussian windowing, and,
%       - these sizes are the smallest odd integer GEQ 5 times WSIGMA.
%
%   harrisCornerResponse is based on code from Project 2.  Replaced
%   convolveImage with conv2.
%
%   Adapted from Lecture 7.
%
%   Contact:        wu.kevi@northeastern.edu
%   Last updated:   April 13, 2023


% Set default inputs
if (nargin < 2)
    k = 0.04;
end
if (nargin < 3)
    wsigma = 1;
end


% Compute windowing function
G = getGaussianMask(wsigma);
n = size(G,1);


% Compute the image gradients
[Ix,Iy] = computeImageGradients(I); % fixed 3-by-3, Prewitt


% Compute product of derivatives at each pixel
Ix2 = Ix.*Ix;
Iy2 = Iy.*Iy;
Ixy = Ix.*Iy;


% Compute the sums of products at each pixel with window averaging
Sx2 = conv2(Ix2,G,'same');
Sy2 = conv2(Iy2,G,'same');
Sxy = conv2(Ixy,G,'same');


% Find the Mdet and Mtrace matrices
Mdet = Sx2.*Sy2 - Sxy.^2; % equivalent to determinant of M at each pixel
Mtrace = Sx2 + Sy2; % equivalent to trace of M at each pixel


% Compute the response R = det M - k trace(M)^2
R0 = Mdet - k*Mtrace.^2;


% Perform non-max suppression
R = nonmaxSuppression(R0,n);


end