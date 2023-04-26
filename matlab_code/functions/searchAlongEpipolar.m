function [vectA,vectB,lineB] = searchAlongEpipolar(xSpan,F,imageA,imageB,useNxc)
%%searchAlongEpipolar Epipolar line search.
%   [VECTA,VECTB] = searchAlongEpipolar(XSPAN,F,IMAGEA,IMAGEB) searches along
%   each epipolar line from IMAGEB corresponding to each point from IMAGEA and
%   then finds the point from IMAGEB on that line with the best correspondence
%   score.  XSPAN sets the search space along the epipolar line as the range of
%   x-coordinates in IMAGEB to test, while F is the fundamental matrix from a
%   point in IMAGEA to a line in IMAGEB.  searchAlongEpipolar then returns the
%   VECTA and VECTB arrays of feature vectors [X; Y; 1] denoting each match
%   found between IMAGEA and IMAGEB, respectively.
%
%   [VECTA,VECTB,LINEB] = searchAlongEpipolar also returns the LINEB
%   coefficients corresponding to each epipolar line, where each column
%   corresponds to a line.
%
%   searchAlongEpipolar(XPSAN,F,IMAGEA,IMAGEB,USENXC) also sets USENXC, a flag
%   to determine which scoring method to use.  By default, USENXC is TRUE and
%   makes searchAlongEpipolar use a normalized cross-correlation search via
%   nxcFeatureMatching.
%
%   Contact:        wu.kevi@northeastern.edu
%   Last updated:   April 18, 2023


% Constants
PATCH_SIZE = [10 10];
MAX_DISPARITY = 100;


% Set default input
if (nargin < 5)
    useNxc = true;
end
imageA = double(imageA);
imageB = double(imageB);


% Get each pixel in A as a feature vector
[numRowA,numColA] = size(imageA(:,:,1));
[colMatA,rowMatA] = meshgrid(1:numColA,1:numRowA);
vectA = [colMatA(:)'; rowMatA(:)'; ones(1,numel(colMatA))];


% Get patch indices
idxColA = vectA(1,:) + (-floor(PATCH_SIZE(2)/2):floor(PATCH_SIZE(2)/2))';
idxRowA = vectA(2,:) + (-floor(PATCH_SIZE(1)/2):floor(PATCH_SIZE(1)/2))';


% Compute coefficients for corresponding epipolar line in B
lineB = F*vectA;


% Construct the epipolar search space (each column being an epipolar line in B)
% - Compute columns of y-coordinates corresponding to xSpan in B
yCoord = (-xSpan(:)*lineB(1,:) - lineB(3,:))./lineB(2,:);
% - Construct corresponding x-coordinates
numLine = size(lineB,2);
xCoord = repmat(xSpan(:),1,numLine);
% - Get max possible Y coordinate for B to set minimum y-coefficient threshold
minYCoef = 1/size(imageB,1);
% - Redo any near-zero y-coefficient (i.e. vertical line) with xSpan as ySpan
ySpan = xSpan(:);
isYCoefZero = (abs(lineB(2,:)) < minYCoef);
yCoord(:,isYCoefZero) = repmat(ySpan,1,sum(isYCoefZero));
xCoord(:,isYCoefZero) = (-ySpan*lineB(2,isYCoefZero) - lineB(3,isYCoefZero)) ...
                        ./lineB(1,isYCoefZero);


% Format coordinates
yCoord = round(yCoord);
xCoord = round(xCoord);


% Perform search
% - Buffer
dimB = size(imageB(:,:,1));
vectB = nan(size(vectA));
c = 0;
t0 = tic;
crem = useNxc*100 + ~useNxc*5;
maxScoreB = nan(1,numLine);
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
    % - Track speed
    c = c + 1;
    if mod(c,crem) == 0
        t1 = toc(t0);
        avgrate = c/t1;
        remtime = (numLine - i)/avgrate;
        fprintf(1,['Took %.2f seconds to process %d total points.  ' ...
                   'Estimated %.2f seconds remaining.\n'],t1,c,remtime);
    end
    % - Note which points along epipolar line are outside image
    isXOutside = (xCoord(:,i) < 1) | (xCoord(:,i) > dimB(2));
    isYOutside = (yCoord(:,i) < 1) | (yCoord(:,i) > dimB(1));
    isPointInB = ~isXOutside & ~isYOutside;
    if ~any(isPointInB)
        continue;
    end
    % - Set feature vector for points along epipolar line within image
    searchVectB = [xCoord(isPointInB,i)'; ...
                   yCoord(isPointInB,i)'; ...
                   ones(1,length(xSpan) - sum(~isPointInB))];
    % - Get image patch centered around point from A
    imagePatchA = imageA(idxRowA(:,i),idxColA(:,i));
    % - (Heuristic) Get image patch within a distance around lineB
    xBound = [min(searchVectB(1,:)) max(searchVectB(1,:))] ...
        + [-PATCH_SIZE(2) PATCH_SIZE(2)];
        xBound(1) = max(xBound(1),1); % IMAGE BOUND
        xBound(1) = max(xBound(1),vectA(1,i) - MAX_DISPARITY); % REDUCE SEARCH
        xBound(2) = min(xBound(2),size(imageB,2)); % IMAGE BOUND
        xBound(2) = min(xBound(2),vectA(1,i) + MAX_DISPARITY); % REDUCE SEARCH
    yBound = [min(searchVectB(2,:)) max(searchVectB(2,:))] ...
        + [-PATCH_SIZE(1) PATCH_SIZE(1)];
        yBound(1) = max(yBound(1),1); % IMAGE BOUND
        yBound(1) = max(yBound(1),vectA(2,i) - MAX_DISPARITY); % REDUCE SEARCH
        yBound(2) = min(yBound(2),size(imageB,1)); % IMAGE BOUND
        yBound(2) = min(yBound(2),vectA(2,i) + MAX_DISPARITY); % REDUCE SEARCH
        imagePatchB = imageB(yBound(1):yBound(2),xBound(1):xBound(2));
%     imagePatchB = imageB;
    % - Skip if bounds unsatisfied
    if any(diff(xBound) <= 0) || any(diff(yBound) <= 0)
        continue;
    end
    % - Search
    if useNxc % nxc
%         nxcB = computeNxc(imagePatchA,imageB);
        nxcB = zeros(size(imageB));
        nxcPatchB = computeNxc(imagePatchA,imagePatchB);
%         nxcB = nxcPatchB;
        nxcB(yBound(1):yBound(2),xBound(1):xBound(2)) = nxcPatchB;
        isNonzero = find(nxcB);
        if isempty(isNonzero)
            continue;
        end
        [yNonzero,xNonzero] = ind2sub(size(nxcB),isNonzero);
        scoreB = nxcB(isNonzero);
    else % abs intensity difference
        idxColB = searchVectB(1,:) ...
            + (-floor(PATCH_SIZE(2)/2):floor(PATCH_SIZE(2)/2))';
        idxRowB = searchVectB(2,:) ...
            + (-floor(PATCH_SIZE(1)/2):floor(PATCH_SIZE(1)/2))';
        scoreB = zeros(1,size(searchVectB,2));
        for j = 1:size(searchVectB,2)
            if any(idxColB(:,j) < 1) || any(idxRowB(:,j) < 1) ...
                    || any(idxColB(:,j) > dimB(2)) ...
                    || any(idxRowB(:,j) > dimB(2))
                continue
            end
            imagePatchB = imageB(idxRowB(:,j),idxColB(:,j));
            scoreB(j) = 1/sum(abs(imagePatchA - imagePatchB),'all');
        end
    end
    % - Find point on line with best score
    [maxScoreB(i),isMax] = max(scoreB);
    if useNxc
        vectB(:,i) = [xNonzero(isMax); yNonzero(isMax); 1];
    else
        vectB(:,i) = searchVectB(:,isMax);
    end
end


end