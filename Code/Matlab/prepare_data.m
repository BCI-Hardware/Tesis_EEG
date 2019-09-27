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
%       1st Block
%       - Loads recorded EEG data and stimuli position + ts.
%       2nd Block
%       - Splits channel data according to n° of active channels.
%       - Filters (discrete, with derivative) and plots per channel data.
%       - Removes outliers (HF peaks mostly due to blink artifacts)
%
%       - [OPTIONAL] Plots output data from all the steps described above.
%       - [OPTIONAL] Saves input and output pairs to files under the
%         pytorch /input_data directory.
%**************************************************************************

%close all;
clear all;

data_date = '26_09_2019_21_09_46_test_ch1';
network_input_type = 1;

%07_09_2019_14_16_59
%07_09_2019_14_23_44

input_data_file_name = strcat('data\', data_date, '.txt');
ts_and_dot_data_file = strcat('data\', data_date, '.mat');

srate = 250;
%% PRE-PROCESSING
% Get both filtered (clean) channel data and real channel data (Nsamples x 2
% matrix with raw eeg data, one channel per column)
should_plot = true;

% [real_channel_data, clean_channel_data] = preprocess_data(input_data_file_name, ts_and_dot_data_file, should_plot);

file_id = fopen(input_data_file_name,'r');
eeg_data = fscanf(file_id,'%f');
fclose(file_id);

channel_data = split_channels(eeg_data, 2, 24);


% Get amplitude of each eog stimuli by applying a manual filter to the raw
% signal
% Take derivative using 50 preceding samples to the current one
n = 50;

% NOTE: This is a temporary test made on channel 1 only
s = channel_data(:,2);
% Derivative of raw signal
sd=s(n:end)-s(1:end-(n -1));

figure;plot(channel_data(:,1))

% Plot both signals together
figure;plot(s)
hold on
plot(sd  - 3250,'r')

% Plot both signals together
figure;plot(s)
figure
plot(sd,'r')