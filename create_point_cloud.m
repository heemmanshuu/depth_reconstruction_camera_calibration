clc; clear; close all;

% **Step 1: Load Matched SIFT Feature Points**
% Assume `matchedPoints1` and `matchedPoints2` contain feature correspondences
% Assume `K` is the intrinsic camera calibration matrix from Part 2
load('matched_features.mat'); % Contains matchedPoints1, matchedPoints2
load('camera_calibration.mat'); % Contains K (intrinsic matrix)

% **Step 2: Filter Matches Using RANSAC**
[F, inliers] = estimateFundamentalMatrix(matchedPoints1, matchedPoints2, 'Method', 'RANSAC');
matchedPoints1 = matchedPoints1(inliers, :);
matchedPoints2 = matchedPoints2(inliers, :);

% **Step 3: Select 150 Well-Distributed Feature Points Using K-means**
numPoints = 150;
[idx, C] = kmeans(matchedPoints1.Location, numPoints);
selectedPoints1 = C; % Cluster centers as selected points in Image 1
selectedPoints2 = matchedPoints2(idx, :); % Corresponding points in Image 2

% **Step 4: Compute Camera Projection Matrices**
% Assume `P1` and `P2` are camera projection matrices from Part 2
P1 = K * [eye(3), zeros(3,1)]; % First camera at origin
R = eye(3); % Replace with real rotation from Part 2
t = [1; 0; 0]; % Replace with actual translation from Part 2
P2 = K * [R, t];

% **Step 5: Perform Triangulation to Recover 3D Points**
numSelected = size(selectedPoints1, 1);
points3D = zeros(numSelected, 3);

for i = 1:numSelected
    A = [
        selectedPoints1(i,1) * P1(3,:) - P1(1,:);
        selectedPoints1(i,2) * P1(3,:) - P1(2,:);
        selectedPoints2(i,1) * P2(3,:) - P2(1,:);
        selectedPoints2(i,2) * P2(3,:) - P2(2,:);
    ];
    
    % Solve using SVD
    [~,~,V] = svd(A);
    X = V(:,end);
    points3D(i,:) = X(1:3)' / X(4);
end

% **Step 6: Visualize 3D Point Cloud**
figure;
scatter3(points3D(:,1), points3D(:,2), points3D(:,3), 30, 'filled');
xlabel('X'); ylabel('Y'); zlabel('Z');
title('3D Reconstruction of Object');
grid on; axis equal;