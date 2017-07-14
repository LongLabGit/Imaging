function varargout = imageSeriesPlotSequentially(varargin)
% IMAGESERIESPLOTSEQUENTIALLY MATLAB code for imageSeriesPlotSequentially.fig
%      IMAGESERIESPLOTSEQUENTIALLY, by itself, creates a new IMAGESERIESPLOTSEQUENTIALLY or raises the existing
%      singleton*.
%
%      H = IMAGESERIESPLOTSEQUENTIALLY returns the handle to a new IMAGESERIESPLOTSEQUENTIALLY or the handle to
%      the existing singleton*.
%
%      IMAGESERIESPLOTSEQUENTIALLY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMAGESERIESPLOTSEQUENTIALLY.M with the given input arguments.
%
%      IMAGESERIESPLOTSEQUENTIALLY('Property','Value',...) creates a new IMAGESERIESPLOTSEQUENTIALLY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before imageSeriesPlotSequentially_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to imageSeriesPlotSequentially_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help imageSeriesPlotSequentially

% Last Modified by GUIDE v2.5 13-Aug-2012 15:11:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @imageSeriesPlotSequentially_OpeningFcn, ...
    'gui_OutputFcn',  @imageSeriesPlotSequentially_OutputFcn, ...
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


% --- Executes just before imageSeriesPlotSequentially is made visible.
function imageSeriesPlotSequentially_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to imageSeriesPlotSequentially (see VARARGIN)

% save the imageSeries object into the handles struct
handles.imageSeriesObject = varargin{1};

% set title
figName = handles.imageSeriesObject.description;
if isempty(figName) || ~ischar(figName); figName = 'anonymous image series'; end
set(hObject,'Name',figName)

% set image selection scrollbar range
imCount = size(handles.imageSeriesObject.images,4);
set(handles.imageSelector,'Max',imCount)
set(handles.imageSelector,'Value',1)
set(handles.imageSelector,'Min',1)
if imCount > 1
    set(handles.imageSelector,'SliderStep',[1 1]/(imCount-1))
else
    set(handles.imageSelector,'SliderStep',[0 0])
end

% plot the image with current parameters
plotImage(handles)

% Choose default command line output for imageSeriesPlotSequentially
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes imageSeriesPlotSequentially wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = imageSeriesPlotSequentially_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function minColor_Callback(hObject, eventdata, handles)
% hObject    handle to minColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% higher than max, move max up
if get(handles.minColor,'Value') > get(handles.maxColor,'Value')
    set(handles.maxColor,'Value',get(handles.minColor,'Value')+0.001)
end

plotImage(handles)


% --- Executes during object creation, after setting all properties.
function minColor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function maxColor_Callback(hObject, eventdata, handles)
% hObject    handle to maxColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% lower than min, move min down
if get(handles.maxColor,'Value') < get(handles.minColor,'Value')
    set(handles.minColor,'Value',get(handles.maxColor,'Value')-0.001)
end

plotImage(handles)


% --- Executes during object creation, after setting all properties.
function maxColor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in normAll.
function normAll_Callback(hObject, eventdata, handles)
% hObject    handle to normAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of normAll

plotImage(handles)


% --- Executes on button press in normSingle.
function normSingle_Callback(hObject, eventdata, handles)
% hObject    handle to normSingle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of normSingle

plotImage(handles)


% --- Executes on slider movement.
function imageSelector_Callback(hObject, eventdata, handles)
% hObject    handle to imageSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

plotImage(handles)


% --- Executes during object creation, after setting all properties.
function imageSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imageSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function normalizeRadioGroup_SelectionChangeFcn(hObject,eventdata,handles)
plotImage(handles)



% update slider labels and plot image
function plotImage(handles)

% get image number and put scrollbar on an integer value
imNum = round(get(handles.imageSelector,'Value'));
set(handles.imageSelector,'Value',imNum)

% get the image to be plotted
thisIm = handles.imageSeriesObject.images(:,:,:,imNum);

% normalize
if get(handles.normAll,'Value')
    
    % normalize by the min and max of all images
    
    % get pixels from all images
    ims = handles.imageSeriesObject.images(:);
    
    % get min, max, and range
    imsMax = max(ims);
    imsMin = min(ims);
    imsRng = imsMax - imsMin;
    
    % compute max and min displayed values
    minDisplayColor = get(handles.minColor,'Value')*imsRng + imsMin;
    maxDisplayColor = get(handles.maxColor,'Value')*imsRng + imsMin;
    
    % display image
    imagesc(thisIm,'Parent',handles.plotAxes)
    
    % set color range to the max and min of all images
    set(handles.plotAxes,'clim',[minDisplayColor maxDisplayColor])
    
    
else
    
    % normalize to fit the min and max of this image
    
    % identify min, max, and range
    imMin = min(thisIm(:));
    imMax = max(thisIm(:));
    imRng = imMax-imMin;
    
    % compute the values to display based on sliders
    minDisplayColor = get(handles.minColor,'Value')*imRng + imMin;
    maxDisplayColor = get(handles.maxColor,'Value')*imRng + imMin;
    
    % clip values outside the display range
    thisIm(thisIm<minDisplayColor) = minDisplayColor;
    thisIm(thisIm>maxDisplayColor) = maxDisplayColor;
    
    % display image
    imagesc(thisIm,'Parent',handles.plotAxes)
    
end

% add colorbar
colorbar('peer',handles.plotAxes)

% set title
set(handles.titleText,'String',sprintf('image %d of %d',...
    imNum,size(handles.imageSeriesObject.images,4)))

colormap gray


% FIX: add normalization
% switch 1
%     case 1 % divided by mean
%         ims = ims./repmat(mean(ims,4),[1 1 1 size(ims,4)]);
%     case 2  % minus mean
%         ims = ims - repmat(mean(ims,4),[1 1 1 size(ims,4)]);
% end
