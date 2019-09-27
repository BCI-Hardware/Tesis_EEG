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
clear

samples = 500;
% Configuration for the dot displacing screen
seconds_per_dot = 3;
N_dots = 30;
recording_duration = seconds_per_dot * (N_dots + 15);

%% Serial port
% Delete all serial port objects, regardless of the value of the object's 
% ObjectVisibility property
delete(instrfindall)

% Create a serial port associated with COM5
s = 'COM5';
serial_port = serial(s);
serial_port.BaudRate = 115200;
serial_port.DataBits = 8;
serial_port.Parity = 'none';
serial_port.StopBits = 1;
serial_port.inputBufferSize = 2056;

% Perform serial port clean up
fopen(serial_port)
pause(6)
flushinput(serial_port)
flushoutput(serial_port)
pause(1)
fwrite(serial_port,'1');
pause(1)

%% Output files set up
% Create files to save data to. Make the names out of the current date,
% to avoid stepping over.
current_date = datestr(now, 'dd_mm_yyyy_HH_MM_SS');
% File to store positions of random dots to
dot_positions_file_name = strcat('data/', current_date, '.mat');
% File to store eeg channel data to
channel_data_file_name = strcat('data/', current_date, '.txt');
output_file_id = fopen(channel_data_file_name,'w');

%%

% Variable to store current cycle
current_cycle = 0;
% Start countdown
cycles_to_record = recording_duration;
calibration_cycles = 0:5:cycles_to_record;

% Initial bell
res = 100050;
len = 0.5 * res;
sound( sin( 400*(2*pi*(0:len)/res) ), res);

% x coordinates used to do real time plotting
n_sample=1:samples;

% Initial timestamp
ts = 0;
figure;
d0 = 0;
x = [];
% hold on;
while(current_cycle < cycles_to_record)
    % On first pass, clean the port and start the dot generator
    if current_cycle == 0
        flushinput(serial_port)
        flushoutput(serial_port)
        gui = dot_generator(seconds_per_dot, N_dots, dot_positions_file_name);
        h = figure(gui)
        % Save initial timestamp
        ts = now;
    end
   
    c = fread(serial_port, samples, 'float')
    
    %Print channel data to file
    fprintf(output_file_id, '%f\n', c);    
    current_cycle = current_cycle + 1; 
end

disp('Finished recording')

% Final bell
sound( sin( 400*(2*pi*(0:len)/res) ), res);

close all;

% Close file and port
fclose(output_file_id);
fclose(serial_port);
delete(instrfindall);