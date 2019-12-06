clc;
clear all;
close all;
K  = [725.0864 0.0 499.5;0.0 709.332 280.5;0.0 0.0 1.0];
Kinv = inv(K);
% X = [440 572 701 442 569 696 442 568 692];
% Y = [150 152 152 280 282 282 407 406 406];
X = [414 454];
Y = [408 302];
    % Read two consecutive images
    I1 = imread('IM.jpg'); 
    I1 = rgb2gray(I1);
    % Detect surf features
    points1 = detectSURFFeatures(I1);
    
%     figure(1);
%     imshow(I1); hold on;
%     plot(points1.selectStrongest(10));
    
    index=zeros(length(X),1);
    for i=1:1:length(X)
        loc = points1.Location;
        dist = sqrt((loc(:,1)-X(i)).^2 + (loc(:,2)-Y(i)).^2);
        index(i) = find(dist==min(dist));
    end
    interest_pts = points1(index);
        
    figure(2);
    imshow(I1); hold on;
    plot(interest_pts);
    
    I2 = imread('image1.jpg');
    I2 = rgb2gray(I2);
    points2 = detectSURFFeatures(I2);
    
    [feature1, vpts1] = extractFeatures(I1, interest_pts);
    [feature2, vpts2] = extractFeatures(I2, points2);
    
    indexPairs = matchFeatures(feature1, feature2) 
    
    matchedPoints1 = vpts1(indexPairs(:, 1)); 
    matchedPoints2 = vpts2(indexPairs(:, 2));
    
    figure(3);
    subplot(1,2,1)
    imshow(I1); hold on;
    plot(matchedPoints1);
    
    subplot(1,2,2)
    imshow(I2); hold on;
    plot(matchedPoints2);
    
    P2 = (matchedPoints2.Location)'; 
    p2 = Kinv*[P2;ones(1,size(P2,2))];
    % Extract features and corresponding Location of these points 
%     [feature1, vpts1] = extractFeatures(I1, points1);
%     Match the corresponding points based on the features in the two
%     images
%     matchedPoints1 = vpts1(indexPairs(:, 1));
%     matchedPoints2 = vpts2(indexPairs(:, 2));
%     Find the location of each matched point in the image in the image
%     coordinates
%     P1 = (matchedPoints1.Location)';
%     P2 = (matchedPoints2.Location)';
%     Convert from Pixel Coordinates into camera coordinates
%     p1 = Kinv*[P1;ones(1,size(P1,2))];
%     p2 = Kinv*[P2;ones(1,size(P2,2))];