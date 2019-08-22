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

function [train_input, train_output] = to_N_samples_per_window(channel, ts_file)

% Get stimuli timestamps (in seconds)
stimuli_data = load(ts_file);
ts = get_stimuli_ts(stimuli_data.stimuli_position);
dots = stimuli_data.stimuli_position;
stimuli_size = size(ts,1);
ts(stimuli_size + 1) = ts(stimuli_size) + 14;

j=1;
samples_per_window = [];
lower_index = [];

for j=1:stimuli_size
    samples_1 = round(250 * ts(j) + 1) + 100;
    samples_2 = round(250 * ts(j+1)) - 100;
    
    samples_per_window = [samples_per_window samples_2-samples_1];
    lower_index = [lower_index samples_1];
end

% window_width = min(samples_per_window);

window_width = 250;
    
for j=1:stimuli_size
    x0 = lower_index(j);
    train_input_x(j, :) = channel(x0:x0+window_width-1, 1) ;
    train_input_y(j, :) = channel(x0:x0+window_width-1, 2);
end

train_input = [train_input_x train_input_y];
train_output = stimuli_data.stimuli_position(:, 1:2);
end