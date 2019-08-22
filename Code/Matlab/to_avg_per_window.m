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

function [split_chan_mean, stimuli_pos]=to_avg_per_window(channel, ts_file)

active_channels = size(channel, 2);
j=1;

% Get stimuli timestamps (in seconds)
stimuli_data = load(ts_file);
ts = get_stimuli_ts(stimuli_data.stimuli_position);
ts(1)
stimuli_size = size(ts,1);
ts(stimuli_size + 1) = ts(stimuli_size) + 14;

for i=1:active_channels  
    % Now overlap timestamps
    for j=1:stimuli_size
        samples_1 = round(250 * ts(j) + 1);
        samples_2 = round(250 * ts(j+1));
        split_chan_mean(j,i) = mean(channel(samples_1:samples_2, i));
        split_chan_raw{i, j, :} = channel(samples_1:samples_2, i);
    end   
        
    stimuli_pos(:, i) = stimuli_data.stimuli_position(1:size(split_chan_mean, 1), i);
end
end