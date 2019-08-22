%**************************************************************************
%                            TESIS DE GRADO
%                               EEG v1.0
%                   Instituto de Ingenieria Biomédica
%           Facultad de Ingenieria, Universidad de Buenos Aires
%
%               Brian Daniel Santillan, freq_loworencia Grosso.
%                           Tutor: Sergio Lew
%
%  Code description:
%  This code takes EEG eeg_data which was obtained with an aplha test. It
%  computes the power of data for each channel and then splits it in chunks
%  of opened and closed eyes, according to the tested windows.
% 
%  This data is then plotted in regular graphs, and finally a bar plot is
%  made, showing the mean of all windows for one condtion and the other
%  condensed in two bars, with their respective SEM.
%**************************************************************************
function eog_test(input_file_name)
active_channels = size(channel_data, 2);

% Compute power of the signal to avoid negative values
for i=1:active_channels
    channel_data_filtered_power(:,i) = channel_data_notch(:,i) .* channel_data_notch(:,i);
end

[openedeyes, closedeyes] = alphatest_calc(channel_data_filtered_power(:,i),arduino_sampling_rate);

% Make 2 plots:
%       - Signal power for eyes opened windows
%       - Signal power for eyes closed windows
figure
subplot(2, 1, 1);
for i=1:size(openedeyes, 1)
plot(openedeyes(i,:));
hold on;
end
title('Eyes opened');
xlabel('Sample');
ylabel('Signal power [\muV^2]');

subplot(2, 1, 2);
for i=1:size(closedeyes, 1)
plot(closedeyes(i,:));
hold on;
end
title('Eyes closed');
xlabel('Sample');
ylabel('Signal power [\muV^2]');

% Compute mean value for each window (distinguish between opened and closed eyes data)
partial_mean_openedeyes = mean(openedeyes, 2);
partial_mean_closedeyes = mean(closedeyes, 2);

% Compute SEM for each condition
sem_openedeyes = std(partial_mean_openedeyes)/sqrt(9);
sem_closedeyes = std(partial_mean_closedeyes)/sqrt(9);

% Plot mean with SEM in a graph bar for each window
figure;
h = barwitherr([sem_openedeyes.*ones(size(partial_mean_openedeyes)) sem_closedeyes.*ones(size(partial_mean_closedeyes))], [partial_mean_openedeyes partial_mean_closedeyes]);
legend(h, ['opened eyes'; 'closed eyes']);
ylabel('Signal power [\muV^2]');
colormap spring;

% Compute coefficient
P = ranksum(partial_mean_openedeyes, partial_mean_closedeyes)

% Obtain total mean of all windows for each case (opened & closed)
total_mean_opened = mean(partial_mean_openedeyes);
total_mean_closed = mean(partial_mean_closedeyes);

% Plot total mean with SEM in a graph bar for each condition
figure;
g = barwitherr([[sem_openedeyes; 0] [sem_closedeyes; 0]], [[total_mean_opened; 0] [total_mean_closed; 0]]);
legend(g, ['opened eyes'; 'closed eyes']);
ylabel('Signal power [\muV^2]');
colormap spring;
end