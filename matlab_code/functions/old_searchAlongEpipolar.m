function match = old_searchAlongEpipolar(jSearch,vectA,imageA,imageB,direction)
%%searchAlongEpipolar Epipolar line search.
%   MATCH = searchAlongEpipolar(JSEARCH,VECTA,IMAGEA,IMAGEB,DIRECTION) searches
%   along an epipolar line from IMAGEB corresponding to a point from IMAGEA --
%   i.e. VECTA = [x; y; 1] -- for the pixel MATCH that minimizes the spatial
%   difference in grayscale intensities.
%
%   DIRECTION sets the direction of pixel search, where 'horz' searches along x
%   and 'vert' searches along y.
%
%   JSEARCH sets the search range.
%
%   Used in conjunction with denseDisparityMaps.
%
%   Yuexi: can use NCC to perform search instead of pixel difference.  For now,
%   the latter is easier for testing.
%
%   Contact:        wu.kevi@northeastern.edu
%   Last updated:   April 13, 2023


% Initialize
score = inf; % running match score
match = 0; % running match


% Indices for A
switch vectA(2)
    case 1
        yA = 1:3;
    case size(imageA,1)
        yA = (size(imageA,1) - 2):size(imageA,1);
    otherwise
        yA = (vectA(2) - 1):(vectA(2) + 1);
end
switch vectA(1)
    case 1
        xA = 1:3;
    case size(imageA,2)
        xA = (size(imageA,2) - 2):size(imageA,2);
    otherwise
        xA = (vectA(1) - 1):(vectA(1) + 1);
end


% Direction flag
if strcmp(direction,'horz')
    fixY = true;
elseif strcmp(direction,'vert')
    fixY = false;
end


% Loop
for j = jSearch
    % - Indices for B
    if fixY
        yB = yA; % set same
        switch j
            case 1
                xB = 1:3;
            case size(imageB,2)
                xB = (size(imageB,2) - 2):size(imageB,2);
            otherwise
                xB = (j - 1):(j + 1);
        end
    else
        switch j
            case 1
                yB = 1:3;
            case size(imageB,1)
                yB = (size(imageB,1) - 2):size(imageB,1);
            otherwise
                yB = (j - 1):(j + 1);
        end
        xB = xA; % set same
    end
    % - Spatial difference
    dpixel = sum(abs(imageA(yA,xA) - imageB(yB,xB)),'all');
    % - Search update
    if (dpixel < score)
        score = dpixel;
        match = j;
    end
end


end