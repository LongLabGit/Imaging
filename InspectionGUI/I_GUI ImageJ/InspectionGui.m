function varargout = InspectionGui(varargin)
% INSPECTIONGUI MATLAB code for InspectionGui.fig
%      INSPECTIONGUI, by itself, creates a new INSPECTIONGUI or raises the existing
%      singleton*.
%
%      H = INSPECTIONGUI returns the handle to a new INSPECTIONGUI or the handle to
%      the existing singleton*.
%
%      INSPECTIONGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INSPECTIONGUI.M with the given input arguments.
%
%      INSPECTIONGUI('Property','Value',...) creates a new INSPECTIONGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before InspectionGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to InspectionGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help InspectionGui

% Last Modified by GUIDE v2.5 03-Oct-2017 14:18:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @InspectionGui_OpeningFcn, ...
                   'gui_OutputFcn',  @InspectionGui_OutputFcn, ...
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


% --- Executes just before InspectionGui is made visible.
function InspectionGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to InspectionGui (see VARARGIN)

% Choose default command line output for InspectionGui
handles.output = hObject;
%%%%%%%%%ADD STUFFS!!!!
set(0,'DefaultFigureWindowStyle','normal')
addpath(genpath('fcns'))
set(handles.upperImg,'Value',1);
handles.roiShape=cell(1);
handles.roi_trace=cell(1);
handles.C={'g','b','r'};
set(handles.imgSelect,'Value',1);
handles.stopit=0;
handles.playing=0;
handles.imgPlot=0;
handles.curSel=1;
handles.assignedR=1:3;
%%%%%%%%
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes InspectionGui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = InspectionGui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in load.
function load_Callback(hObject, eventdata, handles)
% hObject    handle to load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles.imgF,handles.path]=uigetfile('*.tif');
handles.abfF=uigetfile([handles.path '*.abf']);%get a list of the files 
handles.roiF=uigetfile([handles.path '*.zip']);%get a list of the files 
handles.abfF=[handles.path,handles.abfF];
handles.imgF=[handles.path,handles.imgF];
if ~handles.roiF==0
    handles.roiF=[handles.path,handles.roiF];
else
    handles.roiF=[];
end
hold(handles.imgAxes,'on');
guidata(hObject, handles);
pullupdata(hObject);
loadROIS(hObject);

set(handles.Folder,'String',handles.path)



% --- Executes on button press in MotCorr.
function MotCorr_Callback(hObject, eventdata, handles)
% hObject    handle to MotCorr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
is = imageSeries(handles.imgF);
answer = inputdlg('Max Shift (pixels)','maxShift',[1 40]);
maxShift=str2double(answer{1});
newimgF=[handles.path ,'motC_' strrep(handles.imgF,handles.path,'')];
is.motionCorrect('savePath',newimgF,'referenceFrame',1:10,'maxShift',maxShift);
handles.imgF=newimgF;
pullupdata(hObject);

% --- Executes on slider movement.
function imgSelect_Callback(hObject, eventdata, handles)
% hObject    handle to imgSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles=guidata(hObject);%reload data
perc= get(handles.imgSelect,'Value');
imgI=floor(perc*length(handles.imgT));
displayImg(hObject,imgI);
putOnLines(hObject,handles.imgT(imgI));

% --- Executes during object creation, after setting all properties.
function imgSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imgSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over imgSelect.
function imgSelect_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to imgSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in play.
function play_Callback(hObject, eventdata, handles)
% hObject    handle to play (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=guidata(hObject);%reload data
if handles.playing==0
    handles.playing=1;
    set(handles.play,'String','pause')
    guidata(hObject,handles);
else
    handles.stopit=1;
    guidata(hObject,handles);
    return;
end
x=xlim(handles.audio);
[~,start]=min(abs(x(1)-handles.imgT));
[~,stop]=min(abs(x(2)-handles.imgT));
for i=start:stop
    handles=guidata(hObject);%reload data
    if handles.stopit==0
        tic;
        putOnLines(hObject,handles.imgT(i));
        displayImg(hObject,i);
        d=toc;
        pause(.03-d);
    end
end
handles.stopit=0;
handles.playing=0;
set(handles.play,'String','play')
guidata(hObject,handles);

% --- Executes on button press in sel_roi1.
function sel_roi1_Callback(hObject, eventdata, handles)
% hObject    handle to sel_roi1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selectROI(hObject,1);



% --- Executes on button press in sel_roi2.
function sel_roi2_Callback(hObject, eventdata, handles)
% hObject    handle to sel_roi2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selectROI(hObject,2);

% --- Executes on button press in sel_roi3.
function sel_roi3_Callback(hObject, eventdata, handles)
% hObject    handle to sel_roi3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selectROI(hObject,3);





% --- Executes on button press in prev.
function prev_Callback(hObject, eventdata, handles)
% hObject    handle to prev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
r=handles.assignedR(handles.curSel);
rN=max(r-1,1);
handles.assignedR(handles.curSel)=rN;
set(handles.roi_plot(rN),'color',handles.C{handles.curSel});%color it
guidata(hObject,handles);
plotROI(hObject,roi,r);

% --- Executes on button press in next.
function next_Callback(hObject, eventdata, handles)
% hObject    handle to next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
r=handles.assignedR(handles.curSel);
rN=min(r+1,length(handles.roi_plot));
handles.assignedR(handles.curSel)=rN;
set(handles.roi_plot(rN),'color',handles.C{handles.curSel});%color it
guidata(hObject,handles);
plotROI(hObject,roi,r);


% --- Executes on button press in Movie.
function Movie_Callback(hObject, eventdata, handles)
% hObject    handle to Movie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%MAKE MOVIE MAGIC

handles=guidata(hObject);%reload data
axes(handles.audio)
x=xlim;
[~,start]=min(abs(x(1)-handles.imgT));
[~,stop]=min(abs(x(2)-handles.imgT));
v = vision.VideoFileWriter('Movie.avi');
v.FrameRate=30;
v.AudioInputPort=true;
v.VideoCompressor='DV Video Encoder';
audio=handles.wav;
a_inds=1:round(handles.fs/30);%number of samples per frame
for i=start:stop
    putOnLines(hObject,handles.imgT(i));
    displayImg(hObject,i);
    drawnow;
    frame=getframe(handles.figure1);
    inds=a_inds+round(handles.imgT(i)*handles.fs);
    a=audio(inds);
    step(v,frame.cdata,a);
end
release(v);



% --- Executes on slider movement.
function lowerImg_Callback(hObject, eventdata, handles)
% hObject    handle to lowerImg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
displayImg(hObject,0);


% --- Executes during object creation, after setting all properties.
function lowerImg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lowerImg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
% val = get(handles.lowerImg,'Value');


% --- Executes on slider movement.
function upperImg_Callback(hObject, eventdata, handles)
% hObject    handle to upperImg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
displayImg(hObject,0);

% --- Executes during object creation, after setting all properties.
function upperImg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to upperImg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
