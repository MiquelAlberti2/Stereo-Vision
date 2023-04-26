function plotFeaturePairs(match,A,B,imageA,imageB,flag)
%%plotFeaturePairs Create a figure to plot feature pairs between two figures.
%   plotFeaturePairs(MATCH,A,B,IMAGEA,IMAGEB) plots the two images IMAGEA and
%   IMAGEB side-by-side overlaid with their respective features A and B, then
%   displays the feature pairs MATCH by creating a line between features from
%   both images.  A and B are logical matrices that locate the features.
%
%   MATCH is an array of cells which contain the row-column sub-scripts for a
%   feature from A and a feature from B, in that order.
%
%   plotFeaturePairs(MATCH,A,B,IMAGEA,IMAGEB,FLAG) adds the input setting FLAG
%   that is new to Project 3, where the value of FLAG determines whether the
%   function shows:
%       0 (default):        all lines
%       non-zero number:    that number of lines to show (in order of input)
%       numeric array:      these lines to show (with indices to input)
%       non-numeric:        each line, one-by-one, replacing the previous
%
%
%   Contact:        wu.kevi@northeastern.edu
%   Last updated:   April 12, 2023


% Set default input
if (nargin < 6)
    flag = 0;
end


% Create initial figure
figure('Name','Feature Pairs');
m = montage({imageA imageB},'ThumbnailSize',[]);
hold on;


% Overlay with features
% - Features from A
showFeatures(A,'rx');
% - Padding to offset B
offsetB = [false(size(A)) B];
% - Features from B
showFeatures(offsetB,'go');
% - Legend
legend({'Features A' 'Features B'},'location','best');


% Display feature pair lines
% - Offset B features
offsetIdxBMatch = sub2ind(size(imageB),match{2}(:,1),match{2}(:,2)) ...
                  + numel(imageA); % account for offset by image A
[offsetRowBMatch,offsetColBMatch] = ind2sub(size(m.CData),offsetIdxBMatch);
% - Create first line
firstObj = plot([match{1}(1,2) offsetColBMatch(1)], ...
                [match{1}(1,1) offsetRowBMatch(1)], ...
                'LineWidth',2,'HandleVisibility','off');
% - Create remaining lines
if isnumeric(flag) && (length(flag) == 1)
    numLine = (flag == 0)*size(match{1},1) + flag;
    itrLine = 2:numLine;
elseif isnumeric(flag)
    itrLine = flag;
    if ~any(flag == 1)
        delete(firstObj);
    end
else
    numLine = size(match{1},1);
    itrLine = 2:numLine;
    titleObj = title('Correspondence 1');
    fprintf(1,'\tShowing line %d of %d.  Press any key to continue.\n',1, ...
            numLine);
    pause;
    delete(firstObj);
    titleObj.String = '';
end
for i = itrLine
    plotObj = plot([match{1}(i,2) offsetColBMatch(i)], ...
                   [match{1}(i,1) offsetRowBMatch(i)], ...
                   'LineWidth',2,'HandleVisibility','off');
    if ~isnumeric(flag)
        titleObj.String = sprintf('Correspondence %d',i);
        fprintf(1,'\tShowing line %d of %d.  Press any key to continue.\n', ...
                i,numLine);
        pause;
        delete(plotObj);
        titleObj.String = '';
    end
end


end