function varargout = m(varargin)
% M MATLAB code for m.fig
%      M, by itself, creates a new M or raises the existing
%      singleton*.
%
%      H = M returns the handle to a new M or the handle to
%      the existing singleton*.
%
%      M('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in M.M with the given input arguments.
%
%      M('Property','Value',...) creates a new M or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before m_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to m_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help m

% Last Modified by GUIDE v2.5 10-Oct-2016 14:25:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @m_OpeningFcn, ...
                   'gui_OutputFcn',  @m_OutputFcn, ...
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


% --- Executes just before m is made visible.
function m_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to m (see VARARGIN)


% Choose default command line output for m
handles.output = hObject;
%to set background image
%create an axes that spans the whole GUI
ah = axes('unit', 'normalized', 'position', [0 0 1 1]);

%import the background image and show it on axes
bg = imread('back.jpg');
%scale and display image
hi = imagesc(bg);

%prevent plotting over the background and turn the axis off
set(ah, 'handlevisibility', 'off', 'visible', 'off')
%making sure the background is behind all the other uicontrols
uistack(ah, 'bottom');
set(hi,'alphadata',.65)

handles.check=0;
% Update handles structure
axes(handles.Distance);
legend('Horizontal X','Height Y','Depth Z')
ylabel('Distance cm')
xlabel('Frames n')
axes(handles.Angles);
legend('X angle','Y angle','Z angle')
ylabel('Angles Degree')
xlabel('Frames n')
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes m wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = m_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Upload.
function Upload_Callback(hObject, eventdata, handles)
% hObject    handle to Upload (see GCBO)
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

 



% --- Executes on button press in Exit.
function Exit_Callback(hObject, eventdata, handles)
% hObject    handle to Exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.check=1;
guidata(hObject, handles);
delete(handles.figure1)
