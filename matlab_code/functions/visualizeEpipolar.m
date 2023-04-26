function visualizeEpipolar(F,pointA,imageA,imageB)
%%visualizeEpipolar Side-by-side plot of point-to-epipolar between two images.
%   visualizeEpipolar(F,POINTA,IMAGEA,IMAGEB) computes the epipolar line in
%   IMAGEB corresponding to the feature POINTA in IMAGEA using the fundamental
%   matrix F, then generates a 1-by-2 plot of both images with POINTA on the
%   left and its corresponding line F*POINTA on the right.
%
%   visualizeEpipolar(LINEB,POINTA,IMAGEA,IMAGEB) uses the LINEB for the
%   epipolar line instead.
%
%   Contact:        wu.kevi@northeastern.edu
%   Last updated:   April 18, 2023


% Constants
POINT_COLOR = 'r';
LINE_COLOR = 'b';
POINT_SIZE = 50;
LINE_WIDTH = 2;


% Input parsing
% - Get feature vector
switch length(pointA)
    case 1 % input is {[ROW COL]}
        vectA = [pointA{1}(2);
                 pointA{1}(1);
                 1];
    case 2 % input is [ROW COL]
        vectA = [pointA(2);
                 pointA(1);
                 1];
    case 3 % input is [X; Y; 1]
        vectA = pointA;
end
% - Get line coefficients
if all(size(F) == 3)
    lineB = F*vectA;
else % input is lineB
    lineB = F;
end
% - Re-scale vectors
vectA = vectA/vectA(3);
origB = lineB;
lineB = lineB/lineB(3);
% - Set function to compute y-coordinate of lineB when given x-coordinate
getY = @(x) (-lineB(1)*x - lineB(3))/lineB(2);


% Plotting
fig = figure;
tiledlayout(1,2,'TileSpacing','tight','Padding','compact');
t1 = nexttile;
    imshow(imageA);
    hold on;
    scatter(vectA(1),vectA(2),POINT_SIZE,POINT_COLOR,'filled');
    title(t1,[{sprintf('p_A(row,col) = (%d,%d)',vectA(2),vectA(1))}, ...
             {sprintf('v_A(x,y,1) = (%d,%d,1)''',vectA(1),vectA(2))}]);
t2 = nexttile;
    imshow(imageB);
    hold on;
    plot(t2.XLim,[getY(t2.XLim(1)) getY(t2.XLim(2))],LINE_COLOR, ...
        'LineWidth',LINE_WIDTH);
    title(t2,sprintf('l_B = Fv_A = (%.2f,%.2f,%.2f)''', ...
        origB(1),origB(2),origB(3)));
fig.Position(4) = 1/2*fig.Position(3);


end