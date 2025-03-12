function P = cammatrix(world_points, image_points)
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
end