# Camera Calibration and Depth Reconstruction

This project uses traditional computer vision methods to extract camera position, orientation, and object depth from a set of images.

## Expected Directory Structure

### Main Directory:
- **data**: Contains the images to be used for calibration and reconstruction.
- **This repository**: The implementation of the camera calibration and reconstruction methods.

### Files:
- **cammatrix.m**: Function to compute the camera calibration matrix (P), which relates world points to image points.
- **mark_2dpoints.m**: Allows to mark 2D points for correspondence. It also displays the reconstructed points to verify the quality of the correspondences.
- **display_reconstructed_points.m**: Given a camera calibration matrix (P), world points, and image points, this function reprojects the 3D world points into 2D and displays both the original and reprojected points for comparison.
- **plots_per_set.m**: Generates 3D plots of the camera's position and orientation for each subset of images.
- **point_data.m**: Contains a list of 3D points and their corresponding 2D image points.