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
%  This code reads the data sent by the IC ADS1299 through an Arduino NANO.
%  It saves it in a txt file which will be passed then to a plotter
%  function.  
%**************************************************************************
close all
clear

samples=500;
recording_duration = 30; % seconds

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

fopen(serial_port)
pause(6)
flushinput(serial_port)
flushoutput(serial_port)
pause(1)
fwrite(serial_port,'1');
pause(1)

file_name = strcat(datestr(now, 'dd_mm_yyyy_HH_MM_SS'), '.txt');

fid = fopen(file_name,'w');

% Start countdown
tic;

while(toc < recording_duration)  
    c = fread(serial_port, samples, 'float');
    
    % Print data to file
    fprintf(fid, '%f\n', c);

end
disp('Finished recording')

fclose(fid);
fclose(serial_port);

delete(instrfindall)

% Pass data to the plotter to process it
plotter(file_name)