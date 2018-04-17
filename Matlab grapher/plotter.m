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
%  This code reads EEG data from a txt file, filters and plots both the raw
%  data and the filtered one. It also performs an FFT on the data.
%**************************************************************************
function read_data(file_name)

arduino_SR = 250;
samples=500;
active_channels = 1;
plot_status = true;

% Notch filter at 50 Hz
wo=50/(250/2);bw=wo/5;
[bn,an]=iirnotch(wo,bw);

fileID = fopen(file_name,'r');
data = fscanf(fileID,'%f');
fclose(fileID);

% Get screen size
scrsz = get(0,'ScreenSize');
% Draw figure to place the graphs
plotter_fig = figure('Position',[1 1 0.75*1920 0.75*1080]); % [left bottom width height]
hold on

x=0:1/250:length(data)/250 - 1/250;

size(data)
for i=1:active_channels
    j = 0;    
    channel(:,i) = data(i:active_channels:end, i);
    
    % Plot incoming signals without filtering
    clf
    subplot(3,active_channels,active_channels + j)
    plot(x, channel(:,i))
    ylim([-100 100])
    title(strcat('Raw CH', int2str(i)))
    j=j+1;
    
    % High pass filter to remove DC
    ch_hp(i,:) = eegfilt(channel(:,i)', arduino_SR, 1, 0);
    % Low pass filter to remove high frequency noise
    ch_lp(:,i) = eegfilt(ch_hp(i, :), arduino_SR, 0, 100)';
    
    % Notch filter at 50 Hz
    c_filt_ch(:,i) = filter(bn, an, ch_lp(:,i));
    
    % Plot channel data (filtered)
    subplot(3,active_channels,active_channels + j)
    plot(x, c_filt_ch(:,i))
    ylim([-100 100])
    title(strcat('Filtered CH', int2str(i)))
    j=j+1;
    
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