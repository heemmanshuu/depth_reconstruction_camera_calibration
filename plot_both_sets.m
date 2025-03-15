clear; clc; 
run('point_data.m')

imagePathsList = {imagePathsSet1, imagePathsSet2};
maskPathsList = {maskPathsSet1, maskPathsSet2};
world_points_list_list = {world_points_list_Set1, world_points_list_Set2};
image_points_list_list = {image_points_list_Set1, image_points_list_Set2};
fill_color = 'r'; % color of set 1
setPairs = set1Pairs;

% Initialise plot
% figure for plotting
figure;
hold on;
xlabel('X');
ylabel('Y');
zlabel('Z');

% Set plot limits for better visualization
axis equal;
% xlim([-200, 400]);
% ylim([-200, 400]);
% zlim([0, 500]);
title('Camera Positions and 3D Point Cloud for both sets');
grid on;

for setNo = 1:2
    % Set the fill color for the second set
    if setNo == 2
        fill_color = 'b'; % Blue for set 2
        setPairs = set2Pairs;
    end

    % Load paths for the current set
    imagePaths = imagePathsList{setNo};
    maskPaths = maskPathsList{setNo};
    world_points_list = world_points_list_list{setNo};
    image_points_list = image_points_list_list{setNo};

    % List to store camera calibration matrices
    numImages = length(imagePaths);
    P = cell(1, numImages);

    % Iterate through each image and process camera information
    for i = 1:numImages
        disp(i);
        img = imread(imagePaths{i}); % Load image
        world_points = world_points_list{i};
        image_points = image_points_list{i};
        
        % Compute the camera calibration matrix
        calibration_matrix = cammatrix(world_points, image_points);
        P{i} = calibration_matrix;
        
        % Extract rotation matrix and translation vector
        R = calibration_matrix(:, 1:3);  % First three columns: Rotation matrix
        t = calibration_matrix(:, 4);    % Last column: Translation vector
        
        % Compute camera position in world coordinates
        camera_position = -inv(R) * t;
        
        % Ensure R is orthogonal using Singular Value Decomposition (SVD)
        [U, ~, V] = svd(R); 
        R_orthogonal = U * V';
        % R = R_orthogonal; % Uncomment if you want to enforce orthogonality
        
        % Plot the camera position
        figure(1);
        plot3(camera_position(1), camera_position(2), camera_position(3), 'ro', 'MarkerFaceColor', fill_color);
        
        % Define a unit length for the coordinate axes visualization
        axis_length = 10000;  % Adjust as needed for visibility
        
        % Plot the camera's coordinate axes
        quiver3(camera_position(1), camera_position(2), camera_position(3), ...
                axis_length * R(1, 1), axis_length * R(2, 1), axis_length * R(3, 1), ...
                fill_color, 'LineWidth', 2); % X-axis
        
        quiver3(camera_position(1), camera_position(2), camera_position(3), ...
                axis_length * R(1, 2), axis_length * R(2, 2), axis_length * R(3, 2), ...
                fill_color, 'LineWidth', 2); % Y-axis
        
        quiver3(camera_position(1), camera_position(2), camera_position(3), ...
                axis_length * R(1, 3), axis_length * R(2, 3), axis_length * R(3, 3), ...
                fill_color, 'LineWidth', 2); % Z-axis
    end

    % Generate and plot the 3D point cloud
    points3D = create_point_cloud(imagePaths, maskPaths, P, setPairs);
    
    % Scatter plot of 3D points with adjustable size
    scatter3(points3D(1,:), points3D(2,:), points3D(3,:), 50, fill_color, 'filled'); % Adjust size as needed

end

% NOTE: Our sets have two images in common, so the final plot will have two
% red cameras overwritten by 2 blue cameras, giving 2 red cameras and 4
% blue cameras in total.