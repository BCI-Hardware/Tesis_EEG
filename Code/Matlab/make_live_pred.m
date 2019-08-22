%**************************************************************************
%                            TESIS DE GRADO
%                               EEG v1.0
%                   Instituto de Ingenieria Biomédica
%           Facultad de Ingenieria, Universidad de Buenos Aires
%
%                           Florencia Grosso
%                           Tutor: Sergio Lew
%
%  Code description:
%  This code reads the data sent by the IC ADS1299 through an Arduino NANO.
%  It saves it in a txt file which will be passed then to a plotter
%  function.  
%**************************************************************************
close all
clear all

% Samples to read per chunk (1 second of chanel - 250 sps each)
samples = 500;

%% SERIAL PORT

% Delete all serial port objects, regardless of the value of the object's 
% ObjectVisibility property
delete(instrfindall)

% CREATE a serial port associated with COM5
s = 'COM5';
serial_port = serial(s);
serial_port.BaudRate = 115200;
serial_port.DataBits = 8;
serial_port.Parity = 'none';
serial_port.StopBits = 1;
serial_port.inputBufferSize = 2056;

% CLEAN UP
fopen(serial_port)
pause(6)
flushinput(serial_port)
flushoutput(serial_port)
pause(1)
fwrite(serial_port,'1');
pause(1)

%% DEFINE IDS FOR FILES TO EEG SIGNALS AND PREDICTIONS
data_id = '19_06_2019_00_48_39_N2_10000_0.0001';

% Create files to save data to. Make the names out of the current date,
% to avoid stepping over.
current_date = datestr(now, 'dd_mm_yyyy_HH_MM_SS');
% File to store eeg channel data to
predictions_file_name = strcat('predictions/', data_id, '_PRED.txt');
% File to store positions of random dots to
eeg_data_file_name = strcat('predictions/', data_id, '_EEG.txt');
eeg_data_file_id = fopen(eeg_data_file_name,'w');

%% TOOL TO DRAW PREDICTIONS ON THE SCREEN

% Use Window API to get a full screen plot
FigH = figure('Color', [1, 1, 1]);
WindowAPI(FigH, 'Maximize');
% Full screen AXES object, normalized:
AxesH = axes('Units', 'normalized','Position', [0 0 1 1], 'Visible', 'off');
% Window API with some transparency
WindowAPI(FigH, 'Alpha', 0.8, uint8([255, 255, 255]));

% Fix the axis limits.
xlim([0 1]);
ylim([0 1]);

% Set width and height for the square (remember that axes are normalized)
square_width = 0.01;
square_height = 0.02; %square_width*2 since screen is normalized

%% READ & PREDICT LOOP
first_iteration = true;
activation_relu = true;
ch_dat = [];
ch_dat2 = [];

while true
    % On first pass, clean the port and start the dot generator
    if first_iteration
        flushinput(serial_port)
        flushoutput(serial_port)
        first_iteration=false;
    end
   
    % Read samples from serial port
    c = fread(serial_port, samples, 'float');    
    
    % Split channels, filter signal and remove outliers
    [clean_channel_data, raw_channel_data] = process_live_data(c);
    
    nn_input = [clean_channel_data(:,1);clean_channel_data(:,2)]';
    size(nn_input)
    
    normalized_input = normalize_data(nn_input, activation_relu);
    
    % Compute prediction (normalized between 0 and 1)
    [x_pred, y_pred] = get_normalized_pred(normalized_input, data_id);
    x_pred
    y_pred
    % Draw predicted point as a square on the screen
    hold on;
    % First clear previous rectangle
    cla
    % Now draw new one
    rectangle('Position', [(x_pred - square_width/2) (y_pred - square_height/2) square_width square_height], 'EdgeColor', 'r', 'FaceColor','r');
    
    %Print channel data to file
    ch_dat = [ch_dat; clean_channel_data];
    ch_dat2 = [ch_dat2; raw_channel_data];
    %fprintf(eeg_data_file_name, '%f\n', clean_channel_data);
end

% Close file and port
% fclose(output_file_id);
fclose(serial_port);
delete(instrfindall);