function [ R,t,P1,I1,feature1,vpts1,W1,POS,Angle,matchedPoints1,matchedPoints2] = Online(I1,P1,I2,feature1,vpts1,C,R,t,W1 )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
j=0;
    % Now new image has arrived
    points2 = detectSURFFeatures(I2);
%     points2 = points2.selectStrongest(20); 
%     imshow(I2);hold on;
%     plot(points2.selectStrongest(6));
%     hold off;
    [feature2, vpts2] = extractFeatures(I2, points2);
    P2 =  vpts2.Location;
    [indexPairs,matchmetric]  = matchFeatures(feature1, feature2);
%     [matchmetric,indexPairs ] = filtering(matchmetric,indexPairs);
    matchedPoints1 = vpts1(indexPairs(:, 1));
    matchedPoints2 = vpts2(indexPairs(:, 2));
    [matchedPoints1,matchedPoints2,indexPairs] = ...
        best_points3( matchedPoints1,matchedPoints2,indexPairs);
    Pm1 = (matchedPoints1.Location);
    Pm2 = (matchedPoints2.Location);
    L = length(Pm1);
    if (length(Pm2)<5)
        POS = t;
        Angle(1)=atan2d(R(3,2),R(3,3));
        Angle(2)=atan2d(-1*R(3,1)  , sqrt(R(3,2)^2 + R(3,3)^2));
        Angle(3)=atan2d(R(2,1),R(1,1));
        j
        %??eqs from where or i will look.. and j, pos..why 5??
    else
    index = zeros(L,1);
    % Find the world points in the current image from the corresponding
    % points in the previous image
    for j=1:1:length(Pm1)
        temp = ismember(P1,Pm1(j,:),'rows');
        index(j) = find(temp>0);
    end
    % Find R and t from image points and world points
    [R, t] = extrinsics(Pm2, W1(index,:), C);
    
    % We need following prameters for our next iteration, so save them
    % P1,feature1,vpts1,W1
    P1 = P2;
    I1=I2;
    feature1 = feature2;
    vpts1 = vpts2;
    T = [R(1, :); R(2, :); t] * C.IntrinsicMatrix;
    tform = projective2d(T);
    W1 = transformPointsInverse(tform, P1);
    POS= t %position in cm
    Angle(1)=atan2d(R(3,2),R(3,3));
    Angle(2)=atan2d(-1*R(3,1)  , sqrt(R(3,2)^2 + R(3,3)^2));
    Angle(3)=atan2d(R(2,1),R(1,1));
    %%%??pos and angle of camera..just t..angle diff between two images
    %%%how?
    end



end

