function varargout = VNav(varargin)
% VNAV MATLAB code for VNav.fig
%      VNAV, by itself, creates a new VNAV or raises the existing
%      singleton*.
%
%      H = VNAV returns the handle to a new VNAV or the handle to
%      the existing singleton*.
%
%      VNAV('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VNAV.M with the given input arguments.
%
%      VNAV('Property','Value',...) creates a new VNAV or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before VNav_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to VNav_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help VNav

% Last Modified by GUIDE v2.5 03-Jul-2016 23:41:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @VNav_OpeningFcn, ...
                   'gui_OutputFcn',  @VNav_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before VNav is made visible.
function VNav_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to VNav (see VARARGIN)

% Choose default command line output for VNav
handles.output = hObject;
handles.check=0;
% Update handles structure
axes(handles.Distance);
legend('Horizontal X','Height Y','Depth Z')
ylabel('Distance cm')
axes(handles.Angles);
legend('X angle','Y angle','Z angle')
ylabel('Angles Degree')
guidata(hObject, handles);

% UIWAIT makes VNav wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = VNav_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Online.
function Online_Callback(hObject, eventdata, handles)
% hObject    handle to Online (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clc;
load 'C_Cam.mat';
%???this calibration matrix from where?

% Connect to the webcam.
cam = webcam(2);
%?? webcam giving error
% To acquire a single frame, use the |snapshot| function.
frame1 = snapshot(cam);
imwrite(frame1,'IM.tif')
% Now find [R,t] matrix for initial Image
squareSize = 31; % in millimeters
[imagePoints, boardSize] = detectCheckerboardPoints('IM.tif');% Here We can put our SURF Objects
axes(handles.Cam);

imshow(frame1);hold on;plot(imagePoints(:,1),imagePoints(:,2),'ro');
hold off;
worldPoints = generateCheckerboardPoints(boardSize, squareSize);
[R, t] = extrinsics(imagePoints(:,:,1), worldPoints, C);
%???imagepoints..why does it hav third dimension here..noramlly just 2d.

% numOfI = N;
% Read all the images from memory

% Now Navigation Starts
    I1 = snapshot(cam);
    I1 = rgb2gray(I1);
 % We already have R and t for this initial image
 % Detect surf features of the initial image
 points1 = detectSURFFeatures(I1);
 % Extract features and corresponding Location of these points 
 [feature1, vpts1] = extractFeatures(I1, points1);
 P1 = vpts1.Location;
 % We have R and t and image points.
 % Reproject to get world coordinate values for corresponding image
 % points
 %????isnt reprojection from world to image?
 %??why cant we simply use generatecheckerboard points to get
 %worlpoints..this for random images without checkerboaard?
 T = [R(1, :); R(2, :); t] * C.IntrinsicMatrix;
 tform = projective2d(T);
 W1 = transformPointsInverse(tform, P1);
 
j=0;i=0;Pm2 = zeros(10,2);
 while(handles.check==0)
%??when does the check change
    i=i+1;
    I2 = snapshot(cam);
    I2 = rgb2gray(I2);
    I1_old=I1;
    [ R,t,P1,I1,feature1,vpts1,W1,POS,Angle,matchedPoints1,matchedPoints2] = ...
        Online( I1,P1,I2,feature1,vpts1,C,R,t,W1 ); 
     axes(handles.Distance);
     hold on
     plot(i,POS,'*');
     hold off
     axes(handles.Angles);
     plot(i,Angle,'*');
     hold on;
     axes(handles.Cam);
     hold off;
     showMatchedFeatures(I1_old,I1,matchedPoints1,matchedPoints2);
     if (handles.check==1);
         
         %?? how does this change..check
        close(handles.gui);
        delete(handles.figure1);
     end
 end
 clear cam;


% --- Executes on button press in Offline.
function Offline_Callback(hObject, eventdata, handles)
% hObject    handle to Offline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clc;
load 'C.mat';
filename = uigetfile;
v = VideoReader(filename);
N=v.NumberOfFrames;
%???numberof frames has been removed from the current version of
%matlab,,but can also calculate it

i=1;
file=cell(N,1);
%fpr all frames in video...column matrix as opposed to rpw matrix in
%calibration.m
frame1 = read(v,1);
imwrite(frame1,'IM.tif');
% Now find [R,t] matrix for initial Image
squareSize = 31; % in millimeters
[imagePoints, boardSize] = detectCheckerboardPoints('IM.tif');% Here We can put our SURF Objects
axes(handles.Cam);
imshow(frame1);hold on;plot(imagePoints(:,1),imagePoints(:,2),'ro');
hold off;
worldPoints = generateCheckerboardPoints(boardSize, squareSize);
[R, t] = extrinsics(imagePoints(:,:,1), worldPoints, C);
numOfI = N;
% % Read all the images from memory
% for i=1:1:numOfI
%     frame = read(v,i);
%     frame = rgb2gray(frame);
%     file{i} = frame;
% end
% Read all the images from memory @ high frame rate
b=0;
for i=1:1:numOfI
    b=b+1;
    frame = read(v,i);
    frame = rgb2gray(frame);
    file{b} = frame;
end
% Now Navigation Starts
 I1 = file{1};
 % We already have R and t for this initial image
 % Detect surf features of the initial image
 points1 = detectSURFFeatures(I1);
 % Extract features and corresponding Location of these points 
 [feature1, vpts1] = extractFeatures(I1, points1);
 P1 = vpts1.Location;
 % We have R and t and image points.
 % Reproject to get world coordinate values for corresponding image
 % points
 T = [R(1, :); R(2, :); t] * C.IntrinsicMatrix;
 tform = projective2d(T);
 W1 = transformPointsInverse(tform, P1);
 POS = zeros(numOfI-1,3);
 Angle = zeros(numOfI-1,3);
 for i=2:1:numOfI
     I2 = file{i};
     I1_old=I1;
    [ R,t,P1,I1,feature1,vpts1,W1,POS,Angle,matchedPoints1,matchedPoints2] = ...
        Offline( I1,P1,I2,feature1,vpts1,C,R,t,W1 ); 
     axes(handles.Distance);
     hold on
     plot(i,POS,'*');
     hold off
     axes(handles.Angles);
     plot(i,Angle,'*');
     hold on;
     axes(handles.Cam);
     hold off;
     showMatchedFeatures(I1_old,I1,matchedPoints1,matchedPoints2);
     %if (handles.check==1);
      %  close(handles.gui);
       % delete(handles.figure1);
     %end
 end
 %if(exist ('cam','var'))
  %   clear cam;
 
%end

% --- Executes on button press in Exit.
function Exit_Callback(hObject, eventdata, handles)
% hObject    handle to Exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% if(exist ('cam','var'))
 %    clear cam;
 %end
handles.check=1;
guidata(hObject, handles);
delete(handles.figure1)
