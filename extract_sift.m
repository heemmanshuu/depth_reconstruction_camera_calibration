function [matchedPoints1_hom, matchedPoints2_hom] = extract_sift(imgPath1, imgPath2, imgMask1, imgMask2, threshold)
    % Load and preprocess images
    I1 = im2single(rgb2gray(imread(imgPath1)));
    I2 = im2single(rgb2gray(imread(imgPath2)));

    % Compute SIFT features
    [f1, d1] = vl_sift(I1);
    [f2, d2] = vl_sift(I2);

    % Load and apply masks
    mask1 = im2bw(imread(imgMask1));
    mask2 = im2bw(imread(imgMask2));

    valid1 = mask1(sub2ind(size(mask1), round(f1(2, :)), round(f1(1, :))));
    valid2 = mask2(sub2ind(size(mask2), round(f2(2, :)), round(f2(1, :))));

    f1 = f1(:, valid1);
    f2 = f2(:, valid2);
    d1 = d1(:, valid1);
    d2 = d2(:, valid2);

    % Match features
    [matches, scores] = vl_ubcmatch(d1, d2);

    % Define threshold, use this instead?
    %threshold = 1.5 * min(scores);

    % Filter matches based on the threshold
    valid_matches = scores < threshold;
    filtered_matches = matches(:, valid_matches);
    filtered_scores = scores(valid_matches);

    % Sort filtered matches by scores (ascending order)
    [sortedScores, sortIdx] = sort(filtered_scores, 'ascend');
    sortedMatches = filtered_matches(:, sortIdx);

    % Extract the matched feature indices
    matches1 = sortedMatches(1, :);  % Indices in image 1
    matches2 = sortedMatches(2, :);  % Indices in image 2
    
    % Extract the coordinates of the matched points in both images
    matchedPoints1_x = f1(1, matches1);  % x-coordinates in image 1
    matchedPoints1_y = f1(2, matches1);  % y-coordinates in image 1
    
    matchedPoints2_x = f2(1, matches2);  % x-coordinates in image 2
    matchedPoints2_y = f2(2, matches2);  % y-coordinates in image 2
    
    % Optionally, create the matched points as a 2xN matrix
    matchedPoints1 = [matchedPoints1_x; matchedPoints1_y];  % 2xN matrix for image 1
    matchedPoints2 = [matchedPoints2_x; matchedPoints2_y];  % 2xN matrix for image 2
    
    matchedPoints1_hom = [matchedPoints1; ones(1, size(matchedPoints1, 2))];  % 3×N
    matchedPoints2_hom = [matchedPoints2; ones(1, size(matchedPoints2, 2))];  % 3×N

end
