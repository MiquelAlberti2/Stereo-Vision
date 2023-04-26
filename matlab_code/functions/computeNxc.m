function nxc = computeNxc(g,f)
%%computeNxc Normalized cross-correlation of image with kernel.
%   NXC = computeNxc(G,F) computes the cross-correlation of image F with kernel
%   G and returns it normalized as NXC.
%
%   Any padding is removed by using the 'same' option with MATLAB's conv2
%   function.  The output matches the dimensions of the input image.
%
%   TODO: Slightly different results than normxcorr2 and some other NCC
%   algorithms, though the relative ratios appear to be similar.  Not sure why.
%
%   Contact:        wu.kevi@northeastern.edu
%   Last updated:   April 13, 2023


% Center image and correlation kernel
g0 = g - mean(g,'all');
f0 = f - mean(f,'all');


% Compute cross-correlation by convolving image with kernel
xc = conv2(f,rot90(g0,2),'valid');


% Normalize cross-correlation
f2norm = conv2(f0.^2,ones(size(g)),'valid');
fnorm2 = (conv2(f0,ones(size(g)),'valid').^2)/numel(g);
fnorm = f2norm - fnorm2;
fnorm(fnorm < 0) = 0;
gnorm = sum(g0.^2,'all');
denom = sqrt(fnorm*gnorm);
ncc = xc./denom;


% Remove non-finite elements
ncc(~isfinite(ncc)) = 0;


% Add zero-padding to obtain original image size
nxc = zeros(size(f));
lowerBound = 1 + floor((size(g) - 1)/2);
upperBound = size(f) - ceil((size(g) - 1)/2);
nxc(lowerBound(1):upperBound(1),lowerBound(2):upperBound(2)) = ncc;


end % end computeNxc