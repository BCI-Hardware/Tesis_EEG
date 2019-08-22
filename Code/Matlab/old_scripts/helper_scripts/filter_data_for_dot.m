%**************************************************************************
%                            TESIS DE GRADO
%                               EEG v1.0
%                   Instituto de Ingenieria Biomédica
%           Facultad de Ingenieria, Universidad de Buenos Aires
%
%               Brian Daniel Santillan, freq_loworencia Grosso.
%                           Tutor: Sergio Lew
%
%  Code description:
%  This code takes input data and applies a low pass and a high pass
%  filter, and a notch filter to remove 50Hz noise.
%  It also performs an FFT on the eeg_data.
%
%  All raw, filtered and FFT are plotted.
%**************************************************************************

function filter_data_for_dot(channel)

arduino_sampling_rate = 250;
samples = 250;
active_channels = size(channel, 2);

% Notch filter at 50 Hz
wo=50/(250/2);bw=wo/5;
[bn,an]=iirnotch(wo,bw);

time=0:1/250:length(eeg_data)/250 - 1/250;

% Draw figure to place the graphs
figure('Position',[1 1 0.75*1920 0.75*1080]); % [left bottom width height]
hold on

for i=1:active_channels
    % Plot incoming signals without filtering
    clf
    subplot(3,active_channels,active_channels + j)
    plot(time, channel(:,i))
    title(strcat('Raw CH', int2str(i)))
    xlabel('Time [s]')
    ylabel('Amplitude [\muV]')
    j=j+1;
    
    % Alpha Test filters
    freq_low=0.5;
    freq_high=12;
    
    % High pass filter to remove DC
    channel_data_hp(i,:) = eegfilt(channel(:,i)', arduino_sampling_rate, freq_low, 0);
    %     Low pass filter to remove high frequency noise
    %channel_data_lp(:,i) = eegfilt(channel_data_hp(i, :), arduino_sampling_rate, 0, freq_high)'
    channel_data_lp(:,i) = eegfilt(channel(:,i)', arduino_sampling_rate, 0, freq_high)';
    
    % Notch filter at 50 Hz
    channel_data_notch(:,i) = filter(bn, an, channel_data_lp(:, i));
    
    % Plot channel eeg_data (filtered)
    subplot(3,active_channels,active_channels + j)
    plot(time, channel_data_notch(:,i))
    title(strcat('Filtered CH', int2str(i)))
    xlabel('Time [s]')
    ylabel('Amplitude [\muV]')
    j=j+1;
    
    % Compute and plot channel FFT
    [channel_data_fft(:,i) freq] = fft_custom(channel_data_notch(:,i));
    subplot(3, active_channels,active_channels + j)
    plot(freq, channel_data_fft(:,i))
    title(strcat('Single-Sided Amplitude Spectrum of CH', int2str(i)))
    xlabel('f (Hz)')
    ylabel('|channel_data_fft1(f)|')
    xlim([0 20])
    j=j+1;
end
end