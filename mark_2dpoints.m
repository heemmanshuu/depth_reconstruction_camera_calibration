% ADD POINTS COMPUTED HERE TO point_data.m

clear; clc;
run('point_data.m')

% number of points you want to mark
numPoints = 6;

imgPath = '../data/DSCF4180.jpg';
img = imread(imgPath);

% Change cursor to crosshair for better visibility
set(gcf, 'Pointer', 'crosshair');

% Initialize the variable for storing points
image_points = zeros(numPoints, 2);

% UNCOMMENT THIS TO MARK POINTS
% figure;
% imshow(img);
% hold on;
% for i = 1:numPoints
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

%hold off;

% COMMENTED OUT PART ENDS

disp('Selected 2D Points:');
disp(image_points);

% Reset cursor to default
set(gcf, 'Pointer', 'arrow');

% change labels accordingly
P = cammatrix(world_points_80, image_points_80);
display_reconstructed_points(img, P, world_points_80, image_points_80);