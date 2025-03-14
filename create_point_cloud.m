% TRY TO GET ONLY 150 POINTS

clc; clear; close all;
run('point_data.m')

function F = fundamental_matrix(x1, x2)
    x1_transposed = x1';
    ones_row = ones(1, size(x1_transposed, 2));
    x1_h = [x1_transposed; ones_row];
    
    x2_transposed = x2';
    ones_row2 = ones(1, size(x2_transposed, 2));
    x2_h = [x2_transposed; ones_row2];
    
    % Call the function
    [F, ~, ~] = fundmatrix(x1_h, x2_h);

end

% Define image paths
imagePaths = {'../data/DSCF4180.jpg', '../data/DSCF4181.jpg', '../data/DSCF4184.jpg', '../data/DSCF4187.jpg'};
maskPaths = {'../data/DSCF4180Mask.jpg', '../data/DSCF4181Mask.jpg', '../data/DSCF4184Mask.jpg', '../data/DSCF4187Mask.jpg'};
world_points_list = {world_points_80, world_points_81, world_points_84, world_points_87};
image_points_list = {image_points_80, image_points_81, image_points_84, image_points_87};


% %SET 2
% imagePaths = {'../data/DSCF4180.jpg', '../data/DSCF4181.jpg', '../data/DSCF4189.jpg', '../data/DSCF4197.jpg'};
% maskPaths = {'../data/DSCF4180Mask.jpg', '../data/DSCF4181Mask.jpg', '../data/DSCF4189Mask.jpg', '../data/DSCF4197Mask.jpg'};
% world_points_list = {world_points_80, world_points_81, world_points_89, world_points_97};
% image_points_list = {image_points_80, image_points_81, image_points_89, image_points_97};

% Load images
numImages = length(imagePaths);
images = cell(1, numImages);
for i = 1:numImages
    images{i} = imread(imagePaths{i});
end

% Compute camera matrices
P = cell(1, numImages);
for i = 1:numImages
    P{i} = cammatrix(world_points_list{i}, image_points_list{i});
end

% Extract SIFT features and match points
matchedPoints = cell(numImages, numImages);
for i = 1:numImages
    for j = i+1:numImages
        [matchedPoints1, matchedPoints2] = extract_sift(imagePaths{i}, imagePaths{j}, maskPaths{i}, maskPaths{j});
        matchedPoints{i, j} = {matchedPoints1, matchedPoints2};
    end
end

% Filter matches using epipolar constraints
filteredMatches = cell(numImages, numImages);
for i = 1:numImages
    for j = i+1:numImages
        if isempty(matchedPoints{i, j})
            continue;
        end
        
        % Compute fundamental matrix
        [matchedPoints1, matchedPoints2] = deal(matchedPoints{i, j}{:});
        F = fundamental_matrix(matchedPoints1, matchedPoints2);
        
        % Check epipolar constraints
        inliers1 = [];
        inliers2 = [];
        
        for k = 1:size(matchedPoints1, 2)
            x1 = [matchedPoints1(:, k); 1];
            x2 = [matchedPoints2(:, k); 1];
            
            % Epipolar constraint
            error = abs(x2' * F * x1);
            
            % Threshold for considering a match as valid
            if error < 1e-3
                inliers1 = [inliers1, matchedPoints1(:, k)];
                inliers2 = [inliers2, matchedPoints2(:, k)];
            end
        end
        
        filteredMatches{i, j} = {inliers1, inliers2};
    end
end

% 3D Reconstruction using multi-view triangulation
points3D = [];
for i = 1:numImages
    for j = i+1:numImages
        if isempty(filteredMatches{i, j})
            continue;
        end
        
        [matchedPoints1, matchedPoints2] = deal(filteredMatches{i, j}{:});
        
        for k = 1:size(matchedPoints1, 2)
            x1 = [matchedPoints1(:, k); 1];
            x2 = [matchedPoints2(:, k); 1];
            
            % Triangulate 3D point
            A = [x1(1) * P{i}(3,:) - P{i}(1,:);
                 x1(2) * P{i}(3,:) - P{i}(2,:);
                 x2(1) * P{j}(3,:) - P{j}(1,:);
                 x2(2) * P{j}(3,:) - P{j}(2,:)];
            
            [~, ~, V] = svd(A);
            X = V(:, end);
            X = X(1:3) / X(4); % Convert from homogeneous to 3D
            points3D = [points3D, X];
        end
    end
end

% Plot 3D points
figure;
scatter3(points3D(1,:), points3D(2,:), points3D(3,:), 10, 'filled');
grid on;
xlabel('X'); ylabel('Y'); zlabel('Z');
title('3D Point Cloud Reconstruction');