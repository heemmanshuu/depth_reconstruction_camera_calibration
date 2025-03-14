%PART 1 - SET 1 Features Code

% Define image paths
imagePaths = {'../data/DSCF4180.jpg', '../data/DSCF4181.jpg', '../data/DSCF4184.jpg', '../data/DSCF4187.jpg'};
maskPaths = {'../data/DSCF4180Mask.jpg', '../data/DSCF4181Mask.jpg', '../data/DSCF4184Mask.jpg', '../data/DSCF4187Mask.jpg'};

% %SET 2
% imagePaths = {'../data/DSCF4180.jpg', '../data/DSCF4184.jpg', '../data/DSCF4189.jpg', '../data/DSCF4197.jpg'};
% maskPaths = {'../data/DSCF4180Mask.jpg', '../data/DSCF4184Mask.jpg', '../data/DSCF4189Mask.jpg', '../data/DSCF4197Mask.jpg'};

% SIFT threshold (Euclidean distance) for filtering
threshold = 15000;

% Initialize a list to store matches
allMatches = {};

% Loop through all unique pairs of images
numImages = length(imagePaths);
for i = 1:numImages
    for j = i+1:numImages
        sortedMatches = extract_sift(imagePaths{i}, imagePaths{j}, maskPaths{i}, maskPaths{j}, threshold);
        
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

        % Select top 10 matches
        numBestMatches = min(10, size(sortedMatches, 2)); % Ensure we don't exceed available matches
        bestMatches = sortedMatches(:, 1:numBestMatches);
        
        % Display results
        fprintf('Matching %s and %s\n', imagePaths{i}, imagePaths{j});
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
