function S = nonmaxSuppression(R,n)
%%nonmaxSuppression Non-max suppression of response matrix.
%   S = nonmaxSuppression(R,N) suppresses values around maxima in R within a
%   neighborhood of an N-by-N square matrix, returning the non-max suppressed
%   matrix S.
%
%   nonmaxSuppression performs suppression until every pixel has either been
%   suppressed or contains a local maximum.
%
%   Contact:        wu.kevi@northeastern.edu
%   Last updated:   April 13, 2023


% Initial buffer
ndim = size(R);
S = R;
isDone = false(size(R));


% Neighborhood distance
di = (n - 1)/2;


% Sorted list with corresponding sub-scripts
[~,idx] = sort(R(:),'descend');
[rows,cols] = ind2sub(size(R),idx);



% Iteration
for c = 1:length(idx)
    % - Skip if value is suppressed
    ind = idx(c);
    if isDone(ind)
        continue;
    end
    % - Get sub-scripts
    i = rows(c);
    j = cols(c);
    iLocal = max(i - di,1):min(i + di,ndim(1));
    jLocal = max(j - di,1):min(j + di,ndim(2));
    % - Suppress
    S(iLocal,jLocal) = 0;
    S(ind) = R(ind);
    % - Set flag that neighborhood has been cleared
    isDone(iLocal,jLocal) = true;
end
    

end