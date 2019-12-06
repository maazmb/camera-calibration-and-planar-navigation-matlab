clc;
clear all;
close all;
numImages = 3;
% Initialization   
load 'C.mat'
v = VideoReader('Constant.mp4');
N=v.NumberOfFrames;
i=1;
file=cell(N,1);
frame1 = read(v,1);
imwrite(frame1,'IM.tif');
% Now find [R,t] matrix for initial Image
squareSize = 40; % in millimeters
[imagePoints, boardSize] = detectCheckerboardPoints('IM.tif');% Here We can put our SURF Objects
imshow(frame1);hold on;plot(imagePoints(:,1),imagePoints(:,2),'ro');
hold off;
worldPoints = generateCheckerboardPoints(boardSize, squareSize);
[R, t] = extrinsics(imagePoints(:,:,1), worldPoints, C);

% Read all the images from memory
numOfI = N;
for i=1:1:numOfI
    frame = read(v,i);
    frame = rgb2gray(frame);
    file{i} = frame;
end

% Now Navigation Starts
    I1 = file{1};
    % Detect surf features of the initial image
    points1 = detectSURFFeatures(I1);
    imshow(I1);hold on
    plot(points1.selectStrongest(10));
    hold off;
    % Extract features and corresponding Location of these points 
    [feature1, vpts1] = extractFeatures(I1, points1);
    P1 = vpts1.Location;
    T = [R(1, :); R(2, :); t] * C.IntrinsicMatrix;
    tform = projective2d(T);
    W1 = transformPointsInverse(tform, P1);
    POS = zeros(numOfI,3);
    
    % get points 
    T = [R(1, :); R(2, :); t] * C.IntrinsicMatrix;
    tform = projective2d(T);
    W1 = transformPointsInverse(tform, P1);
    POS(i,:) = t;
   
%   Select any point to get its position in real world
    [x,y]=ginput(1);
    world = transformPointsInverse(tform, [x y])
    
    
    j=0;
    tic;
%     figure;
%     subplot(1,2,1);
    
for i=2:1:43
    % Now new image has arrived
    I2 = file{i};
    points2 = detectSURFFeatures(I2);
    imshow(I2);hold on;
    [feature2, vpts2] = extractFeatures(I2, points2);
    P2 =  vpts2.Location;
    indexPairs = matchFeatures(feature1, feature2);
    matchedPoints1 = vpts1(indexPairs(:, 1));
    matchedPoints2 = vpts2(indexPairs(:, 2));
    Pm1 = (matchedPoints1.Location);
    Pm2 = (matchedPoints2.Location);
    L = length(Pm1);
    if (length(Pm2)<5)
        j=j+1;
    else
    index = zeros(L,1);
    for j=1:1:length(Pm1)
        temp = ismember(P1,Pm1(j,:),'rows');
        index(j) = find(temp>0);
    end
    [R, t] = extrinsics(Pm2, W1(index,:), C);
    
    % We need following prameters for our next iteration, so save them
    % P1,feature1,vpts1,W1
    P1 = P2;
    feature1 = feature2;
    vpts1 = vpts2;
    T = [R(1, :); R(2, :); t] * C.IntrinsicMatrix;
    tform = projective2d(T);
    W1 = transformPointsInverse(tform, P1);
    POS(i,:) = t;
   
%   Select any point to get its position in real world
    [x,y]=ginput(1);
    W = transformPointsInverse(tform, [x y])
%     text(num2str(W))
%     Q = vrrotmat2vec(R);
%     angle = rad2deg(Quaternion_2_Euler(Q(1),Q(2),Q(3),Q(4)));
%     G = [angle t'/1000]
i
    end
end
toc