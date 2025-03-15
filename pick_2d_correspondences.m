clear; clc;

imgPath1 = '../data/DSCF4180.jpg';
imgPath2 = '../data/DSCF4181.jpg';

% Load images
img1 = imread(imgPath1);
img2 = imread(imgPath2);

% Display images side by side
figure;
subplot(1,2,1);
imshow(img1);
title('Image 1');
hold on;

subplot(1,2,2);
imshow(img2);
title('Image 2');
hold on;

% Number of points to select
numPoints = 10;

% Initialize storage for selected points
image_points1 = zeros(numPoints, 2);
image_points2 = zeros(numPoints, 2);

% Pick corresponding points
disp('Select corresponding points in both images. Click first on the left image, then on the right.');

for i = 1:numPoints
    % Select point in first image
    subplot(1,2,1);
    [x1, y1] = ginput(1);
    image_points1(i, :) = [x1, y1];
    plot(x1, y1, 'ro', 'MarkerSize', 10, 'LineWidth', 2); % Mark point
    text(x1 + 5, y1, num2str(i), 'Color', 'r', 'FontSize', 12, 'FontWeight', 'bold'); % Numbering

    % Select point in second image
    subplot(1,2,2);
    [x2, y2] = ginput(1);
    image_points2(i, :) = [x2, y2];
    plot(x2, y2, 'ro', 'MarkerSize', 10, 'LineWidth', 2); % Mark point
    text(x2 + 5, y2, num2str(i), 'Color', 'r', 'FontSize', 12, 'FontWeight', 'bold'); % Numbering
end

% Print the selected points
disp('Selected points in Image 1:');
% disp(image_points1);

for i = 1:numPoints
    fprintf('%.4f, %.4f;\n', image_points1(i, 1)/1000, image_points1(i, 2)/1000);
end

disp('\nSelected points in Image 2:');
% disp(image_points2);

for i = 1:numPoints
    fprintf('%.4f, %.4f;\n', image_points2(i, 1)/1000, image_points2(i, 2)/1000);
end
