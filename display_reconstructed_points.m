function display_reconstructed_points(img, P, world_points, image_points)
    % Reproject the world points to the image plane
    reprojected_points = (P * world_points')'; % Homogeneous projection
    
    % Convert to non-homogeneous coordinates (divide by the last column)
    reprojected_points = reprojected_points(:, 1:2) ./ reprojected_points(:, 3);
    
    % Compare with the original image points
    disp('Original Image Points:');
    disp(image_points);
    disp('Reprojected Image Points:');
    disp(reprojected_points);
    errors = sqrt(sum((image_points - reprojected_points).^2, 2));
    mean_error = mean(errors);
    disp(['Mean Reprojection Error: ', num2str(mean_error)]);
    
    figure;
    imshow(img);
    hold on;
    plot(image_points(:,1), image_points(:,2), 'ro', 'MarkerFaceColor', 'r');
    plot(reprojected_points(:,1), reprojected_points(:,2), 'bo', 'MarkerFaceColor', 'b');
    legend('Original Points', 'Reprojected Points');
    
    hold off;
    
end