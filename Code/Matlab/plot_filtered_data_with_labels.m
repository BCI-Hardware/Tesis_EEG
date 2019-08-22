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

function plot_filtered_data_with_labels(raw_data, filtered_data, ts_and_dot_data_file, srate)

stimuli_data = load(ts_and_dot_data_file);
ts = get_stimuli_ts(stimuli_data.stimuli_position);
x = stimuli_data.stimuli_position(:,1);
y = stimuli_data.stimuli_position(:,2);

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
    
    text(ts + 0.5,filtered_data(int64((ts + 0.5) * srate),i)' + 25, num2str(stimuli_data.stimuli_position(:,i),'%.2f'),'VerticalAlignment','bottom', 'FontSize', 8);
        
%     figure
%     scatter(1:size(filtered_data(:,i)), filtered_data(:,i))
end
end