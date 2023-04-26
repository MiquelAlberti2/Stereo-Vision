function [dx,dy,d] = denseDisparityMaps(F,n,imageA,imageB)
%%denseDisparityMaps Disparity maps from fundamental matrix.
%   [DX,DY,D] = denseDisparityMaps(F,N,IMAGEA,IMAGEB) takes the fundamental
%   matrix F that relates a point in IMAGEA to an epipolar line in IMAGEB and
%   generates the disparity maps DX, DY, and D.  These are horizontal, vertical,
%   and magnitude components scaled into grayscale from 0 to 255.
%
%   N searches the search size.
%
%   TBD: Code vector direction with hue.
%
%   Contact:        wu.kevi@northeastern.edu
%   Last updated:   April 13, 2023


% Construct search space from A
dimA = size(imageA);
[colsA,rowsA] = meshgrid(1:dimA(2),1:dimA(1));


% Buffer for search
xcoefB = colsA;
ycoefB = rowsA;
scoefB = ones(dimA);
dx = nan(dimA);
dy = nan(dimA);


% Compute line coefficients for B
for i = 1:numel(imageA)
    % - Vector from A
    vectA = [colsA(i); rowsA(i); 1]; % x y 1
    % - Coefficients for corresponding line from B
    lineB = F*vectA;
%     lineB = lineB/lineB(3); not sure if to scale
    xcoefB(i) = lineB(1);
    ycoefB(i) = lineB(2);
    scoefB(i) = lineB(3);
    % - Epipolar line search (vectorize this?)
        % -- Boundary distances
        distToLeft = abs(scoefB(i)/xcoefB(i));
%         distToRight = abs((scoefB(i) - dimA(2)*xcoefB(i))/xcoefB(i));
        distToTop = abs(scoefB(i)/ycoefB(i));
        distXA = vectA(1) - distToLeft;
        distYA = vectA(2) - distToTop;
        % -- Search range
        jdxMin = round(distXA - n);
            jdxMin = max(jdxMin,1); % offset into bounds
        jdxMax = round(distXA + n);
            jdxMax = min(jdxMax,dimA(2));
        jdyMin = round(distYA - n);
            jdyMin = max(jdyMin,1);
        jdyMax = round(distYA + n);
            jdyMax = min(jdyMax,dimA(1));
        % -- Search (there must be a better way to vectorize?)
        estx = old_searchAlongEpipolar(jdxMin:jdxMax,vectA,imageA,imageB,'horz');
        esty = old_searchAlongEpipolar(jdyMin:jdyMax,vectA,imageA,imageB,'vert');
    % - Component disparities
    dx(i) = vectA(1) - estx;
    dy(i) = vectA(2) - esty;
end


% Magnitude disparity
d = sqrt(dx.^2 + dy.^2);


% Scaling
dx = dx - min(dx,[],'all');
    dx = dx/max(dx,[],'all')*255;
    dx = uint8(dx);
dy = dy - min(dy,[],'all');
    dy = dy/max(dy,[],'all')*255;
    dy = uint8(dy);
d = d - min(d,[],'all');
    d = d/max(d,[],'all')*255;
    d = uint8(d);


end