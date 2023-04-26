%%test_searchAlongEpipolar
%   Test on Cast stereo pair.
%   
%   Contact:        wu.kevi@northeastern.edu
%   Last updated:   April 18, 2023


% Load Cast image data
imageA = ones(3);
imageB = ones(3);


% Set fundamental matrix
F = [0 0 0;
     0 0 -1;
     0 1 0];


% Set xSpan
xSpan = 1:576;


% Set patch size
patchSize = [2 2];


% Get each pixel in A as a feature vector
[numRowA,numColA] = size(imageA(:,:,1));
[colMatA,rowMatA] = meshgrid(1:numColA,1:numRowA);
vectA = [colMatA(:)'; rowMatA(:)'; ones(1,numel(colMatA))];


% Get range of indices as column vectors, corresponding to each image patch
itrRange = (-floor(patchSize(2)/2):floor(patchSize(2)/2));
idxColA = zeros(length(itrRange),length(vectA(1,:)));
idxRowA = zeros(length(itrRange),length(vectA(1,:)));
for i = 1:length(vectA(1,:))
    idxColA(:,i) = vectA(1,i) + itrRange';
    idxRowA(:,i) = vectA(2,i) + itrRange';
end


% Compute coefficients for corresponding epipolar line in B
lineB = F*vectA;


% Construct the epipolar search space (each column being an epipolar line in B)
% - Compute columns of y-coordinates corresponding to xSpan in B
yCoord = (-xSpan(:)*lineB(1,:) - lineB(3,:))./lineB(2,:);
% - Construct corresponding x-coordinates
numLine = size(lineB,2);
xCoord = repmat(xSpan(:),1,numLine);
% NOTE: Removed check for vertical lines, which crashes this


% Perform search
% - Buffer
dimB = size(imageB(:,:,1));
vectB = nan(size(vectA));
% - Iterate through each point in A
for i = 1:numLine
    % - Skip points from A too close to boundary
    isTooClose = (vectA(1,i) <= PATCH_SIZE(2)) ...
        || (vectA(1,i) > (numColA - PATCH_SIZE(2))) ...
        || (vectA(2,i) <= PATCH_SIZE(1)) ...
        || (vectA(2,i) > (numRowA - PATCH_SIZE(1)));
    if isTooClose
        continue;
    end
    % - Note which points along epipolar line are outside image
    isXOutside = (xCoord(:,i) < 1) | (xCoord(:,i) > dimB(2));
    isYOutside = (yCoord(:,i) < 1) | (yCoord(:,i) > dimB(1));
    isPointInB = ~isXOutside & ~isYOutside;
    % - Set feature vector for points along epipolar line within image
    searchVectB = [xCoord(isPointInB,i)'; ...
                   yCoord(isPointInB,i)'; ...
                   ones(1,length(xSpan) - sum(~isPointInB))];
    % - Get image patch centered around point from A
    imagePatchA = imageA(idxRowA(:,i),idxColA(:,i));
    % - Search
    nxcB = fastncc(double(imagePatchA),doubleImageB);
    % - Find point on line with best score
    [~,isMax] = max(scoreB);
    vectB(:,i) = searchVectB(:,isMax);
end


% Remove NaNs
matchFound = isfinite(vectB(1,:));
    vectA = vectA(:,matchFound);
    vectB = vectB(:,matchFound);
    lineB = lineB(:,matchFound);


% Compute disparities
dx = vectA(1,:) - vectB(1,:);
dy = vectA(2,:) - vectB(2,:);