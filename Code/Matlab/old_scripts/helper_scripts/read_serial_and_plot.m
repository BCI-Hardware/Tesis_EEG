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

samples = 250;
recording_duration = 100;
% Delete all serial port objects, regardless of the value of the object's 
% ObjectVisibility property
delete(instrfindall)

% Create a serial port associated with COM5
s = 'COM3';
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

% File to save data to
file_name = strcat(datestr(now, 'dd_mm_yyyy_HH_MM_SS'), '.txt');
ts_file_name = strcat(datestr(now, 'dd_mm_yyyy_HH_MM_SS_ts'), '.mat');

fid = fopen(file_name,'w');

% Parameters to make sound with
res = 100050;
len = 0.5 * res;
hz = 800;

% Variable to store current cycle
cycle_count = 0;

% Resting
pause(1);
sound( sin( 400*(2*pi*(0:len)/res) ), res);

% Start countdown
cycles_to_record = recording_duration + 20;

x=1:250;
figure;

while(cycle_count < cycles_to_record)  
    if cycle_count == 0
        flushinput(serial_port)
        flushoutput(serial_port)
        % Save ts at which the test starts
        start_ts = now;
        dot_generator();
    end
    c = fread(serial_port, samples, 'float');
    size(c)
    
    %Print data to file
    fprintf(fid, '%f\n', c);
    
    %Plot samples in real time
    plot(x, c);
    pause(0.01);
    
    cycle_count = cycle_count + 1; 
end
disp('Finished recording')
sound( sin( 400*(2*pi*(0:len)/res) ), res);

fclose(fid);
fclose(serial_port);

delete(instrfindall)

% Save initial ts to file
save(ts_file_name,'start_ts');

% Pass data to the plotter to process it
plotter(file_name)