
%this code finds calibration matrix of camera by taking frames from a video
%and then gives world point of the selected point in the image.
clc;
clear all;
close all
numImages = 10;
%if the number of images is less..unable to estimate..here 4 points needed
%atleast.
files = cell(1, numImages); 
% Calibration 
%153
v = VideoReader('vidamr3.mp4');
%Dynamic.mp4
for i=1:1:numImages
    frame1 = read(v,i*10);
    %?????????takes the thenth frmae frst time,,then tenthieth till 100th frame as
    %the tenth index in image.
    %video = read(obj) reads in all video frames from the file associated with obj. The read method returns a H-by-W-by-B-by-F matrix, video, where H is the
    %image frame height, W is the image frame width, B is the number of bands in the image (for example, 3 for RGB), and F is the number of frames read.

%video = read(obj,index) reads only the specified frames. index can be a single number or a two-element array representing an index range of the video stream.
    filename = strcat('image',num2str(i),'.tif');
    %Concatenate strings horizontally
    imwrite(frame1,filename);
end
for i=1:1:numImages
    filename = strcat('image',num2str(i),'.tif');
    files{i} = filename;
end
[imagePoints, boardSize] = detectCheckerboardPoints(files);
%???????imagepoints:M-by-2-by- number of images array...308 by 286...
%???image points varies for each frame..world point is constant..that is
%why no third dimension in Wldpts.

squareSize = 40; % in millimeters
worldPoints = generateCheckerboardPoints(boardSize, squareSize);
%[worldPoints] = generateCheckerboardPoints(boardSize,squareSize) returns an M-by-2 matrix containing M [x, y] 
%corner coordinates for the squares on a checkerboard. The point [0,0] corresponds to the lower-right corner of the top-left square of the board.

C = estimateCameraParameters(imagePoints, worldPoints);



% Now start Navigation
%[imagePoints, boardSize] = detectCheckerboardPoints(files{1});% Here We can put our SURF Objects
[R, t] = extrinsics(imagePoints(:,:,1), worldPoints, C);
%Compute location of calibrated camera

figure;
imshow(files{1});hold on;
plot(imagePoints(:,1,1), imagePoints(:,2,1), 'ro')
[x, y] = ginput(1);
%ginput raises crosshairs in the current axes to for you to identify points in the figure, positioning the cursor with the mouse

T = [R(1, :); R(2, :); t] * C.IntrinsicMatrix;
%is this the re-projection matrix..as evrything transposed..t is normally the
%third column..actualluy in eqs it is C*(R,T)..but since here C is
%afterwards so r and t in rows and not column....whether forward or
%backward transform..T and tform remains same.
%and in intrinsic matrix check the param.intrinsic..there
%should be zeroes below??. the below elements are the center coordinates of
%camera which isnt 0,0.
%.so this is basically the inverse projection

tform = projective2d(T);
w = transformPointsInverse(tform, [x,y]);


