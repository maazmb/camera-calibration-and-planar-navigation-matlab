clc;
clear all;
close all;
% imageDir = fullfile(toolboxdir('vision'), 'visiondata','upToScaleReconstructionImages');
% images = imageSet(imageDir);
I1 = imread('Image1.tif');
I2 = imread('Image2.tif');


load ('C.mat');
I1 = undistortImage(I1, C);
I2 = undistortImage(I2, C);

figure
imshowpair(I1, I2, 'montage');
title('Original Images');

% Detect feature points
imagePoints1 = detectMinEigenFeatures(I1, 'MinQuality', 0.1);

% Visualize detected points
figure
imshow(I1, 'InitialMagnification', 50);
title('150 Strongest Corners from the First Image');
hold on
plot(selectStrongest(imagePoints1, 150));

% Create the point tracker
tracker = vision.PointTracker('MaxBidirectionalError', 1, 'NumPyramidLevels', 5);

% Initialize the point tracker
imagePoints1 = imagePoints1.Location;
initialize(tracker, imagePoints1, I1);

% Track the points
[imagePoints2, validIdx] = step(tracker, I2);
matchedPoints1 = imagePoints1(validIdx, :);
matchedPoints2 = imagePoints2(validIdx, :);

% Visualize correspondences
figure
showMatchedFeatures(I1, I2, matchedPoints1, matchedPoints2);
title('Tracked Features');


% Estimate the fundamental matrix
[fMatrix, epipolarInliers] = estimateFundamentalMatrix(...
  matchedPoints1, matchedPoints2, 'Method', 'MSAC', 'NumTrials', 10000);

% Find epipolar inliers
inlierPoints1 = matchedPoints1(epipolarInliers, :);
inlierPoints2 = matchedPoints2(epipolarInliers, :);

% Display inlier matches
figure
showMatchedFeatures(I1, I2, inlierPoints1, inlierPoints2);
title('Epipolar Inliers');

[R, t] = cameraPose(fMatrix, C, inlierPoints1, inlierPoints2);