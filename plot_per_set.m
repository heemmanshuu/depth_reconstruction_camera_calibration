clear; clc;

run('point_data.m')
% Define image paths

% Set 1
imgPaths = {'../data/DSCF4180.jpg', '../data/DSCF4181.jpg', '../data/DSCF4184.jpg', '../data/DSCF4187.jpg'};
world_points_list = {world_points_80, world_points_81, world_points_89, world_points_97};
image_points_list = {image_points_80, image_points_81, image_points_89, image_points_97};

% % Set 2
% imgPaths = {'../data/DSCF4180.jpg', '../data/DSCF4181.jpg', '../data/DSCF4189.jpg', '../data/DSCF4197.jpg'};
% world_points_list = {world_points_80, world_points_81, world_points_84, world_points_87};
% image_points_list = {image_points_80, image_points_81, image_points_84, image_points_87};

% figure for plotting camera position and orientation
figure;
hold on;
xlabel('X');
ylabel('Y');
zlabel('Z');
% Set plot limits for better visualization
axis equal;
xlim([-200, 400]);
ylim([-200, 400]);
zlim([0, 500]);
title('Camera Position and Orientation');
grid on;

% go through each image and add plots
for i = 1:length(imgPaths)
    disp(i);
    img = imread(imgPaths{i}); % Load image
    world_points = world_points_list{i};
    image_points = image_points_list{i};
    P = cammatrix(world_points, image_points);
    
    % Extract rotation matrix and translation vector from the camera matrix P
    R = P(:, 1:3);  % First three columns are the rotation matrix
    t = P(:, 4);    % The last column is the translation vector
    
    % Calculate the camera position in the world coordinate system
    % Camera position is -R_inv * t, since P = [R | t] represents the projection
    camera_position = -inv(R) * t;
    
    % make R orthogonal on purpose
    [U, ~, V] = svd(R); 
    R_orthogonal = U * V';
    R = R_orthogonal;
    
    figure(1);
    % Plot the position of the camera as a point (red dot)
    plot3(camera_position(1), camera_position(2), camera_position(3), 'ro', 'MarkerFaceColor','r');
    
    % Plot the camera's local axes (coordinate system)
    % Define a unit length for the axes
    axis_length = 50;  % You can adjust this length to make the axes visible
    
    % Plot each axis (Red: X, Green: Y, Blue: Z)
    quiver3(camera_position(1), camera_position(2), camera_position(3), axis_length * R(1, 1), axis_length * R(2, 1), axis_length * R(3, 1), 'r', 'LineWidth', 2); % X-axis
    quiver3(camera_position(1), camera_position(2), camera_position(3), axis_length * R(1, 2), axis_length * R(2, 2), axis_length * R(3, 2), 'g', 'LineWidth', 2); % Y-axis
    quiver3(camera_position(1), camera_position(2), camera_position(3), axis_length * R(1, 3), axis_length * R(2, 3), axis_length * R(3, 3), 'b', 'LineWidth', 2); % Z-axis
end
    
%view(3);
hold off;

