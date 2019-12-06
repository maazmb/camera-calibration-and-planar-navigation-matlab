function [ R,t,P1,I1,feature1,vpts1,W1,POS,Angle,matchedPoints1,matchedPoints2] = Offline(I1,P1,I2,feature1,vpts1,C,R,t,W1 )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    % Now new image has arrived
    %POS1,POS2,POS3
    points2 = detectSURFFeatures(I2);
%     imshow(I2);hold on;
%     plot(points2.selectStrongest(6));
%     hold off;
    [feature2, vpts2] = extractFeatures(I2, points2);
    P2 =  vpts2.Location;
    [indexPairs,matchmetric]  = matchFeatures(feature1, feature2);
%     [matchmetric,indexPairs ] = filtering(matchmetric,indexPairs);
    matchedPoints1 = vpts1(indexPairs(:, 1));
    matchedPoints2 = vpts2(indexPairs(:, 2));
    [matchedPoints1,matchedPoints2,indexPairs,count] = ...
        best_points( matchedPoints1,matchedPoints2,indexPairs );
    Pm1 = (matchedPoints1.Location);
    Pm2 = (matchedPoints2.Location);
    L = length(Pm1);
    k =1;
    if (length(Pm2)<5)
        %{}
        POS=t/20;
        %POS2(k) = t(2);
        %POS3(k)  = t(3);
        Angle(1)=atan2d(R(3,2),R(3,3));
        Angle(2)=atan2d(-1*R(3,1)  , sqrt(R(3,2)^2 + R(3,3)^2));
        Angle(3)=atan2d(R(2,1),R(1,1));
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
    %here the world points remain the same for the matched points..they
    %dont change..lbvioudsly
    
    % We need following prameters for our next iteration, so save them
    % P1,feature1,vpts1,W1
    
    P1 = P2;
    I1=I2;
    feature1 = feature2;
    vpts1 = vpts2;
    T = [R(1, :); R(2, :); t] * C.IntrinsicMatrix;
    %since k is multiplied afterwards so it is transposed
    tform = projective2d(T);
    W1 = transformPointsInverse(tform, P1);
    POS= t/20; %position in cm
    Angle(1)=atan2d(R(3,2),R(3,3));
    %x axis..psi
    Angle(2)=atan2d(-1*R(3,1)  , sqrt(R(3,2)^2 + R(3,3)^2));
    %y axis..theta
    Angle(3)=atan2d(R(2,1),R(1,1));
    %z axis..phi
    end



end

