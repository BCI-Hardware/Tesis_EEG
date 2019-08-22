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
%  This code takes input data and removes outliers. This is done
%  automatically by computing the second derivative of the signal and
%  detecting the peaks which are higher than a configured thresold, which
%  will define the spikes to remove.
%  
%  In order to preserve the signal information as much as possible, the
%  width of the peak is calculated and that is used to define how many
%  points will be removed. These are replaced in the following way:
%  
%     SIGNAL WITH OUTLIER (*)               SIGNAL WITH OUTLIER FILLED
%
%               *
%              / \                                     (2)
%             /   \_ _ _                            _ _ _ _ _
%            /                  ====>              |
%           /                                      |  
%       _ _/                              _ _ _ _ _|
%                                            (1)
%
%  (1) Avg of the signal before peak - width/2
%  (2) Avg of the signal after peak + width/2
%
%  Note that each channel may use a different threshold to detect for
%  peak detection.
%
%  If the should_plot flag is set to true, then the different steps of the
%  process are plotted. 
%**************************************************************************

function cropped_data = fill_outliers_auto(channel, srate, should_plot)
%% Find peaks
active_channels = size(channel, 2);

fs = 1/srate;
time=0:fs:length(channel)*fs - fs;
N_samples = length(channel);

pks_max_thr_all = [0.53, 0.43]; %[0.53, 0.43]
clean_data = [];

for k=1:active_channels
    
    data = channel(:,k);
    pks_max_thr = pks_max_thr_all(k);
    
    % Compute the second derivative of the signal
    d2 = abs(diff(data(2:end))-diff(data(1:end-1)));
    
    % Keep only the values above a certain thresold
    % NOTE: since the second derivative inverts the sign, then positive
    % maxima need to be found checking negative peaks and viceversa.
    idxs = find(d2>pks_max_thr);
    
    % Generate a vector with the same length as each input channel, which
    % has 0 in all values except the ones that satisfied the threshold.
    d2_cut = zeros(N_samples, 1);
    d2_cut(idxs) = d2(idxs);
    
    % Since a wide overshoot might be composed of multiple values which
    % passed the threshold, we need to filter out the highest point from it
    [pks, locs, w] = findpeaks(d2_cut);
    peaks = [locs, pks];
    peaks_width = w;
    
    % Get peak's coordinates referred to the channel's data
    %         peaks_x =  fs * (peaks(:, 1) -1);
    %         peaks_y = data(peaks(:, 1));
    
    if should_plot == true
        figure
        subplot(2, 1, 1);
        plot(find(d2>pks_max_thr),d2(find(d2>pks_max_thr))); hold on
        plot(peaks(:, 1), peaks(:, 2), 'ko','MarkerFaceColor','r');
        title(strcat('CH',int2str(k),': 2nd derivative peaks detection'));
        
        subplot(2, 1, 2);
        plot(data);hold on
        plot(peaks(:, 1), data(peaks(:, 1)),'ko','MarkerFaceColor','r');
        title(strcat('CH',int2str(k),': Peaks detected on samples'));
    end
    
    data_cp = data;
    % Now cut off the peaks
    for i=1:length(peaks)
        pk = peaks(i, 1);
        width_2 = round(w(i)) * 8;
        
        x_1 = pk-width_2;
        x_2 = pk+width_2;
        x_0 = x_1-20;
        x_3 = x_2+20;
        
        if x_0 < 1; x_0 = 1; end
        
        if x_1 < 1; continue; end
        
        if x_2 > N_samples; continue; end
        
        if x_3 > N_samples; x_3=N_samples; end
        
        left_fill = mean(data_cp(x_0:x_1));
        right_fill = mean(data_cp(x_2:x_3));
        
        data_cp(x_1:pk-1) = left_fill;
        data_cp(pk:x_2) = right_fill;
    end
    
    if should_plot == true
        figure
        plot(data);
        title('Before');
        figure
        plot(data_cp, 'r');
        if k == 2
            ylim([-200 700]);
        else
            ylim([-500 400]);
        end
        title('After');
        figure
        plot(data);
        hold on
        plot(data_cp, 'r');
        title('Before (blue) and After (red)');
    end
    
    % Save data into output matrix
    cropped_data(:, k) = data_cp;
end

end
