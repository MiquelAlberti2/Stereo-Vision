import numpy as np
import imageio.v3 as iio # to read and write images
import matplotlib.pyplot as plt
from skimage import draw

# Other files in the project
from harris_corner_detector import detect_features
from NCC import find_correspondances
from fundamental_matrix_RANSAC import estimate_fundamental_matrix_RANSAC
from disparity_map import dense_disparity_map

def rgb_to_gray(rgb):

    # compute a weighted average of RGB colors to obtain a greyscale value
    # weights correspond to the luminosity of each color channel
    # we also normalize the image
    return (1/255)*np.dot(rgb[...,:3], [0.2989, 0.5870, 0.1140])

def plot_correspondaces(img1, img2, corresp):
    img3 = np.zeros((img1.shape[0]+img2.shape[0], max(img1.shape[1], img2.shape[1])))
    img3[:img1.shape[0], :img1.shape[1]] = img1
    img3[img1.shape[0]:, :img2.shape[1]] = img2

    fig, ax = plt.subplots(figsize=(10,10))
    ax.imshow(img3, cmap='gray')

    for match in corresp:
        pt1 = match[0]
        pt2 = match[1]
        r, c = draw.line(pt1[1], pt1[0], pt2[1] + img1.shape[0], pt2[0])
        ax.plot(c, r, linewidth=0.4, color='blue')

    plt.show()

##################
# Read the images
##################

image1 = iio.imread(uri='input1\image-3.jpeg')
image2 = iio.imread(uri='input1\image-4.jpeg')

# image1 = iio.imread(uri='input2\cast-left-1.jpg')
# image2 = iio.imread(uri='input2\cast-right-1.jpg')

# convert to grey images
grey_img1 = rgb_to_gray(image1)
grey_img2 = rgb_to_gray(image2)


##################
# Detect features of each image
##################

features1 = detect_features(grey_img1)

# visualize the detected corners
plt.imshow(image1, cmap='gray')
plt.plot(features1[:, 0], features1[:, 1], 'r.', markersize=5)
plt.show()

features2 = detect_features(grey_img2)

# visualize the detected corners
plt.imshow(image2, cmap='gray')
plt.plot(features2[:, 0], features2[:, 1], 'r.', markersize=5)
plt.show()


##################
# Find correspondaces between the two sets of cornes
##################

# get a list containing all the feature correspondances
corresp = find_correspondances(grey_img1, grey_img2, features1, features2)

print("\nNumber of initial correspondances: ", len(corresp))
# plot the correspondaces between the two images
plot_correspondaces(grey_img1, grey_img2, corresp)

##################
# Estimate the fundamental matrix using RANSAC to ignore outliers
##################

fund_matrix, inliers = estimate_fundamental_matrix_RANSAC(corresp)

print('Fundamental matrix:\n', fund_matrix)

print("\nNumber of inliers after RANSAC: ", len(inliers))
# plot the correspondaces between the two images
plot_correspondaces(grey_img1, grey_img2, inliers)

##################
# Compute a dense disparity map
##################

# define n that constraints the search space
n = 20

dx, dy, d = dense_disparity_map(fund_matrix, n, grey_img1, grey_img2)

# Display the resulting images
plt.imshow(dx)
plt.show()

plt.imshow(dy)
plt.show()

plt.imshow(d)
plt.show()


# write the reults to disk
iio.imwrite(uri="output/vertical_disparity.png", image=dx)
iio.imwrite(uri="output/horizontal_disparity.png", image=dy)
iio.imwrite(uri="output/disparity_vector.png", image=d)


