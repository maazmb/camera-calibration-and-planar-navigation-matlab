function varargout = Checkerboardnav(varargin)
% CHECKERBOARDNAV MATLAB code for Checkerboardnav.fig
%      CHECKERBOARDNAV, by itself, creates a new CHECKERBOARDNAV or raises the existing
%      singleton*.
%
%      H = CHECKERBOARDNAV returns the handle to a new CHECKERBOARDNAV or the handle to
%      the existing singleton*.
%
%      CHECKERBOARDNAV('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHECKERBOARDNAV.M with the given input arguments.
%
%      CHECKERBOARDNAV('Property','Value',...) creates a new CHECKERBOARDNAV or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Checkerboardnav_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Checkerboardnav_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Checkerboardnav

% Last Modified by GUIDE v2.5 27-Jul-2017 13:53:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Checkerboardnav_OpeningFcn, ...
                   'gui_OutputFcn',  @Checkerboardnav_OutputFcn, ...
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


% --- Executes just before Checkerboardnav is made visible.
function Checkerboardnav_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Checkerboardnav (see VARARGIN)

% Choose default command line output for Checkerboardnav
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
set(hi,'alphadata',.7)

handles.limit =0;
handles.check= 0;
handles.POS = [];
handles.Angle =  [];
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

% UIWAIT makes Checkerboardnav wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Checkerboardnav_OutputFcn(hObject, eventdata, handles) 
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
  POS1 = zeros(numOfI-1);
  POS2 = zeros(numOfI-1);
  POS3 = zeros(numOfI-1);
 Angle = zeros(numOfI-1,3);
 savePOS(1,:) = zeros(1,3);
 saveAngle(1,:) = zeros(1,3);
 %world(1,:) = W1;
 %points(1,:) = vpts1;
 %delete(handles.figure1)
 
 while (handles.check  == 0 && handles.limit == 0)
    
 for i=2:2:numOfI
     %numOfI
      handles = guidata(hObject);
    %   delete(handles.figure1)
     I2 = file{i};
     %i*10
     I1_old=I1;
     
     
    [ R,t,P1,I1,feature1,vpts1,W1,POS,Angle,matchedPoints1,matchedPoints2] = ...
        Offline( I1,P1,I2,feature1,vpts1,C,R,t,W1 ); 
    %POS1,POS2,POS3
    %fprintf('axes data');
   % msgbox('axes data');
  % world(:,i) = W1;
  %display(POS)
  %display(Angle)
  %POS(i) = [POS1 POS2 POS3]
    savePOS(i,:) = POS;
 saveAngle(i,:) = Angle;
 %points(:,i) = vpts1;
 
 %these assignments arent working..handles.pos still empty
 handles.POS = savePOS;
  handles.Angle= saveAngle;
  %handles.world = world;
  %handles.points  = points;
   
     axes(handles.Distance);
     hold on
     plot(i,POS,'*');
     hold off
     axes(handles.Angles);
     plot(i,Angle,'*');
     hold on;
     axes(handles.Cam);
     hold off;
    
    % assignin('base', 'POS', POS)
%assignin('base', 'Angle', Angle)
     showMatchedFeatures(I1_old,I1,matchedPoints1,matchedPoints2);
     drawnow
     % fprintf('after draw');
     % msgbox('sfter draw');
     pause(0.0001);
     %fprintf('after pause');
    %sprintf('%d',handles.check)
   % display(i)
     if (handles.check==1 || i==numOfI);
         %numOfI
      %  close(handles.gui);
       %delete(handles.figure1)
       handles.limit=1;
       %display(handles.limit)
        fprintf('in if loop....\n');
      
      break
     end
     %delete(handles.figure1)
     
 end
 end
  handles.POS = savePOS;
  handles.Angle= saveAngle;
  assignin('base', 'Position', savePOS)
assignin('base', 'Anglesf', saveAngle)
  if (handles.check==1)
delete(handles.figure1)
  end



% --- Executes on button press in Save.
function Save_Callback(hObject, eventdata, handles)
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%evalin('base', 'save(''Checkernav1.mat'')');
save('Checkerboardnav.mat');
save guioutput;
assignin('base', 'POS', handles.POS)
assignin('base', 'Angle', handles.Angle)
%assignin('base', 'points', handles.points)
%assignin('base', 'world', handles.world)

% --- Executes on button press in Exitnow.
function Exitnow_Callback(hObject, eventdata, handles)
% hObject    handle to Exitnow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.check = 1; 
guidata(hObject, handles);
%handles = guidata(hObject);
%isfield(handles,'check')
handles.check
msgbox('Process stopped');
 fprintf('trying to stop...\n');
 %delete(handles.figure1)
%guidata(hObject, handles);
