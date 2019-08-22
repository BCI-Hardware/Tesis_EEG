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
%       - Filters (LP, HP & Notch) and plots per channel data.
%       - Removes outliers HF peaks mostly due to blink artifacts)
%       - Splits each channel data to chunks, and processes it, based on the nn input type:
%
%             - Type 1: one input pair (x,y) per output pair (x,y). Each
%                       output appears a single time on the vector.
%                       The input value on each direction is computed by
%                       averaging all samples for the same window.
%
%             - Type 2: N input pairs per output pair (x,y). Each
%                       output appears a single time on the vector.
%                       The first valid* N** samples per window on each
%                       direction are captured.
%                       * Note that samples on the borders of each window
%                       are removed to keep only the parts where the signal
%                       stabilizes.
%                       ** This value is defined as the minimum number of
%                       valid samples within all windows for both
%                       directions. It must be a single value, equal for
%                       both.
%
%             - Type 3: The complete eeg signal, only with borders
%                       between windows cropped is used as input to the nn.
%                       There is an output pair per input signal, each of
%                       them matching the corresponding dot position that
%                       an input is responding to.
%
%       - [OPTIONAL] Plots output data from all the steps described above.
%       - [OPTIONAL] Saves input and output pairs to files under the
%         pytorch /input_data directory.
%       3rd block
%       - Reads weight matrices w1 and w2 from the nn output and computes
%         predicted output. It also plots real vs predicted output for both
%         directions and computes MSE.
%       4th block
%       - Gets predicted output directly from the nn and plots it against
%         real output. It also computes MSE.
%**************************************************************************

% close all;
clear all;

data_date = '21_08_2019_19_11_30';
network_input_type = 1;

input_data_file_name = strcat('data\', data_date, '.txt');
ts_and_dot_data_file = strcat('data\', data_date, '.mat');

srate = 250;
%% PRE-PROCESSING
save_data_to_file = false;
activation_relu = true;
should_plot = true;
plot_hist = false;

[real_channel_data, clean_channel_data] = preprocess_data(input_data_file_name, ts_and_dot_data_file, should_plot);

% Prepare data by removing windows transitions and creating the output
% training vector
[train_input, train_output] = window_data(clean_channel_data, ts_and_dot_data_file, network_input_type);

% Normalize input and output
normalized_input = normalize_data(train_input, activation_relu);
if activation_relu
    normalized_output = train_output;
else
    normalized_output = 2 * train_output - 1;
end

% Save training data to files
if save_data_to_file
    csvwrite(strcat('..\..\Pytorch\input_data\input_type2_', data_date,'.txt'),normalized_input);
    csvwrite(strcat('..\..\Pytorch\input_data\output_type2_', data_date,'.txt'),normalized_output);
end

%% POST TF - Plot data to compare real vs prediction
normalized_input = csvread(strcat('..\..\Pytorch\input_data\input_type2_', data_date,'.txt'));
normalized_output = csvread(strcat('..\..\Pytorch\input_data\output_type2_', data_date,'.txt'));

pred_data_id = '02_05_2019_22_49_08_N10_10000_0.0001';
w1 = csvread(strcat('..\..\Pytorch\output\w1_', pred_data_id, '.txt'));
w2 = csvread(strcat('..\..\Pytorch\output\w2_', pred_data_id,'.txt'));

bias1 = csvread(strcat('..\..\Pytorch\output\bias1_', pred_data_id,'.txt'))';
bias2 = csvread(strcat('..\..\Pytorch\output\bias2_', pred_data_id,'.txt'))';

train_indices = csvread(strcat('..\..\Pytorch\output\train_indices_', pred_data_id,'.txt')) + 1;
test_indices = csvread(strcat('..\..\Pytorch\output\test_indices_', pred_data_id,'.txt')) + 1;

[error_x_train, error_y_train, error_x_test, error_y_test, corr_x, corr_y] = get_perceptron_output(w1, w2, bias1, bias2, normalized_input, normalized_output, train_indices, test_indices);
