% getting image frames from a camera in matlab
clc;
clear all;
close all;
% get information about the adaptors installed
imaqhwinfo;
vid = videoinput('winvideo',1,'RGB24_640x480');
