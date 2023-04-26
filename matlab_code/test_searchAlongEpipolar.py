import numpy as np
grayCast1;
grayCast2;


# Set fundamental matrix
F = np.array([[0, 0, 0], 
              [0, 0, -1], 
              [0, 1, 0]])


# Set xSpan
xSpan = np.arange(1, 577)


# Set patch size
patchSize = (75, 75)


# Get each pixel in A as a feature vector
numRowA, numColA = imageA.shape
colMatA, rowMatA = np.meshgrid(np.arange(0, numColA), np.arange(0, numRowA))
vectA = np.vstack((colMatA.flatten(), rowMatA.flatten(), np.ones(1, colMatA.size)))


# Get range of indices as column vectors, corresponding to each image patch
itrRange = np.arange(-np.floor(patchSize[1]/2), np.floor(patchSize[1]/2)+1)
idxColA = np.zeros((len(itrRange), vectA.shape[1]))
idxRowA = np.zeros((len(itrRange), vectA.shape[1]))
for i in range(vectA.shape[1]):
    idxColA[:, i] = vectA[0, i] + itrRange.transpose()
    idxRowA[:, i] = vectA[1, i] + itrRange.transpose()


# Compute coefficients for corresponding epipolar line in B
lineB = np.matmul(F,vectA)


# Construct the epipolar search space (each column being an epipolar line in B)
# - Compute columns of y-coordinates corresponding to xSpan in B
yCoord = (-xSpan[:, np.newaxis] * lineB[0, :] - lineB[2, :]) / lineB[1, :]
# - Construct corresponding x-coordinates
numLine = lineB.shape[1]
xCoord = np.tile(xSpan[:, np.newaxis], (1, numLine))
# NOTE: Removed check for vertical lines, which crashes this


# Perform search
# - Buffer
dimB = imageB.shape[:2]
vectB = np.full(vectA.shape, np.nan)

# - Iterate through each point in A
for i in range(numLine):
    # - Skip points from A too close to boundary
    isTooClose = (vectA[0,i] <= patchSize[1]/2) \
                 or (vectA[0,i] > (numColA - patchSize[1]/2)) \
                 or (vectA[1,i] <= patchSize[0]/2) \
                 or (vectA[1,i] > (numRowA - patchSize[0]/2))
    if isTooClose:
        continue
        
    # - Note which points along epipolar line are outside image
    isXOutside = (xCoord[:,i] < 1) | (xCoord[:,i] > dimB[1])
    isYOutside = (yCoord[:,i] < 1) | (yCoord[:,i] > dimB[0])
    isPointInB = ~isXOutside & ~isYOutside
    
    # - Set feature vector for points along epipolar line within image
    searchVectB = np.vstack((xCoord[isPointInB,i], 
                             yCoord[isPointInB,i], 
                             np.ones((np.sum(isPointInB),))))
    
    # - Get image patch centered around point from A
    imagePatchA = imageA[np.ix_(idxRowA[:,i],idxColA[:,i])]
    
    # - Search
    #nxcB = fastncc(vectA[:, i], imageB)
    
    # - Find point on line with best score
    isMax = np.argmax(nxcB)
    vectB[:,i] = searchVectB[:,isMax]


# Remove NaNs
matchFound = np.isfinite(vectB[0,:])
vectA = vectA[:,matchFound]
vectB = vectB[:,matchFound]
lineB = lineB[:,matchFound]


# Compute disparities
dx = vectA[0,:] - vectB[0,:]
dy = vectA[1,:] - vectB[1,:]