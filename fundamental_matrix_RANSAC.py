import numpy as np



def compute_candidate_fundamental_matrix(corresp):
    """
    Computes the coefficients of the fundamental matrix
    that match the correspondances given
    """
    n=len(corresp)

    # build the system of equations Ah=0
    A = np.empty((n, 9))

    for i in range(n):
        pt1, pt2 =corresp[i][0], corresp[i][1]
        x1, y1 = pt1[0], pt1[1]
        x2, y2 = pt2[0], pt2[1]

        A[i] = np.array([x1*x2, x1*y2, x1, y1*x2, y1*y2, y1, x2, y2, 1])

    # now we can solve the system
    At = np.transpose(A)

    # compute the SVD of A^t A
    u, s, vh = np.linalg.svd(At @ A)

    # h is the column of U associated with the smallest singular value in S
    min_i = np.argmin(s)
    column_result = u[:,min_i]

    F = np.reshape(column_result, (3, 3))

    # enforce that F must have rank 2
    u, s, vh = np.linalg.svd(F)
    smallest_sv_i = np.argmin(s)
    s[smallest_sv_i] = 0

    F = u @ np.diag(s) @ vh

    return F


def estimate_fundamental_matrix_RANSAC(corresp):
    """
    INPUT
     - list of pairs (tuples) of matching points
    OUTPUT
     - The inliers
     - Fundamental matrix computed with all the inliers
    """
    best_inliers = None
    best_score = 0

    thr = 0.001
    max_iter = 100 # number of iterations 
    iter=0
    exit = False
    while iter < max_iter and not exit:
        inliers = []
        # Randomly sample 8 points (minimum required to determine the matrix)
        i_sample = np.random.choice(len(corresp), 8, replace=False)

        corresp_sample = [corresp[i_sample[i]] for i in range(8)]

        # Fit a Fundamental Matrix with the small sample
        F = compute_candidate_fundamental_matrix(corresp_sample)

        # Compute inliers
        for match in corresp:
            pt1, pt2 = match[0], match[1]

            # compute the coefficients of the epipolar line
            pt2 = np.hstack([pt2, np.ones((1), dtype=int)]).T # Homogenize coordinate
            epipolar_line = np.dot(F,pt2)

            # compute the distance from pt1 to the estimated epipolar line
            num = abs(epipolar_line[0]*pt1[0] + epipolar_line[1]*pt1[1] + epipolar_line[2])
            den = np.sqrt(epipolar_line[0]**2 + epipolar_line[1]**2)
            dist = num / den

            if dist < thr:
                inliers.append((pt1,pt2))

        score = len(inliers)      
        
        # Update best parameters if score is better
        if score > best_score:
            best_inliers = inliers
            best_score = score
            print("current best score: ", best_score)

            if best_score > max((4*len(corresp)/5),8):
                # Is good enough
                exit=True

        iter+=1
        
    if not exit:
        print("maximum number of iterations reached with RANSAC!")
        
    # Compute the final fundamental matrix with all inliers
    return compute_candidate_fundamental_matrix(best_inliers), best_inliers