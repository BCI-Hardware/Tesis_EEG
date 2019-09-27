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
%  This code reads the data sent by the IC ADS1299 through an Arduino NANO.
%  It saves it in a txt file which will be passed then to a plotter
%  function.  
%**************************************************************************
close all

data_date = '21_08_2019_22_50_16';
network_input_type = 1;

input_data_file_name = strcat('data\', data_date, '.txt');
ts_and_dot_data_file = strcat('data\', data_date, '.mat');

srate = 250;
%% READ & PREDICT LOOP

file_id = fopen(input_data_file_name,'r');
eeg_data = fscanf(file_id,'%f');
fclose(file_id);
figure

% Split channels, filter signal and remove outliers
[raw_data, no_outliers_data, filtered_data, peaks] = process_live_data(eeg_data, 50);
subplot(3, 1, 1);
plot(raw_data(:,1));
ylim([-10000 -8400]);
subplot(3, 1, 2);
plot(no_outliers_data(:,1));
ylim([-10000 -8400]);
subplot(3, 1, 3);
plot(filtered_data(:,1));
