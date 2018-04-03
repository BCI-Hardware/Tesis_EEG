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

% Delete all serial port objects, regardless of the value of the object's 
% ObjectVisibility property
delete(instrfindall)

% Create a serial port associated with COM5
serial_port = 'COM5';
s = serial(serial_port);
s.BaudRate = 115200;
s.DataBits = 8;
s.Parity = 'none';
s.StopBits = 1;
s.inputBufferSize = 2056;

fopen(s)
pause(6)
flushinput(s)
flushoutput(s)
pause(1)
fwrite(s,'1');
pause(1)

% Get screen size
scrsz = get(0,'ScreenSize');

% Draw figure to place the graphs
figure('Position',[1 1 0.75*1920 0.75*1080]); % [left bottom width height]
hold on

samples=500;

while(1)
    c = fread(s, samples, 'float')
    if(length(c)<samples)
        length(c)
        break;
    end    
    
    % Separate channel 1 and channel 2 data
    channel_1 = c(1:2:end);
    channel_2 = c(2:2:end);
    
%     % Low pass filter to remove high frequency noise
%     fc = 50; % Cut off frequency
%     fs = 1000; % Sampling rate
%     [b,a] = butter(6,fc/(fs/2)); % Butterworth filter of order 6
%     
%     clp_ch1 = filter(b,a,channel_1); % Will be the filtered signal for ch1
%     clp_ch2 = filter(b,a,channel_2); % Will be the filtered signal for ch2
    
    % Smoothen data
    c_smooth_ch1=smooth(channel_1,5);
    c_smooth_ch2=smooth(channel_2,5);
    
    % Notch filter at 50 Hz        
    wo=50/(250/2);bw=wo/5;
    [bn,an]=iirnotch(wo,bw);
    
    c_filt_ch1 = filter(bn, an, c_smooth_ch1);
    c_filt_ch2 = filter(bn, an, c_smooth_ch2);
    
    % Plot channel 1 and channel 2 data
    clf
    subplot(3,1,1)
    plot(c_filt_ch1)
    
    subplot(3,1,2)
    plot(c_filt_ch2)

    %% FFT
    Fs = 256;            % Sampling frequency                    
    T = 1/Fs;            % Sampling period       
    L = samples;         % Length of signal
    t = (0:L-1)*T;       % Time vector

    Y = fft(c);

    P2 = abs(Y/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);

    f = Fs*(0:(L/2))/L;
    
    subplot(3,1,3)
    plot(f,P1) 
%     title('Single-Sided Amplitude Spectrum of X(t)')
    xlabel('f (Hz)')
    ylabel('|P1(f)|')

    pause(0.0001)

end


fclose(s)
delete(instrfindall)


