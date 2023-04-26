function G = getGaussianMask(o,n)
%%getGaussianMask Generates a Gaussian mask provided a sigma value.
%   G = getGaussianMask(O) generates a Gaussian mask with sigma value O, where
%   the mask is an N-by-N matrix and N is the minimum odd integer that is
%   greater than 5*O.
%
%   G = getGaussianMask(O,N) instead returns a mask that is N-by-N.
%
%   Contact:        wu.kevi@northeastern.edu
%   Last updated:   March 17, 2023


% Minimum size
nmin = ceil(5*o);
if (mod(nmin,2) == 0)
    nmin = nmin + 1;
end
if (nargin < 2)
    n = nmin;
elseif (n < nmin)
    warning('Input mask size is below minimum');
end


% Mask generation
s = -floor(n/2):floor(n/2);
t = s';
w = exp(-(s.^2 + t.^2)/(2*o^2));
G = w/sum(w,'all');


end