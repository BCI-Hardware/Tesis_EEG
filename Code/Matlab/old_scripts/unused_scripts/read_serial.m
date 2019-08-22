%**************************************************************************
%                            TESIS DE GRADO
%                               EEG v1.0
%                   Instituto de Ingenieria Biomédica
%           Facultad de Ingenieria, Universidad de Buenos Aires
%
%               Brian Daniel Santillan, Florencia Grosso.
%                           Tutor: Sergio Lew
%
%  Code description:
%  This code reads the data sent by the IC ADS1299 through an Arduino NANO
%  and saves it in a txt file.
%**************************************************************************
close all
clear

samples = 250;
recording_duration = 10;
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

% Create files to save eeg channel data to.
current_date = datestr(now, 'dd_mm_yyyy_HH_MM_SS');
channel_data_file_name = strcat('data/',current_date, '.txt');
output_file_id = fopen(channel_data_file_name,'w');

% Parameters to make initial sound with
res = 100050;
len = 0.5 * res;
hz = 800;

% Variable to store current cycle
cycle_count = 0;
% Start countdown
cycles_to_record = recording_duration;

% Resting
pause(1);
sound( sin( 400*(2*pi*(0:len)/res) ), res);

while(cycle_count < cycles_to_record)
    % Sounds to mark eye movements
%     if mod(cycle_count, 2) == 0
%         sound( sin( hz*(2*pi*(0:len)/res) ), res);
%     end
%     sound( sin( hz*(2*pi*(0:len)/res) ), res);
    if cycle_count == 0
        flushinput(serial_port)
        flushoutput(serial_port)
    end
    
    %Print channel data to file
    c = fread(output_file_id, samples, 'float');
    fprintf(fid, '%f\n', c);
    
    cycle_count = cycle_count + 1; 
end

disp('Finished recording')
% Final bell
sound( sin( 400*(2*pi*(0:len)/res) ), res);

% Close file and port
fclose(output_file_id);
fclose(serial_port);

delete(instrfindall)