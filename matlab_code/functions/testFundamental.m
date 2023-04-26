function F = testFundamental(vA,vB)

% Construct the matrix A
A = zeros(size(vA,2),9);
for i = 1:size(vA,2)
    A(i,:) = [vA(1,i)*vB(1,i) vA(2,i)*vB(1,i) vB(1,i) ...
              vA(1,i)*vB(2,i) vA(2,i)*vB(2,i) vB(2,i) ...
              vA(1,i) vA(2,i) 1];
end

% Solve the homogeneous system of equations Af = 0 using SVD
[~, ~, V] = svd(A'*A);
f = V(:,end);

% Reshape f into a 3x3 matrix F and enforce rank 2 by zeroing out the smallest singular value
F = reshape(f,3,3);
[U, S, V] = svd(F);
S(end,end) = 0;
F = U*S*V';

% % Enforce the epipolar constraint by re-estimating F using SVD on the essential matrix
% K = [fx 0 cx; 0 fy cy; 0 0 1]; % Intrinsic matrix
% E = K'*F*K;
% [U, S, V] = svd(E);
% S(1,1) = 1;
% S(2,2) = 1;
% S(3,3) = 0;
% E = U*S*V';
% F = inv(K')*E*inv(K);

% Normalize F to ensure that the last element is 1
F = F/F(3,3);


end