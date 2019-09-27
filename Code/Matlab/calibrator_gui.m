function varargout = calibrator_gui(varargin)
% DOT_GENERATOR M-file for calibrator_gui.fig
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
%           3) Filename where to save dot position and ts
%           4) File id where to store channel data
%           5) Serial port object (where device is connected)
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

% Last Modified by GUIDE v2.5 06-Sep-2019 18:04:37

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

handles.output_file_name = varargin{3};
handles.stimuli_position = [];
handles.output = hObject;
handles.displayed = false;
% Number of stimuli to display
handles.N_total = varargin{2};
handles.N = 1;

% Initiate timer and callback function:
handles.timer = timer('ExecutionMode', 'fixedSpacing', 'TasksToExecute', handles.N_total, 'Period', period,'TimerFcn',{@timerCallback, hObject});
handles.timer.StopFcn = {@timerStopCallback, hObject};

% Update handles structure
guidata(hObject, handles);
start(handles.timer);

% Time callback: It will be triggered when a new stimuli needs to be
% rendered.
function timerCallback(~, ~, parent_GUI)
% HORIZONTAL CHANNEL:
% Secuence order for 1 calibration cycle 
% (LEFT)        (CENTER)        (RIGHT)
% ---------------> 1 <-----------------
% ------- 2 <--------------------------
% ---------------> 3 >-----------------
% 4 <----------------------------------
% ---------------> 5 >-----------------
% -------------------------> 6 --------
% ---------------> 7 >-----------------
% ----------------------------------> 8
% ---------------> 9 >-----------------

% VERTICAL CHANNEL:
% Secuence order for 1 calibration cycle 
% (UP)     |    10   |    |   
%          |    |    |    |
% (CENTER) 9    |    11   |
%          |    |    |    |
% (DOWN)   |    |    |    12

% Stimuli # for each position
sequence = [ [ 0.50 0.50 ];
             [ 0.00 0.50 ];
             [ 0.50 0.50 ];
             [ 0.25 0.50 ];
             [ 0.50 0.50 ];
             [ 0.75 0.50 ];
             [ 0.50 0.50 ];
             [ 0.97 0.50 ];
             [ 0.50 0.50 ];
             [ 0.50 0.94 ];
             [ 0.50 0.50 ];
             [ 0.50 0.00 ];
             [ 0.50 0.50 ]];

handles = guidata(parent_GUI); 

% Clean previous 'X'
set(handles.X,'Visible','off');

% Initial rendering. Needed to avoid losing start screen.
if ~handles.displayed
    dot_xy = [0.5 0.5];
    handles.displayed = true;
end

% Assign the corresponding calibration position to the marker on the screen
if handles.N <= size(sequence, 1)
    dot_xy = [ sequence(handles.N,1) sequence(handles.N,2) ]; 
end

% Increase total timer
% NOTE: this is independent of the type of stimuli shown (test or
% calibration)
handles.N = handles.N +1;

dot_position = [dot_xy 0.033 0.073]; % [x y width height]
set(handles.X,'Visible','on', 'Position', dot_position);
drawnow;

% Accumulate new stimuli position
handles.stimuli_position = [handles.stimuli_position; [dot_xy now]];

% Update handles structure
guidata(parent_GUI, handles);

function timerStopCallback(~, ~, parent_GUI)
handles = guidata(parent_GUI);
stimuli_position = handles.stimuli_position;

% Save stimuli position to a mat file
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
