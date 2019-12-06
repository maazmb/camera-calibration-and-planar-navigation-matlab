clc;
clear all;
close all;

srcFiles = dir('D:\BUAA_Folder\Semester2\Computer Vision\Final Project\Calibration Experiment\Original Images\*.jpg');  % the folder in which ur images exists
for i = 1 : length(srcFiles)
    filename = strcat('D:\BUAA_Folder\Semester2\Computer Vision\Final Project\Calibration Experiment\Original Images\image',num2str(i),'.jpg');
    I = imread(filename);
    I2 = rgb2gray(I);
    I3 = imresize(I2,0.3);
    h = imshow(I3)
    filename = strcat('D:\BUAA_Folder\Semester2\Computer Vision\Final Project\Calibration Experiment\Images\image',num2str(i),'.tif');
    imwrite(I3, filename);
 end