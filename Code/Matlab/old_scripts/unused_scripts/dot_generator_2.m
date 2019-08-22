function varargout = dot_generator(varargin)
% DOT_GENERATOR MATLAB code for dot_generator.fig
%      DOT_GENERATOR, by itself, creates a new DOT_GENERATOR or raises the existing
%      singleton*.
%
%      H = DOT_GENERATOR returns the handle to a new DOT_GENERATOR or the handle to
%      the existing singleton*.
%
%      DOT_GENERATOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DOT_GENERATOR.M with the given input arguments.
%
%      DOT_GENERATOR('Property','Value',...) creates a new DOT_GENERATOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dot_generator_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dot_generator_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dot_generator

% Last Modified by GUIDE v2.5 13-Jun-2018 23:53:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dot_generator_OpeningFcn, ...
                   'gui_OutputFcn',  @dot_generator_OutputFcn, ...
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


% --- Executes just before dot_generator is made visible.
function dot_generator_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dot_generator (see VARARGIN)

% Choose default command line output for dot_generator
handles.output = hObject;

% Initiate timer and callback function:
handles.timer = timer('Period',1,'TimerFcn',{@timerCallback,handles}); 
start(handles.timer);

% dot_handles = [handles.NO, handles.O, handles.SO, handles.S, handles.SE, handles.E, handles.NE, handles.N, handles.C];
% rand_idxs = randi(length(dot_handles), 1, 10);

function timerCallback(hObject, eventdata, handles)
disp('Timer Function Executing')
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes dot_generator wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = dot_generator_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
