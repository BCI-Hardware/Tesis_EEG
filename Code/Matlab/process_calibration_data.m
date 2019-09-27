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

function [channel_data, sf] = process_calibration_data(cal_output, n)
active_channels = 2;
arduino_gain = 24;

file_id = fopen(cal_output,'r');
eeg_data = fscanf(file_id,'%f');
fclose(file_id);

noise_lim = [ 50 35 ];

channel_data = split_channels(eeg_data, active_channels, arduino_gain);

% Get amplitude of each eog stimuli by applying a manual filter to the raw
% signal (takes derivative using n preceding samples to the current one)
for i=1:active_channels
    s = channel_data(:,i);
    
    % Derivative of raw signal
    sd=s(n+1:end)-s(1:end-n);
    
    % Remove noise between deltas
    idxs = find(abs(sd)>noise_lim(i));
    sf(:,i) = zeros(length(sd), 1);
    sf(idxs, i) = sd(idxs);
end

% Remove first n samples, used to compute derivative only
channel_data = channel_data(n+1:end, :);
end