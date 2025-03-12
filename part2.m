clear; clc;

% Define image paths
set1Paths = {'data/DSCF4180.jpg', 'data/DSCF4181.jpg', 'data/DSCF4184.jpg', 'data/DSCF4187.jpg'};
set2Paths = {'data/DSCF4189.jpg', 'data/DSCF4197.jpg'};

img = imread('data/DSCF4184.jpg'); % Load image
imshow(img);
hold on;

% Change cursor to crosshair for better visibility
set(gcf, 'Pointer', 'crosshair');

% Initialize the variable for storing points
image_points = zeros(9, 2);

% for i = 1:9
%     [x, y] = ginput(1); % Select 1 point per iteration
%     image_points(i, :) = [x, y]; % Store the selected point
% 
%     % Plot red circle on the selected point
%     plot(x, y, 'ro', 'MarkerSize', 10, 'LineWidth', 2);
% 
%     % Display the point number in blue and move it a bit to the right
%     text(x + 10, y, num2str(i), 'Color', 'cyan', 'FontSize', 12, 'FontWeight', 'bold');
% 
% end

disp('Selected 2D Points:');
disp(image_points);

% Reset cursor to default
set(gcf, 'Pointer', 'arrow');

%4184

world_points = [
    64,64,0,1;
    0,64,19,1;
    64,64,29,1;
    32,80,67,1;
    40,120,0,1;
    180,140,0,1;
    120,180,0,1;
    60,160,0,1;
    140,100,0,1;

];

image_points = 1000*[
    1.9795,    0.9995;
    2.6555,    0.9355;
    1.9835,    0.7475;
    2.2915,    0.4515;
    1.9915,    1.3835;
    0.5555,    1.1515;
    0.7715,    1.5555;
    1.5555,    1.6195;
    1.1155,    1.0395;
];


% Number of points
num_points = size(world_points, 1);

% Preallocate matrix A for efficiency
A = zeros(2 * num_points, 12); % 2 rows per point, 12 columns (for a 3x4 matrix)

% Construct the matrix A
for i = 1:num_points
    X = world_points(i, 1);
    Y = world_points(i, 2);
    Z = world_points(i, 3);
    x = image_points(i, 1);
    y = image_points(i, 2);
    
    % Populate A with the coefficients for the equations
    A(2*i-1, :) = [X, Y, Z, 1,  0,  0,  0, 0, -x*X, -x*Y, -x*Z, -x];
    A(2*i, :) = [0,  0,  0, 0, X,  Y,  Z, 1, -y*X, -y*Y, -y*Z, -y];
end

disp(['Rank of A:', num2str(rank(A))]);

% Solve for P using SVD
[~, ~, V] = svd(A);
P = reshape(V(:, end), 4, 3)'; % Reshape last column of V into 3x4 matrix

% Display the camera projection matrix
disp('Camera Projection Matrix P:');
disp(P);

% Reproject the world points to the image plane
reprojected_points = (P * world_points')'; % Homogeneous projection

% Convert to non-homogeneous coordinates (divide by the last column)
reprojected_points = reprojected_points(:, 1:2) ./ reprojected_points(:, 3);

% Compare with the original image points
disp('Original Image Points:');
disp(image_points);
disp('Reprojected Image Points:');
disp(reprojected_points);

% Assuming you have the image stored in 'image_data'
figure;
imshow(img);
hold on;
plot(image_points(:,1), image_points(:,2), 'ro', 'MarkerFaceColor', 'r');
plot(reprojected_points(:,1), reprojected_points(:,2), 'bo', 'MarkerFaceColor', 'b');
legend('Original Points', 'Reprojected Points');
hold off;

errors = sqrt(sum((image_points - reprojected_points).^2, 2));
mean_error = mean(errors);
disp(['Mean Reprojection Error: ', num2str(mean_error)]);

% Assuming P is the 3x4 camera matrix obtained from the previous step
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

% Plot the camera position and the orientation axes
figure;
hold on;

% Plot the position of the camera as a point (red dot)
plot3(camera_position(1), camera_position(2), camera_position(3), 'ro', 'MarkerFaceColor','r');

% Plot the camera's local axes (coordinate system)
% Define a unit length for the axes
axis_length = 50;  % You can adjust this length to make the axes visible

% Plot each axis (Red: X, Green: Y, Blue: Z)
quiver3(camera_position(1), camera_position(2), camera_position(3), axis_length * R(1, 1), axis_length * R(2, 1), axis_length * R(3, 1), 'r', 'LineWidth', 2); % X-axis
quiver3(camera_position(1), camera_position(2), camera_position(3), axis_length * R(1, 2), axis_length * R(2, 2), axis_length * R(3, 2), 'g', 'LineWidth', 2); % Y-axis
quiver3(camera_position(1), camera_position(2), camera_position(3), axis_length * R(1, 3), axis_length * R(2, 3), axis_length * R(3, 3), 'b', 'LineWidth', 2); % Z-axis

% Set labels for the axes
xlabel('X');
ylabel('Y');
zlabel('Z');

% Set plot limits for better visualization
axis equal;  % This makes the axes scaled equally
xlim([-200, 400]); % Adjust the limits according to your scene
ylim([-200, 400]);
zlim([0, 500]);

% Add title and grid for better visualization
title('Camera Position and Orientation');
grid on;

% Enable 3D view
view(3);

hold off;

% %4181
% 
% world_points = [
%     0,0,0,1;
%     0,64,0,1;
%     0,0,29,1;
%     0,80,29,1;
%     140,40,0,1;
%     140,60,0,1;
%     32,48,67,1;
%     180,100,0,1;
%     180,140,0,1;
% 
% ];
% 
% image_points = 1000*[
%     1.9595,    2.0395;
%     1.2955,    1.8275;
%     1.9715,    1.7875;
%     1.1035,    1.5395;
%     1.9835,    1.0795;
%     1.8275,    1.0475;
%     1.5475,    1.0795;
%     1.6475,    0.8475;
%     1.3875,    0.8035;
% ];

% %4180
% 
% world_points = [
%     0,0,0,1;
%     64,0,0,1;
%     0,0,29,1;
%     48,16,29,1;
%     140,40,0,1;
%     140,60,0,1;
%     32,48,67,1;
%     180,100,0,1;
%     180,140,0,1;
% 
% ];
% 
% image_points = 1000*[
%     0.7435,    2.1075;
%     1.4915,    1.8755;
%     0.6995,   1.8395;
%     1.2235,    1.3595;
%     2.0395,    1.3715;
%     1.9395,    1.2675;
%     0.9035,    0.9835;
%     2.0555,    1.0075;
%     1.8955,    0.8635;
% ];

% %4184
% 
% world_points = [
%     64,64,0,1;
%     0,64,19,1;
%     64,64,29,1;
%     32,80,67,1;
%     40,120,0,1;
%     180,140,0,1;
%     120,180,0,1;
%     60,160,0,1;
%     140,100,0,1;
% 
% ];
% 
% image_points = 1000*[
%     1.9795,    0.9995;
%     2.6555,    0.9355;
%     1.9835,    0.7475;
%     2.2915,    0.4515;
%     1.9915,    1.3835;
%     0.5555,    1.1515;
%     0.7715,    1.5555;
%     1.5555,    1.6195;
%     1.1155,    1.0395;
% ];