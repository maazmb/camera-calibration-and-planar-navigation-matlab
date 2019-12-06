%This code takes images from database and calculates the camera calibration
%and also finds the world coordinates of the point selected..it also shows
%the reprojection points

%images = imageSet(fullfile(toolboxdir('vision'),'visiondemos','calibration','fishEye'));
%imageFileNames = images.ImageLocation;

%imageFileNames = strcat('image1.tif');
%axes(imageFileNames)

numImages = 4;
 imageFileNames= cell(1, numImages);
for i=1:1:numImages
    imageFileNames{i} = strcat('image',num2str(i),'.tif');
    
end
[imagePoints, boardSize] = detectCheckerboardPoints(imageFileNames);
squareSize = 29;
worldPoints = generateCheckerboardPoints(boardSize, squareSize);
params = estimateCameraParameters(imagePoints, worldPoints);
figure; imshow(imageFileNames{1}); hold on;
plot(imagePoints(:, 1, 1), imagePoints(:, 2, 1), 'go');

[x, y] = ginput(1);
%ginput raises crosshairs in the current axes to for you to identify points in the figure, positioning the cursor with the mouse
[R, t] = extrinsics(imagePoints(:,:,1), worldPoints, params);
T = [R(1, :); R(2, :); t] * params.IntrinsicMatrix;

tform = projective2d(T);
w = transformPointsInverse(tform, [x,y]);



plot(params.ReprojectedPoints(:, 1, 1), params.ReprojectedPoints(:, 2, 1), 'r+');

legend('Detected Points', 'ReprojectedPoints');
hold off;

%DETECTING SURF FEATURES:/
%testimage = imread('image1.tif');
%greyimage = rgb2gray(testimage) (not for the imges here..only for color)
%surffeatures = detectSURFFeatures(testimage);
%[features, interestpoints] = extractFeatures(testimage, surffeatures);
%plot(interestpoints)

%?? it doesnt transform the g input point...
%?? it also doest take the outliers as the checkerboard points...so how do
%we find location of those points..surf..surffeatures..but then how do we
%see location of interest ponts and calculate the ..