% Expects ../code directory to be present with fundmatrix.m
addpath('../code')

img1 = imread('../data/DSCF4189.jpg');
img2 = imread('../data/DSCF4197.jpg');

x1 = 1000 * [
    0.3615, 1.3595;
    1.6715, 2.0535;
    2.6775, 1.0775;
    1.0535, 0.8815;
    1.0255, 0.6555;
    1.7075, 0.3255;
    2.0555, 1.3855;
    1.3255, 1.1475;
    0.7715, 1.0755;
    1.1735, 1.5715;
    2.0115, 1.0295;
    1.7135, 0.4955;    
];

x2 = 1000 * [
    2.0275, 2.0015;
    2.6975, 1.0775;
    1.5115, 0.6215;
    0.6735, 1.6235;
    0.6015, 1.4075;
    0.9355, 0.5375;
    1.9515, 0.9155;
    1.5295, 1.3115;
    1.2835, 1.8015;
    2.2615, 1.3295;
    1.3355, 0.9075;
    0.9635, 0.7035;
];

features = [1; 2; 3];

function draw_single_epipolar_line(img1, img2, x1, x2, F, idx1, idx2, draw_image)
    % Show Image 1 with epipolar line and point
    figure; imshow(img1); hold on;
    title(['Epipolar Line for Feature ' num2str(idx1)]);
    
    % Plot the relevant point in Image 1 (filled red circle)
    scatter(x1(1, idx1), x1(2, idx1), 100, 'ro', 'filled'); 
    
    if draw_image == 1
        % Draw the epipolar line for the selected point in Image 1
        draw_line(F' * x2(:, idx2), img1);
    end
    
    % Show Image 2 with just the point
    figure; imshow(img2); hold on;
    title(['Feature ' num2str(idx1)]);
    
    % Plot the relevant point in Image 2 (filled red circle)
    scatter(x2(1, idx2), x2(2, idx2), 100, 'ro', 'filled');
    
    if draw_image == 2
        % Draw the epipolar line for the selected point in Image 2
        draw_line(F * x1(:, idx1), img2);
    end
end

function draw_line(line, img)
    [rows, cols, ~] = size(img);
    x = [1, cols];  % Line spans the entire image width
    y = (-line(1) * x - line(3)) / line(2); % Solve for y = (-ax - c) / b
    plot(x, y, 'g', 'LineWidth', 1.5); % Plot line
end

x1_transposed = x1';
ones_row = ones(1, size(x1_transposed, 2));
x1_h = [x1_transposed; ones_row];

x2_transposed = x2';
ones_row2 = ones(1, size(x2_transposed, 2));
x2_h = [x2_transposed; ones_row2];

% Call the function
[F, e1, e2] = fundmatrix(x1_h, x2_h);

% Display the fundamental matrix
disp('Fundamental Matrix:');
disp(F);

% Compute the epipolar constraint for all points
errors = zeros(1, size(x1_h, 2));
for i = 1:size(x1_h, 2)
    errors(i) = x2_h(:, i)' * F * x1_h(:, i);
end

% Display results
disp('Epipolar constraint values (should be close to zero):');
disp(errors);

for i = 1:size(features, 1)
    draw_single_epipolar_line(img1, img2, x1_h, x2_h, F, features(i), features(i), 1);
end
