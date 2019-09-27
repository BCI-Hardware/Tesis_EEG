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

function [channel_data, sf, peaks] = process_live_data(eeg_output, n, alpha, abs_peak_max)
active_channels = 2;
arduino_gain = 24;
channel_data = split_channels(eeg_output, active_channels, arduino_gain);

noise_lim = [ 50 50 ];

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
    
    peak1 = max(sf(:,i));
    peak2 = min(sf(:,i));
     
%     [peak1(i), idx_peak1(i)] = max(sf(:,i))
%     [peak2(i), idx_peak2(i)] = min(sf(:,i))
%     
    % SPECIAL CHECKS FOR CH2 (removal of blinks and interdependence with
    % CH1)
    if i == 2
%         % If the index of the peak is the same for both channels, then
%         % there might be influence of CH1 over CH2. We need to remove it.
%         if idx_peak1(1) == idx_peak1(2)
%             peak1 = sf(idx_peak1(1),2) - alpha * sf(idx_peak1(1),1);
%         end
%         if idx_peak2(1) == idx_peak2(2)
%             peak2 = sf(idx_peak2(1),2) - alpha * sf(idx_peak2(1),1);
%         end
        
        % Check if the + peak is higher than the highest expected value
        % (max excursion of vertical channel). If so, remove both + and -
        % peaks since it might be a blink.
        if peak1 > abs_peak_max
            disp 'PICOOO'
            disp(peak1)
            peak1 = 0;
            peak2 = 0;
        end
    end        

    peaks(i) = peak1 + peak2;
    
%     % NOTE: this might be different for each channel.
%     if abs(peaks(i)) < 70
%         peaks(i) = 0;
%     end
end

% Remove first n samples, used to compute derivative only
channel_data = channel_data(n+1:end, :);
end