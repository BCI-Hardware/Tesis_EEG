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
% handles object
handles.output = hObject;

% STORE INPUT ARGS IN THE HANDLES OBJECT
% Seconds per stimuli
period =  varargin{1};
% Number of stimuli to display
handles.N_total = varargin{2};
% Filename where to save stimuli positions to
handles.stimuli_file_name = varargin{3};
% File id where to save eeg data to
handles.output_file_id = varargin{4};
% Filename where to save pred positions to
handles.pred_file_name = varargin{5};
% Serial port object
handles.serial_port = varargin{6};
% Calibration limit values:
% [left   up
%  right down]
handles.cal = varargin{7};
% Interdependency factor between CH1 and CH2
handles.alpha = varargin{8};
% Max valid value for CH2 data. Higher values are considered blinks.
handles.blinks_thr = varargin{9};

% Flag to indicate whether the stimuli initial were already displayed or
% not. This is used to avoid getting stuck on the very first render and
% advance properly to the following cycles.
handles.displayed = false;

% Array of accumulated stimuli positions for the test
handles.stimuli_position = [];
% Internal cycles counter
handles.N = 1;
% Flag to indicate whether the current cycle is a calibration or not
handles.calibration_on = false;
% [x y] prediction
handles.pred = [0.5 0.5];

% TIMER OBJECTS
% Initiate timer and callback function:
handles.timer = timer('ExecutionMode', 'fixedSpacing', 'TasksToExecute', handles.N_total, 'Period', period,'TimerFcn',{@timerCallback, hObject});
handles.timer.StopFcn = {@timerStopCallback, hObject};

% Update handles structure
guidata(hObject, handles);
start(handles.timer);

function timerCallback(~, ~, parent_GUI)
% USE IN CASE OF ORDERED STIMULI DISPLAY (either horizontal or vertical
% array)
% Stimuli # for each position
% center = 1:3:100;
% left = 2:3:100;
% right = 3:3:100;

% Calibration parameters
cal_spacing = 6; % Calibrate every 6 stimuli
% Sequence in which calibration will be placed
calibration = 1:cal_spacing:100;
% Sequence of X points for each calibration cycle
cal_xy = [ 0.5 0.5 ]; % Use the center of the screen for now

% Get updated handles data
handles = guidata(parent_GUI);

% Clean previous dot
set(handles.X,'Visible','off');

if ~handles.displayed
    dot_xy = [0.5 0.5];
    handles.displayed = true;
end

% If cycle number is within calibration program and calibrate flag is on,
% proceed with the calibration sequence.
if ismember(handles.N, calibration)   
    % Calibration bell
    res = 100050;
    len = 0.5 * res;
    sound( sin( 400*(2*pi*(0:len)/res) ), res);
    
    % Turn on flag to indicate we are calibrating
    handles.calibration_on = true;
    dot_xy = cal_xy;
    data_type = 'C';
else
    % Make a random position of the dot on screen
    dot_xy = [0.5 0.94*rand(1)];    %0.97*rand(1)
%     if ismember(handles.N, center)
%         dot_xy = [ 0.5 0.5 ];
%     elseif ismember(handles.N, left)
%         dot_xy = [ 0.0 0.5 ];
%     else
%         dot_xy = [ 0.97 0.5 ];
%     end
    % Turn off flag, calibration is over
    handles.calibration_on = false;
    data_type = 'T';
end

% Increase total timer
% NOTE: this is independent of the type of stimuli shown (test or
% calibration)
handles.N = handles.N +1;
% Update handles data so that other threads can use it
guidata(parent_GUI, handles);

X_position = [dot_xy 0.033 0.073]; % [ x y width height ]
set(handles.X,'Visible','on', 'BackgroundColor', 'none', 'Position', X_position);

% Store stimuli position on an array
handles.stimuli_position = [handles.stimuli_position; [dot_xy now]];

% Update handles structure
guidata(parent_GUI, handles);

function timerStopCallback(~, ~, parent_GUI)
handles = guidata(parent_GUI);
stimuli_position = handles.stimuli_position;

% Save the array of stimuli positions, ts and data type indicators to a
% .mat file
save(handles.stimuli_file_name,'stimuli_position');

% --- Outputs from this function are returned to the command line.
function varargout = dot_generator_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Make guide fill window, with normalized screen units (0..1 for both
% directions)
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
drawnow;

% Maximize figure to fill screen
jFig = get(handle(gcf), 'JavaFrame'); 
jFig.setMaximized(true);
% Get default command line output from handles structure
varargout{1} = handles.output;

% Array of peaks detected during the test. This is a matrix with 2 columns,
% one per channel
accum_peaks = [];
% Channel data read on last cycle
last_c = [];

% Accumulated errors for each channel, obtained by calibrating the
% measurements with a stimuli placed at the center of the screen.
% Note that after every calibration this is set back to (0,0)
zero_drift = [0 0];

% Number of points previous to current stimuli to use when computing the
% signal's derivative.
n_derivative = 50;

% EEG samples to read on each cycle
samples = 500;

% Update handles data
handles = guidata(hObject);

% Calibration data for horizontal and vertical movement amplitudes (max
% allowed from center to borders for screen size). This is used as a
% reference to transform channel data to values between 0 and 1.
cal = handles.cal;

pred_array = [];

flushinput(handles.serial_port)
flushoutput(handles.serial_port)

% Main loop to read data from eeg device. Run continuously until stimuli
% render is complete.
while handles.N <= handles.N_total    
    handles = guidata(hObject);
    % If first reading, flush port
    % Read channel data from port
    c = fread(handles.serial_port, samples, 'float');
    
    % If there's already accumulated data, start processing new inputs
    % this is because of the derivative filter)
    if length(last_c) > 1
        % Split channels and filter signal
        [raw_data, filtered_data, peaks] = process_live_data([last_c(end-(2*n_derivative - 1):end); c], n_derivative, handles.alpha, handles.blinks_thr);
        
        % Remove interdependency between channels
        
        % Accumulate calculated peaks
        accum_peaks = [accum_peaks; peaks];
        
        % The current position is the sum of the accumulated peaks
        current_pos_raw = sum(accum_peaks, 1);
        
        % NOTE: this is a little tricky, since it's based on the fact that
        % the only stimuli within the 3s time window in which
        % should_calibrate is ON will be the calibration.
        if handles.calibration_on
            zero_drift = current_pos_raw;
        end
        
        % Corrected position: remove zero drift
        current_pos_corrected = current_pos_raw - zero_drift;
        
        % Scale positions to be within -1...1
        current_pos_estimated = current_pos_corrected ./ cal;
        % Now take it to 0...1
        pred = (current_pos_estimated + 1) ./ 2;
        
        % Cleanup previous marker
        set(handles.O,'Visible','off');
        pred_position = [pred 0.033 0.073]; % [ x y width height ]
        %set(handles.O,'Visible','on', 'BackgroundColor', 'none','Position', pred_position);
        
        pred_array = [pred_array; [pred_position(1:2) handles.N now]];
    end
    drawnow;
    
    % Store last channel data for next derivative calculation
    last_c = c;
    
    % Output channel data to file
    fprintf(handles.output_file_id, '%f\n', c);
end

save(handles.pred_file_name,'pred_array');

% Reading is over. Close port and data files.
fclose(handles.output_file_id);
fclose(handles.serial_port);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
