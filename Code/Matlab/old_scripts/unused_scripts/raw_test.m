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
close all
clear all
data_date = '19_06_2019_00_48_39';

input_data_file_name = strcat('data\', data_date, '.txt');
ts_and_dot_data_file = strcat('data\', data_date, '.mat');

load(ts_and_dot_data_file);

active_channels = 2;
arduino_gain = 24;
srate = 250;
should_plot = false;

[channel_data, filtered_channel_data] = preprocess_data(input_data_file_name, ts_and_dot_data_file, should_plot);

figure
plot(channel_data(:,1));

lowered_channel_data = channel_data(1:3e4,1) - channel_data(1,1);
figure
plot(lowered_channel_data);

% Notch filter at 50 Hz
wo=50/(250/2);bw=wo/5;
[bn,an]=iirnotch(wo,bw);

fc_hp=0.005/(250/2);
[b_hp,a_hp]= butter(2,fc_hp,'high');

fc_lp=30/(250/2);
[b_lp,a_lp]= fir1(20,fc_lp,'low');

% Low pass filter to remove high frequency noise
channel_data_lp = filter(b_lp, a_lp, lowered_channel_data);

figure
plot(channel_data_lp);

% % High pass filter to remove DC
channel_data_hp = filter(b_hp, a_hp, channel_data_lp);

figure
plot(channel_data_hp);