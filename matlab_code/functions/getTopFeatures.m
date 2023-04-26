function [features,threshold] = getTopFeatures(R,n)
%%getTopFeatures Return the top number of features with corresponding threshold.
%   [FEATURES,THRESHOLD] = getTopFeatures(R,N) determines the minimum THRESHOLD
%   which at most N features from the response R exceeds, then returns the
%   logical matrix FEATURES denoting the location of those features.
%
%   Contact:        wu.kevi@northeastern.edu
%   Last updated:   April 13, 2023


% Determine threshold
n = min(n,numel(R) - 1);
Rsort = sort(R(:),'descend');
threshold = Rsort(n + 1);


% Get features
features = (R > threshold);


% Ignore features too close to boundaries (10px)
features(1:10,:) = false;
features(end-9:end,:) = false;
features(:,1:10) = false;
features(:,end-9:end) = false;


end