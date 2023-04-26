function F = fundamentalMatrix(A,B)
%%fundamentalMatrix Fundamental matrix computation using 8-pt algorithm.
%   F = fundamentalMatrix(A,B) uses the 8 point correspondences provided by A
%   and B to compute the fundamental matrix F.  This uses the 8-point algorithm
%   that includes Hartley pre-conditioning.
%   
%   A and B are matrices where each row vector denotes the [ROW COL] sub-scripts
%   corresponding to the feature location in their respective images.  Note that
%   this corresponds to [Y X].
%
%   Contact:        wu.kevi@northeastern.edu
%   Last updated:   April 18, 2023


% Hartley's pre-conditioning
% - Get 2D feature vectors as [x; y; 1]
a0 = [flip(A,2)'; ones(1,size(A,1))];
b0 = [flip(B,2)'; ones(1,size(A,1))];
% - Translate center of mass to origin
Ta = [1 0 -mean(a0(1,:));
      0 1 -mean(a0(2,:));
      0 0  1            ];
Tb = [1 0 -mean(b0(1,:));
      0 1 -mean(b0(2,:));
      0 0  1            ];
a1 = Ta*a0;
b1 = Tb*b0;
% - Determine scale for average point distribution to be sqrt(2)
avgDistA = mean(sqrt(sum(a1(1:2,:).^2,1)));
avgDistB = mean(sqrt(sum(b1(1:2,:).^2,1)));
Sa = [sqrt(2)/avgDistA 0                0;
      0                sqrt(2)/avgDistA 0;
      0                0                1];
Sb = [sqrt(2)/avgDistB 0                0;
      0                sqrt(2)/avgDistB 0;
      0                0                1];
a2 = Sa*a1;
b2 = Sb*b1;


% Vectors
% - x-y
x = a2(1,:)';
y = a2(2,:)';
xp = b2(1,:)';
yp = b2(2,:)';
% - x-y products
% xxp = x.*xp;
% xyp = x.*yp;
% yxp = y.*x;
% yyp = y.*yp;
xpx = xp.*x;
ypx = yp.*x;
xpy = xp.*y;
ypy = yp.*y;
% - First eigenmatrix M (appears as A in lecture, and actually M'*M)
% M = [xxp xyp x yxp yyp y xp yp ones(length(x),1)];
M = [xpx xpy xp ypx ypy yp x y ones(length(x),1)];


% First eigendecomposition
[~,S1,V1] = svd(M);
[~,isSmallestEigenval] = min(diag(S1));
F1 = reshape(V1(:,isSmallestEigenval),3,3);


% Second eigendecomposition
[U2,S2,V2] = svd(F1);
[~,isSmallestEigenval] = min(diag(S2));


% Singular constraint for rank 2
S3 = S2;
S3(isSmallestEigenval,isSmallestEigenval) = 0;
F3 = U2*S3*V2';


% Hartley pre-conditioning inversion
F = (Sb*Tb)'*F3*(Sa*Ta);


end