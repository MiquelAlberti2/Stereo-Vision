import numpy as np



def compute_candidate_fundamental_matrix(corresp):
    """
    Computes the coefficients of the fundamental matrix
    """
    #TODO
    pass

def compute_epipolar_line(M,pt):
    """
    Compute the conjugate epipolar line
    """
    #TODO
    pass

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

    thr = 5
    max_iter = 100 # number of iterations 
    iter=0
    exit = False
    while iter < max_iter and not exit:
        inliers = []
        # Randomly sample 8 points (minimum required to determine the matrix)
        i_sample = np.random.choice(len(corresp), 8, replace=False)

        corresp_sample = [corresp[i_sample[i]] for i in range(8)]

        # Fit a Fundamental Matrix with the small sample
        M = compute_candidate_fundamental_matrix(corresp_sample)

        # Compute inliers
        for match in corresp:
            pt1, pt2 = match[0], match[1]

            epipolar_line=compute_epipolar_line(M,pt1)
            dist = 0 #TODO, compute the "score" of the epipolar line with pt2

            if dist < thr:
                inliers.append((pt1,pt2))

        score = len(inliers)      
        
        # Update best parameters if score is better
        if score > best_score:
            best_inliers = inliers
            best_score = score
            print("current best score: ", best_score)

            if best_score > max((4*len(corresp)/5),4):
                # Is good enough
                exit=True

        iter+=1
        
    if not exit:
        print("maximum number of iterations reached with RANSAC!")
        
    # Compute the final fundamental matrix with all inliers
    return compute_candidate_fundamental_matrix(best_inliers), best_inliers

