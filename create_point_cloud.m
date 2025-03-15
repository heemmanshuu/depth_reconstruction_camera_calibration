% try to get around 150 points
function points3D = create_point_cloud(imagePaths, maskPaths, P, set2Dcorrespondences) % P - list of camera calibration matrices
    % Load images
    numImages = length(imagePaths);
    images = cell(1, numImages);
    
    for i = 1:numImages
        images{i} = imread(imagePaths{i});
    end
    
    % % COMMENTING OUT SIFT PART
    % % Extract SIFT features and match points
    % matchedPoints = cell(numImages, numImages);
    % 
    % for i = 1:numImages
    %     for j = i+1:numImages
    %         [matchedPoints1_hom, matchedPoints2_hom] = extract_sift(imagePaths{i}, imagePaths{j}, maskPaths{i}, maskPaths{j}, 25000);
    %         matchedPoints{i, j} = {matchedPoints1_hom, matchedPoints2_hom};
    %     end
    % end

    % Filter matches using epipolar constraints
    filteredMatches = cell(numImages, numImages);
    
    pairIndex = 0;
    for i = 1:numImages
        for j = i+1:numImages
            pairIndex = pairIndex + 1;
            % if isempty(matchedPoints{i, j})
            %     continue;
            % end
            if isempty(set2Dcorrespondences{pairIndex})
                continue;
            end

            % Compute fundamental matrix
            %[matchedPoints1, matchedPoints2] = deal(matchedPoints{i, j}{:});
            [matchedPoints1, matchedPoints2] = deal(set2Dcorrespondences{pairIndex}{:});

            %homogenize
            matchedPoints1 = [matchedPoints1'; ones(1, size(matchedPoints1', 2))];  % 3×N
            matchedPoints2 = [matchedPoints2'; ones(1, size(matchedPoints2', 2))];  % 3×N

            if length(matchedPoints2) < 8 || length(matchedPoints1) < 8 
                continue;
            end

            [F, ~, ~] = fundmatrix(matchedPoints1, matchedPoints2);

            % Check epipolar constraints
            inliers1 = [];
            inliers2 = [];

            for k = 1:size(matchedPoints1, 2)
                % Epipolar constraint
                error = abs(matchedPoints2(:, k)' * F * matchedPoints1(:, k));

                % Threshold for considering a match as valid
                if error < 1
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
end
