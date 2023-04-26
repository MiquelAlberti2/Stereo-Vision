function c = fastncc(g,f)
%%fastncc Simple but fast estimate of normalized cross-correlation.
%   C = fastncc(G,F) estimates the normalized cross-correlation of the image F
%   with an image patch G, then returns it in a matrix C the same size of F.
%
%   This is a rough approximation using only conv2, subtracting out the mean,
%   and dividing out the standard deviation and size.  It is intended only for
%   use where only the relative sizes of the correlations are important, even in
%   a simplified sense.  
% 
%   Designed for use in epipolar line search.
%
%   I hate my life.
%
%   Contact:        wu.kevi@northeastern.edu
%   Last updated:   April 17, 2023


% Subtract out means
f0 = f - mean(f,'all');
g0 = g - mean(g,'all');


% Pad image with zeros
lr = zeros(size(f,1),size(g,2));
ud = zeros(size(g,1),size(f,2));
fpad = [zeros(size(g)) ud zeros(size(g));
        lr             f0 lr;
        zeros(size(g)) ud zeros(size(g))];


% Compute normalized cross-correlation
c = conv2(fpad,rot90(g0,2),'same');
c = c./(numel(f)*std(f,0,'all')*std(g,0,'all'));
c = c(size(g,1) + (1:size(f,1)),size(g,2) + (1:size(f,2)));


end