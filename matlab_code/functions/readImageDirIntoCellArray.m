function imageCellArray = readImageDirIntoCellArray(imageDir)
%%readImageDirIntoCellArray Folder of images into cell array.
%   C = readImageDirIntoCellArray(D) attempts to read the contents of folder D
%   using imread into a cell array C.  Each cell in C contains data for an image
%   in D.
%
%   Contact:        kwu@draper.com
%   Last updated:   March 15, 2023


% Get files from directory
dirContents = dir(imageDir);
isFile = arrayfun(@(x) isfile(fullfile(x.folder,x.name)),dirContents);
dirFiles = dirContents(isFile);


% Read in image data from files
imageCellArray = arrayfun(@(x) imread(fullfile(x.folder,x.name)),dirFiles, ...
    'UniformOutput',false);


end