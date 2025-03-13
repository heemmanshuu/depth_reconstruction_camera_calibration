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
        % Select top 10 matches
        numBestMatches = min(10, size(sortedMatches, 2)); % Ensure we don't exceed available matches
        bestMatches = sortedMatches(:, 1:numBestMatches);
        
        % Store the results - are these being used anywhere?
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