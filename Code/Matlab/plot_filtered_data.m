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
%  This code plots raw and filtered data for each channel, as well as the
%  FFT for each of them.
%**************************************************************************

function plot_filtered_data(raw_data, filtered_data, srate)

fs = 1/srate;
active_channels = size(raw_data, 2);

time=0:fs:length(raw_data)*fs - fs;

j=1;

for i=1:active_channels  
    figure
    plot(time, filtered_data(:,i))
    hold on
    title(strcat('Filtered CH', int2str(i)))
    xlabel('Time [s]')
    ylabel('Amplitude [\muV]')
    j = j + active_channels;
    
    txt = 'sin(\pi) = 0 \rightarrow';
    text(pi,sin(pi),txt,'HorizontalAlignment','right')
    
%     % Compute and plot channel FFT
%     [channel_data_fft(:,i) freq] = fft_custom(filtered_data(:,i));
%     subplot(3, active_channels, j)
%     plot(freq, channel_data_fft(:,i))
%     title(strcat('Single-Sided Amplitude Spectrum of CH', int2str(i)))
%     xlabel('f (Hz)')
%     ylabel('|channel_data_fft1(f)|')
%     xlim([0 20])
%     
%     hold on
end
end