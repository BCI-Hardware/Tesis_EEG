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
%  This code takes EEG channel data and stimuli a stimuli data file, and
%  plots them together. On each stimulus occurence, a vertical line is
%  placed over the EEG channel data to mark these events.
%
%  Based on this, data for each channel is split in chunks, where each of
%  them corresponds to the region between stimuli.
%
%  The return values are:
%  - split_chan_raw: an MxN cell (M= #active channels, N=#of chunks). Each
%    cell element contains a vector with the channel data within the
%    region.
%  - split_chan_mean: an NxM matrix, where each ij element is the average
%    of the values for region j in channel i. (i=1..N, j=1..M).
%  - stimuli_pos: an NxM matrix, where the column 1 is the stimuli position
%    in x and column 2 in y.
%**************************************************************************

function plot_data_and_stimuli(channel, ts_file, srate)

active_channels = size(channel, 2);

time=0:1/srate:length(channel)/srate - 1/srate;

% Draw figure to place the graphs
figure
hold on
j=1;

% Get stimuli timestamps (in seconds)
stimuli_data = load(ts_file);
ts = get_stimuli_ts(stimuli_data.stimuli_position);
stimuli_size = size(ts,1);

for i=1:active_channels
    
    % Plot channel eeg_data (filtered)
    subplot(2,1,i)
    plot(time, channel(:,i))
    title(strcat('Filtered CH', int2str(i)))
    xlabel('Time [s]')
    ylabel('Amplitude [\muV]')
    
    % Now overlap timestamps
    hold on
    for j=1:stimuli_size
        SP=ts(j);
        x=[SP,SP];
        y=[-500,500];
        plot(x,y);
        hold on;
    end
end
end