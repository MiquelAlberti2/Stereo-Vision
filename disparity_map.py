import numpy as np

def search_along_epipolar(jSearch, vectA, imageA, imageB, direction):
    """
    Epipolar line search that searches along an epipolar line from IMAGEB corresponding to a point from IMAGEA
    for the pixel MATCH that minimizes the spatial difference in grayscale intensities.

    Parameters:
    jSearch (list): search range
    vectA (list): [x, y, 1] vector of point from IMAGEA
    imageA (numpy array): image array of IMAGEA
    imageB (numpy array): image array of IMAGEB
    direction (str): 'horz' for horizontal search or 'vert' for vertical search

    Returns:
    match (int): pixel position that minimizes the spatial difference in grayscale intensities
    """

    # Initialize
    score = float('inf') # running match score
    match = 0 # running match

    # Indices for A
    if vectA[1] == 1:
        yA = range(1, 4)
    elif vectA[1] == imageA.shape[0]:
        yA = range(imageA.shape[0] - 2, imageA.shape[0] + 1)
    else:
        yA = range(vectA[1] - 1, vectA[1] + 2)

    if vectA[0] == 1:
        xA = range(1, 4)
    elif vectA[0] == imageA.shape[1]:
        xA = range(imageA.shape[1] - 2, imageA.shape[1] + 1)
    else:
        xA = range(vectA[0] - 1, vectA[0] + 2)

    # Direction flag
    if direction == 'horz':
        fixY = True
    elif direction == 'vert':
        fixY = False

    # Loop
    for j in jSearch:
        # Indices for B
        if fixY:
            yB = yA # set same
            if j == 1:
                xB = range(1, 4)
            elif j == imageB.shape[1]:
                xB = range(imageB.shape[1] - 2, imageB.shape[1] + 1)
            else:
                xB = range(j - 1, j + 2)
        else:
            if j == 1:
                yB = range(1, 4)
            elif j == imageB.shape[0]:
                yB = range(imageB.shape[0] - 2, imageB.shape[0] + 1)
            else:
                yB = range(j - 1, j + 2)
            xB = xA # set same

        # Spatial difference
        dpixel = np.sum(np.abs(imageA[np.ix_(yA, xA)] - imageB[np.ix_(yB, xB)]))

        # Search update
        if dpixel < score:
            score = dpixel
            match = j

    return match



def dense_disparity_map(F, n, imageA, imageB):
    # Construct search space from A
    dimA = imageA.shape
    colsA, rowsA = np.meshgrid(np.arange(dimA[1]), np.arange(dimA[0]))

    # Buffer for search
    xcoefB = colsA.copy()
    ycoefB = rowsA.copy()
    scoefB = np.ones(dimA)
    dx = np.full(dimA, np.nan)
    dy = np.full(dimA, np.nan)

    # Compute line coefficients for B
    for i in range(imageA.size):
        # - Vector from A
        vectA = np.array([colsA.flat[i], rowsA.flat[i], 1])  # x y 1
        # - Coefficients for corresponding line from B
        lineB = F @ vectA
        xcoefB.flat[i] = lineB[0]
        ycoefB.flat[i] = lineB[1]
        scoefB.flat[i] = lineB[2]
        # - Epipolar line search
        distToLeft = abs(scoefB.flat[i] / xcoefB.flat[i])
        distToTop = abs(scoefB.flat[i] / ycoefB.flat[i])
        distXA = vectA[0] - distToLeft
        distYA = vectA[1] - distToTop
        # -- Search range
        jdxMin = round(distXA - n)
        jdxMin = max(jdxMin, 0)
        jdxMax = round(distXA + n)
        jdxMax = min(jdxMax, dimA[1]-1)
        jdyMin = round(distYA - n)
        jdyMin = max(jdyMin, 0)
        jdyMax = round(distYA + n)
        jdyMax = min(jdyMax, dimA[0]-1)
        # -- Search
        estx = search_along_epipolar(np.arange(jdxMin, jdxMax+1), vectA, imageA, imageB, 'horz')
        esty = search_along_epipolar(np.arange(jdyMin, jdyMax+1), vectA, imageA, imageB, 'vert')
        # - Component disparities
        dx.flat[i] = vectA[0] - estx
        dy.flat[i] = vectA[1] - esty

    # Magnitude disparity
    d = np.sqrt(dx ** 2 + dy ** 2)

    # Scaling
    dx = dx - np.nanmin(dx)
    dx = dx / np.nanmax(dx) * 255
    dx = dx.astype(np.uint8)
    dy = dy - np.nanmin(dy)
    dy = dy / np.nanmax(dy) * 255
    dy = dy.astype(np.uint8)
    d = d - np.nanmin(d)
    d = d / np.nanmax(d) * 255
    d = d.astype(np.uint8)

    return dx, dy, d
