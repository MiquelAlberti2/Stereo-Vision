function checkFundamentalMatrix(F,featureA,featureB)
%%checkFundamentalMatrix Common checks for sensibility of fundamental matrix.
%   checkFundamentalMatrix(F,FEATUREA,FEATUREB) checks the fundamental matrix F
%   using features denoted by FEATUREA and FEATUREB, which contain the [ROW COL]
%   of each feature from image A and from image B.
%
%   Contact:        wu.kevi@northeastern.edu
%   Last updated:   April 17, 2023


% Fundamental matrix
% - Rank 2
if (rank(F) ~= 2)
    warning('F is not rank 2.');
end
% - Smallest eigenvalue
[~,S] = svd(F);
if ~(abs(min(diag(S))) < sqrt(eps))
    warning('Smallest eigenvalue of F is non-zero.')
end


% Epipolar lines
% - Geature vectors
vectA = [featureA(:,2)'; featureA(:,1)'; ones(1,length(featureA))];
vectB = [featureB(:,2)'; featureB(:,1)'; ones(1,length(featureB))];
% - Epipolar line coefficients corresponding to points from A
lineB = F*vectA;
% - Epipolar constraint
fulfillsEpipolarConstraint = false(1,size(lineB,2));
for i = 1:size(lineB,2)
    fulfillsEpipolarConstraint(i) = abs(lineB(:,i)'*F*vectA(:,i)) < sqrt(eps);
end
if ~all(fulfillsEpipolarConstraint)
    warning('At least one computed line does not fulfill epipolar constraint.');
end
% - Line contains original feature
containsFeature = false(1,size(vectA,2));
for i = 1:size(lineB,2)
    containsFeature(i) = abs(vectB(:,i)'*lineB(:,i)) < sqrt(eps);
end
if ~all(fulfillsEpipolarConstraint)
    warning('At least one computed line does not contain actual feature.');
end


end