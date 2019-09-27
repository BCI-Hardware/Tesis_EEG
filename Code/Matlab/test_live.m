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
% Create files to save data to. Make the names out of the current date,
% to avoid stepping over.
current_date = datestr(now, 'dd_mm_yyyy_HH_MM_SS');
% File to store positions of random dots to
dot_positions_file_name = strcat('data/', current_date, '.mat');
% File to store eeg channel data to
channel_data_file_name = strcat('data/', current_date, '.txt');
output_file_id = fopen(channel_data_file_name,'w');

%% READ & PREDICT LOOP
first_iteration = true;
activation_relu = true;
ch_dat = [];
ch_dat2 = [];

accum_peaks = [];
last_c = [];
figure
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
    [raw_data, filtered_data, peaks] = process_live_data([last_c(1:end-100) c], 50);
    
    accum_peaks = [accum_peaks; peak];
    current_pos = sum(accum_peaks);
    
    % NOTE: this is done only for CH1 for now
    x=[current_pos(1),current_pos(1)];
    y=[0,10];    
    plot(x,y);
    xlim([-5000 5000])
    pause(0.1);
    
    last_c = c;
end

% Close file and port
% fclose(output_file_id);
fclose(serial_port);
delete(instrfindall);