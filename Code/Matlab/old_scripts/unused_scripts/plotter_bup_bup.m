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
%  This code reads and processes the data sent by the IC ADS1299 through an
%  Arduino NANO
%**************************************************************************
close all
clear

arduino_SR = 250;
samples=500;
active_channels = 1;
recording_duration = 30; % seconds

plot_status = false;

% Notch filter at 50 Hz
wo=50/(250/2);bw=wo/5;
[bn,an]=iirnotch(wo,bw);

% Global file identifiers
global fid
global serial_port

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

% Get screen size
scrsz = get(0,'ScreenSize');
% Draw figure to place the graphs
plotter_fig = figure('Position',[1 1 0.75*1920 0.75*1080]); % [left bottom width height]
set(plotter_fig,'KeyPressFcn',@stop_recording_fcn);
hold on

file_name = strcat(datestr(now, 'dd_mm_yyyy_HH_MM_SS'), '.txt');

fid = fopen(file_name,'w');

% Start countdown
tic;

while(toc < recording_duration)  
    c = [];
    for i=1:5
        c_aux = fread(serial_port, samples, 'float');
        c = [c; c_aux];
    end
    
    % Plot incoming signals without filtering
    for i=1:active_channels
        j = 0;
        % G
        channel(:,i) = c(i:active_channels:end);
        
        if plot_status
            clf
            subplot(3,active_channels,active_channels + j)
            plot(channel(:,i))
            ylim([-100 100])
            title(strcat('Raw CH', int2str(i)))
            j=j+1;
        end

        % High pass filter to remove DC
        ch_hp(i,:) = eegfilt(channel(:,i)', arduino_SR, 1, 0);        
        % Low pass filter to remove high frequency noise
        ch_lp(:,i) = eegfilt(ch_hp(i, :), arduino_SR, 0, 100)';
      
        % Notch filter at 50 Hz
        c_filt_ch(:,i) = filter(bn, an, ch_lp(:,i));
        
        % Print data to file
        fprintf(fid, '%f\n', c_filt_ch(:,i));
        
        % Plot channel data (filtered)
        if plot_status
            subplot(3,active_channels,active_channels + j)
            plot(c_filt_ch(:,i))
            ylim([-100 100])
            title(strcat('Filtered CH', int2str(i)))
            j=j+1;
        end
        
        if plot_status            
            % Compute and plot channel FFT
            [fft_ch(:,i) f] = fft_custom(c_filt_ch(:,i));
            subplot(3,active_channels,active_channels + j)
            plot(f,fft_ch(:,i))
            title(strcat('Single-Sided Amplitude Spectrum of CH', int2str(i)))
            xlabel('f (Hz)')
            ylabel('|fft_ch1(f)|')
            xlim([0 20])
            j=j+1;
        end
    end

    pause(0.0001)
end

fclose(fid);
fclose(serial_port);
    
delete(instrfindall)

read_data(file_name)