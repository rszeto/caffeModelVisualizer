function varargout = caffeModelVisualizer(varargin)
% CAFFEMODELVISUALIZER MATLAB code for caffeModelVisualizer.fig
%      CAFFEMODELVISUALIZER, by itself, creates a new CAFFEMODELVISUALIZER or raises the existing
%      singleton*.
%
%      H = CAFFEMODELVISUALIZER returns the handle to a new CAFFEMODELVISUALIZER or the handle to
%      the existing singleton*.
%
%      CAFFEMODELVISUALIZER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CAFFEMODELVISUALIZER.M with the given input arguments.
%
%      CAFFEMODELVISUALIZER('Property','Value',...) creates a new CAFFEMODELVISUALIZER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before caffeModelVisualizer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to caffeModelVisualizer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help caffeModelVisualizer

% Last Modified by GUIDE v2.5 07-Jan-2017 16:17:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @caffeModelVisualizer_OpeningFcn, ...
                   'gui_OutputFcn',  @caffeModelVisualizer_OutputFcn, ...
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


% --- Executes just before caffeModelVisualizer is made visible.
function caffeModelVisualizer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to caffeModelVisualizer (see VARARGIN)

% Set data values
handles.filterNum = 0;
handles.sliceNum = 0;
handles.layerNameToWeightMap = 0;

% Set colormap for plots
colormap('gray');

% Set Caffe mode (no GPU needed for this program)
caffe.set_mode_cpu();

% --- Stuff below was automatically generated

% Choose default command line output for caffeModelVisualizer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes caffeModelVisualizer wait for user response (see UIRESUME)
% uiwait(handles.mainWindow);


% --- Outputs from this function are returned to the command line.
function varargout = caffeModelVisualizer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in layerListBox.
function layerListBox_Callback(hObject, eventdata, handles)
% hObject    handle to layerListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns layerListBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from layerListBox
% Set layer name
handles.layerName = hObject.String{hObject.Value};
% Get layer weights
layerWeights = handles.layerNameToWeightMap(handles.layerName);

% Determine layer type from shape of weights (either conv or fc)
if length(size(layerWeights)) == 4
    disp('Conv layer');
    % Show conv panel and hide FC panel
    set(handles.convVisPanel, 'Visible', 'On');
    set(handles.fcVisPanel, 'Visible', 'Off');
    
    % Set maximum filter and slice numbers
    [hObject, handles] = updateNumFilters(hObject, handles, size(layerWeights, 4));
    [hObject, handles] = updateNumSlices(hObject, handles, size(layerWeights, 3));
    
    % Reset filter and slice selectors
    [hObject, handles] = updateFilterNum(hObject, handles, 1);
    [hObject, handles] = updateSliceNum(hObject, handles, 1);
    
    % Update filter visualization
    [hObject, handles] = updateConvAxes(hObject, handles);
elseif length(size(layerWeights)) == 2
    disp('FC layer');
    % Show FC panel and hide conv panel
    set(handles.convVisPanel, 'Visible', 'Off');
    set(handles.fcVisPanel, 'Visible', 'On');
    
    % Update FC weight visualization
    [hObject, handles] = updateFcAxes(hObject, handles);
end
% Hide instructions panel
set(handles.instructionsPanel, 'Visible', 'Off');


function [hObject, handles] = updateNumFilters(hObject, handles, numFilters)
handles.numFilters = numFilters;
% Update slider
set(handles.filterNumSlider, 'Max', numFilters);
set(handles.filterNumSlider, 'SliderStep', [1/(numFilters-1), 1/(numFilters-1)]);
% Commit handle data
guidata(hObject, handles);


function [hObject, handles] = updateNumSlices(hObject, handles, numSlices)
handles.numSlices = numSlices;
% Update slider
set(handles.sliceNumSlider, 'Max', numSlices);
set(handles.sliceNumSlider, 'SliderStep', [1/(numSlices-1), 1/(numSlices-1)]);
% Commit handle data
guidata(hObject, handles);


function [hObject, handles] = updateConvAxes(hObject, handles)
% Get slice to show
layerWeights = handles.layerNameToWeightMap(handles.layerName);
slice = layerWeights(:, :, handles.sliceNum, handles.filterNum);
% Show slice with color bar and hide axes
imagesc(slice, 'Parent', handles.convAxes, [0 .2]);
colorbar(handles.convAxes);
set(handles.convAxes, 'Visible', 'Off');


function [hObject, handles] = updateFcAxes(hObject, handles)
% Get weights to show
layerWeights = handles.layerNameToWeightMap(handles.layerName);
% Show weights and colorbar
imagesc(layerWeights, 'Parent', handles.fcAxes, [0 .2]);
colorbar(handles.fcAxes);
% For both axes, hide tick labels and add descriptive label
set(handles.fcAxes, 'XTick', []);
set(handles.fcAxes, 'XTickLabel', []);
xlabel(handles.fcAxes, 'Output index');
set(handles.fcAxes, 'YTick', []);
set(handles.fcAxes, 'YTickLabel', []);
ylabel(handles.fcAxes, 'Input index');


% --- Executes during object creation, after setting all properties.
function layerListBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to layerListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in modelFileButton.
function modelFileButton_Callback(hObject, eventdata, handles)
% hObject    handle to modelFileButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global g_modelRootPath;
[basename, dirname, ~] = uigetfile({'*.prototxt', 'Model files (*.prototxt)'}, 'Model file', g_modelRootPath);
if basename ~= 0
    % Set and display model path
    handles.modelFilePath = fullfile(dirname, basename);
    set(handles.modelFileLabel, 'String', handles.modelFilePath);
    % Enable weight path button
    set(handles.weightsFileButton, 'Enable', 'on');
else
    % Disable weight path button
    set(handles.weightsFileButton, 'Enable', 'off');
    % Reset model path
    handles.modelFilePath = '';
    set(handles.modelFileLabel, 'String', 'None');
end
% Reset weight path
handles.modelWeightsPath = '';
set(handles.modelWeightsLabel, 'String', 'None');
% Reset layer name list
set(handles.layerListBox, 'String', {});
% Show instructions panel
set(handles.instructionsPanel, 'Visible', 'On');
% Commit handle data
guidata(hObject, handles);


% --- Executes on button press in weightsFileButton.
function weightsFileButton_Callback(hObject, eventdata, handles)
% hObject    handle to weightsFileButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global g_modelRootPath;
[basename, dirname, ~] = uigetfile({'*.caffemodel', 'Weight files (*.caffemodel)'}, 'Weight file', g_modelRootPath);
if basename ~= 0
    % Set and display weight path
    handles.modelWeightsPath = fullfile(dirname, basename);
    set(handles.modelWeightsLabel, 'String', handles.modelWeightsPath);
    % Show loading panel and render immediately
    set(handles.loadingPanel, 'Visible', 'On');
    drawnow;
    
    % Get and store network weights
    [orderedLayerNames, layerNameToWeightMap] = createCaffeNet(handles.modelFilePath, handles.modelWeightsPath);
    handles.layerNameToWeightMap = layerNameToWeightMap;
    % Update layer name list
    set(handles.layerListBox, 'String', orderedLayerNames);
    
    % Hide loading panel
    set(handles.loadingPanel, 'Visible', 'Off');
    % Show instructions panel
    set(handles.instructionsPanel, 'Visible', 'On');
end
guidata(hObject, handles);


% --- Auxilliary function
function [orderedLayerNames, layerNameToWeightMap] = createCaffeNet(modelFilePath, weightsFilePath)
disp(['Model file: ' modelFilePath]);
disp(['Model weights: ' weightsFilePath]);
% Clear previous nets
caffe.reset_all();
% Set handle to the net
net = caffe.Net(modelFilePath, weightsFilePath, 'test');

% Get layer information (names and weights)
layerNames = net.layer_names;
layerNameToWeightMap = containers.Map();
% Maintain order of layer names
orderedLayerNames = {};
for i=1:length(layerNames)
    layerName = layerNames{i};
    try
        layerWeights = net.params(layerName, 1).get_data();
        layerNameToWeightMap(layerName) = layerWeights;
        orderedLayerNames{end+1} = layerName;
    catch
        warning('Could not load weights for %s', layerName);
    end
end
disp('Done loading net');


% --- Auxilliary function
function [hObject, handles] = updateFilterNum(hObject, handles, filterNum)
% Set data value
handles.filterNum = filterNum;
% Update GUI
set(handles.filterNumEditLabel, 'String', filterNum);
set(handles.filterNumSlider, 'Value', filterNum);
% Commit data value
guidata(hObject, handles);


% --- Auxilliary function
function [hObject, handles] = updateSliceNum(hObject, handles, sliceNum)
% Set data value
handles.sliceNum = sliceNum;
% Update GUI
set(handles.sliceNumEditLabel, 'String', sliceNum);
set(handles.sliceNumSlider, 'Value', sliceNum);
% Commit data value
guidata(hObject, handles);


% --- Executes on slider movement.
function filterNumSlider_Callback(hObject, eventdata, handles)
% hObject    handle to filterNumSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
filterNum = round(hObject.Value);
[hObject, handles] = updateFilterNum(hObject, handles, filterNum);
[hObject, handles] = updateConvAxes(hObject, handles);


% --- Executes during object creation, after setting all properties.
function filterNumSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filterNumSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function filterNumEditLabel_Callback(hObject, eventdata, handles)
% hObject    handle to filterNumEditLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filterNumEditLabel as text
%        str2double(get(hObject,'String')) returns contents of filterNumEditLabel as a double
[filterNum, status] = str2num(hObject.String);
% Check that conversion worked, filterNum is integer, and is in valid range
if status && mod(filterNum, 1) == 0 && filterNum >= 0 && filterNum < handles.numFilters
    [hObject, handles] = updateFilterNum(hObject, handles, filterNum);
    [hObject, handles] = updateConvAxes(hObject, handles);
else
    [hObject, handles] = updateFilterNum(hObject, handles, handles.filterNum);
end


% --- Executes during object creation, after setting all properties.
function filterNumEditLabel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filterNumEditLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function sliceNumEditLabel_Callback(hObject, eventdata, handles)
% hObject    handle to sliceNumEditLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sliceNumEditLabel as text
%        str2double(get(hObject,'String')) returns contents of sliceNumEditLabel as a double
[sliceNum, status] = str2num(hObject.String);
% Check that conversion worked, sliceNum is integer, and is in valid range
if status && mod(sliceNum, 1) == 0 && sliceNum >= 0 && sliceNum < handles.numSlices
    [hObject, handles] = updateSliceNum(hObject, handles, sliceNum);
    [hObject, handles] = updateConvAxes(hObject, handles);
else
    [hObject, handles] = updateSliceNum(hObject, handles, handles.sliceNum);
end


% --- Executes during object creation, after setting all properties.
function sliceNumEditLabel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliceNumEditLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sliceNumSlider_Callback(hObject, eventdata, handles)
% hObject    handle to sliceNumSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
sliceNum = round(hObject.Value);
[hObject, handles] = updateSliceNum(hObject, handles, sliceNum);
[hObject, handles] = updateConvAxes(hObject, handles);


% --- Executes during object creation, after setting all properties.
function sliceNumSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliceNumSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes during object deletion, before destroying properties.
function mainWindow_DeleteFcn(hObject, eventdata, handles)
% Reset Caffe when exiting. This stops Matlab from crashing on close.
caffe.reset_all();
