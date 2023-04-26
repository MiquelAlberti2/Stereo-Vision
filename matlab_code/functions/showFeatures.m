function showFeatures(features,marker)
%%showFeatures Overlay current figure with feature detections.
%   showFeatures(FEATURES) takes the logical matrix FEATURES denoting binary
%   features and displays them on the current figure.
%
%   showFeatures(FEATURES,MARKER) displays the binary features with marker
%   string MARKER.  By default, MARKER is 'rx'.
%
%   Contact:        wu.kevi@northeastern.edu
%   Last updated:   March 17, 2023


% Set default marker
if (nargin < 2)
    marker = 'rx';
end
MARKER_SIZE = 50;


% Get dimensions
imageDim = size(features);


% Get row-column subscripts of logical matrix
[y,x] = ind2sub(imageDim,find(features));


% Display on current figure
scatter(x,y,MARKER_SIZE,marker);


end