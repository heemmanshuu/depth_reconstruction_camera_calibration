%PART 1 - SET 1 Features Code

% Define image paths
imagePaths = {'data/DSCF4180.jpg', 'data/DSCF4181.jpg', 'data/DSCF4184.jpg', 'data/DSCF4187.jpg'};
maskPaths = {'data/DSCF4180Mask.jpg', 'data/DSCF4181Mask.jpg', 'data/DSCF4184Mask.jpg', 'data/DSCF4187Mask.jpg'};

%SET 2
imagePaths = {'data/DSCF4180.jpg', 'data/DSCF4184.jpg', 'data/DSCF4189.jpg', 'data/DSCF4197.jpg'};
maskPaths = {'data/DSCF4180Mask.jpg', 'data/DSCF4184Mask.jpg', 'data/DSCF4189Mask.jpg', 'data/DSCF4197Mask.jpg'};

% SIFT threshold for filtering
threshold = 15000;

% Initialize a list to store matches
allMatches = {};

% Loop through all unique pairs of images
numImages = length(imagePaths);
for i = 1:numImages
    for j = i+1:numImages
        % Load and preprocess images
        I1 = im2single(rgb2gray(imread(imagePaths{i})));
        I2 = im2single(rgb2gray(imread(imagePaths{j})));
        
        % Compute SIFT features
        [f1, d1] = vl_sift(I1);
        [f2, d2] = vl_sift(I2);
        
        % Load and apply masks
        mask1 = im2bw(imread(maskPaths{i}));
        mask2 = im2bw(imread(maskPaths{j}));
        
        valid1 = mask1(sub2ind(size(mask1), round(f1(2, :)), round(f1(1, :))));
        valid2 = mask2(sub2ind(size(mask2), round(f2(2, :)), round(f2(1, :))));
        
        f1 = f1(:, valid1);
        f2 = f2(:, valid2);
        d1 = d1(:, valid1);
        d2 = d2(:, valid2);
        
        % Match features
        [matches, scores] = vl_ubcmatch(d1, d2);
        
        % Filter matches based on the threshold
        valid_matches = scores < threshold;
        filtered_matches = matches(:, valid_matches);
        filtered_scores = scores(valid_matches);
        
        % Sort filtered matches by scores (ascending order)
        [sortedScores, sortIdx] = sort(filtered_scores, 'ascend');
        sortedMatches = filtered_matches(:, sortIdx);

        % Select top 10 matches
        numBestMatches = min(10, size(sortedMatches, 2)); % Ensure we don't exceed available matches
        bestMatches = sortedMatches(:, 1:numBestMatches);
        
        % Store the results
        matchData.image1 = imagePaths{i};
        matchData.image2 = imagePaths{j};
        matchData.matches = bestMatches;
        allMatches{end+1} = matchData;
        
        % Display results
        fprintf('Matching %s and %s\n', imagePaths{i}, imagePaths{j});
        fprintf('Total matches before filtering: %d\n', size(matches, 2));
        fprintf('Valid matches after filtering: %d\n', size(filtered_matches, 2));
        fprintf('Displaying top %d matches.\n\n', numBestMatches);
        
        % Visualization of top 10 matches
        figure; ax = axes;
        showMatchedFeatures(I1, I2, ...
            f1(1:2, bestMatches(1, :))', ...
            f2(1:2, bestMatches(2, :))', ...
            'montage', 'Parent', ax);
        title(sprintf('Top %d SIFT Matches: %s & %s', numBestMatches, imagePaths{i}, imagePaths{j}));
    end
end