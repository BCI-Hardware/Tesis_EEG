function varargout = dot_generator(varargin)
% DOT_GENERATOR M-file for dot_generator.fig
%      DOT_GENERATOR, by itself, creates a new DOT_GENERATOR or raises the existing
%      singleton*.
%
%      H = DOT_GENERATOR returns the handle to a new DOT_GENERATOR or the handle to
%      the existing singleton*.
%
%      DOT_GENERATOR('Property','Value',...) creates a new DOT_GENERATOR using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to dot_generator_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      INPUT ARGUMENTS ARE:
%           1) seconds per dot
%           2) number of dots to display
%           3) name of the file to save the data to
%
%      DOT_GENERATOR('CALLBACK') and DOT_GENERATOR('CALLBACK',hObject,...) call the
%      local function named CALLBACK in DOT_GENERATOR.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dot_generator

% Last Modified by GUIDE v2.5 09-Jun-2019 20:56:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dot_generator_OpeningFcn, ...
                   'gui_OutputFcn',  @dot_generator_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before dot_generator is made visible.
function dot_generator_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for dot_generator
period =  varargin{1};
N = varargin{2};

handles.output_file_name = varargin{3};
handles.stimuli_position = [];
handles.output = hObject;
handles.displayed = false;
handles.N = 1;

% Initiate timer and callback function:
handles.timer = timer('ExecutionMode', 'fixedSpacing', 'TasksToExecute', N, 'Period', period,'TimerFcn',{@timerCallback, hObject});
handles.timer.StopFcn = { @timerStopCallback, hObject};

% Update handles structure
guidata(hObject, handles);
start(handles.timer);

function timerCallback(~, ~, parent_GUI)

left = 2:3:100;
center = 1:3:100;

handles = guidata(parent_GUI); 

% Clean previous dot
set(handles.C,'Visible','off');

if ~handles.displayed
    dot_xy = [0.5 0.5];
    disp 'Hola'
    handles.displayed = true;
else
    % Make a random position of the dot on screen
%     dot_xy = [0.5 0.5];
%     dot_xy = [0.97*rand(1) 0.94*rand(1)];    
    handles.N = handles.N + 1;
    if ismember(handles.N, left)
        dot_xy = [ 0.0 0.5 ];
    elseif ismember(handles.N, center)
        dot_xy = [ 0.5 0.5 ];
    else
        dot_xy = [ 0.97 0.5 ];
    end
end

dot_position = [dot_xy 0.033 0.073];
set(handles.C,'Visible','on', 'Position', dot_position);
drawnow;

handles.stimuli_position = [handles.stimuli_position; [dot_xy now]];

% Update handles structure
guidata(parent_GUI, handles);

function timerStopCallback(~, ~, parent_GUI)
handles = guidata(parent_GUI);
stimuli_position = handles.stimuli_position;

% If mat file doesn't exist, create it. If not, append data to it.
save(handles.output_file_name,'stimuli_position');


% --- Outputs from this function are returned to the command line.
function varargout = dot_generator_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
drawnow;
% Maximize figure
jFig = get(handle(gcf), 'JavaFrame'); 
jFig.setMaximized(true);
% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
