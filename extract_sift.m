function sortedMatches = extract_sift(imgPath1, imgPath2, imgMask1, imgMask2, threshold)
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
end