# Camera Calibration and Depth Reconstruction

This project uses traditional computer vision methods to extract camera position, orientation, and object depth from a set of images.

## Expected Directory Structure

### Main Directory:
- **data**: Contains the images to be used for calibration and reconstruction.
- **This repository**: The implementation of the camera calibration and reconstruction methods.
- **code**: Folder containing supporting code for computing fundamental matrix for a pair of images

## Files:

### SIFT matching
- **extract_sift.m**: Function to extract SIFT matches between a pair of images. Used in plot_SIFT_matches.m
- **plot_SIFT_matches.m**: Plots the top 10 SIFT matches between a pair of images

### Camera calibration matrix
- **cammatrix.m**: Function to compute the camera calibration matrix (P), which relates world points to image points.
- **mark_2dpoints.m**: Allows to mark 2D points for correspondence. It also displays the reconstructed points to verify the quality of the correspondences.
- **display_reconstructed_points.m**: Given a camera calibration matrix (P), world points, and image points, this function reprojects the 3D world points into 2D and displays both the original and reprojected points for comparison. Used in mark_2dpoints.m
- **point_data.m**: Contains a list of 3D points and their corresponding 2D image points, with some supporting data.

### Depth reconstruction
- **create_point_cloud.m**: Function to compute point cloud of an object given images and corresponding calibration matrices.
- **epipolar_line.m**: Given two images and corresponding points between them, plots features in one image and the corresponding epipolar line in all other images.
- **plot_per_set.m**: Generates 3D plots of the camera position, orientation, and 3D point cloud for a set of images.
- **plot_both_sets.m** Generates 3D plots of the camera position, orientation, and 3D point cloud for two sets of images in red and blue.
