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
%  This is the main block for data analysis. It performs the following
%  operations:
%       - Loads recorded EEG data and stimuli position + ts.
%       - Splits channel data according to n° of active channels.
%       - Filters (LP, HP & Notch) and plots per channel data.
%       - Removes outliers HF peaks mostly due to blink artifacts)
%       - Splits each channel data to chunks, limited by stimuli.
%       - Computes the average of each chunk.
%       - Feeds the averaged data and the stimuli positions matrix to a
%         multiple layer perceptron.
%**************************************************************************

function [no_outliers_data] = preprocess_data(input_data_file_name, ts_and_dot_data_file, should_plot)

clear all;
close all;

active_channels = 2;
arduino_gain = 24;
srate = 250;

channel_data = split_channels(input_data_file_name, active_channels, arduino_gain);

% NOTE!!!
% Temporary hack to invert channels and have x on chan 1 and y on chan 2
channel_data(:,[1,2])=channel_data(:,[2,1]);

% Apply a band pass filter to the data
filtered_channel_data = filter_data(channel_data, srate);
if should_plot
    plot_filtered_data(channel_data, filtered_channel_data, srate);
end

% Remove outliers (peaks) from channel data
no_outliers_data = fill_outliers_auto(filtered_channel_data, srate);

% Plot data and stimuli
if should_plot
    plot_data_and_stimuli(no_outliers_data, ts_and_dot_data_file, srate);
end

end