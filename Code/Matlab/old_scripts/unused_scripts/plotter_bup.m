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

flp = lowpass();
fhp = highpass();

samples=100;

file_name = strcat(datestr(now, 'dd_mm_yyyy_HH_MM_SS'), '.txt');

fid = fopen(file_name,'w');

while(1)  
    c = [];
    for i=1:5
        c_aux = fread(serial_port, samples, 'float');
        c = [c; c_aux];
    end

%     t = 0:1/500:1-1/500;
%     c = sin(2*pi*t);

    % Separate channel 1 and channel 2 data
    channel_1 = c(1:2:end);
    channel_2 = c(2:2:end);
    
    % Plot incoming signals without filtering
    clf
    subplot(3,2,1)
    plot(channel_1)
    ylim([-100 100])
    title('ch 1 raw')
    
    subplot(3,2,2)
    plot(channel_2)
    ylim([-100 100])
    title('ch 2 raw')
    
    % Low pass filter to remove high frequency noise
    ch1_lp = filter(flp, channel_1);
    ch2_lp = filter(flp, channel_2);
    
    ch1_hp = filter(fhp, ch1_lp);
    ch2_hp = filter(fhp, ch2_lp);

%     % Smoothen data
%     c_smooth_ch1=smooth(channel_1,5);
%     c_smooth_ch2=smooth(channel_2,5);
    
    % Notch filter at 50 Hz        
    wo=50/(250/2);bw=wo/5;
    [bn,an]=iirnotch(wo,bw);
    
    c_filt_ch1 = filter(bn, an, ch1_hp);
    c_filt_ch2 = filter(bn, an, ch2_hp);
    
    % Print data to file
    fprintf(fid, '%f %f \n', [c_filt_ch1 c_filt_ch2]');
    
    % Plot channel 1 and channel 2 data    
    subplot(3,2,3)
    plot(c_filt_ch1)
    ylim([-100 100])
    title('ch 1 filtered')
    
    subplot(3,2,4)
    plot(c_filt_ch2)
    ylim([-100 100])
    title('ch 2 filtered')

    %% FFT

%     [fft_input_all f] = fft(c);
%     subplot(3,2,5)
%     plot(f,P1) 
%     title('Single-Sided Amplitude Spectrum of ALL')
%     xlabel('f (Hz)')
%     ylabel('|P1(f)|')
%     xlim([0 50])
    
    [fft_ch1 f] = fft_custom(c_filt_ch1);
    subplot(3,2,5)
    plot(f,fft_ch1) 
    title('Single-Sided Amplitude Spectrum of CH 1')
    xlabel('f (Hz)')
    ylabel('|fft_ch1(f)|')
    xlim([0 50])
    
    [fft_ch2 f] = fft_custom(c_filt_ch2);
    subplot(3,2,6)
    plot(f,fft_ch2) 
    title('Single-Sided Amplitude Spectrum of CH 2')
    xlabel('f (Hz)')
    ylabel('|fft_ch1(f)|')
    xlim([0 50])

    pause(0.0001)

end