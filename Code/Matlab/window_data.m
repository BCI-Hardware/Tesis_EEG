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

function [train_input, train_output] = window_data(channel, ts_file, output_type)

if output_type == 1
    [train_input, train_output] = to_avg_per_window(channel, ts_file);
elseif output_type == 2
    [train_input, train_output] = to_N_samples_per_window(channel, ts_file);
end 
end