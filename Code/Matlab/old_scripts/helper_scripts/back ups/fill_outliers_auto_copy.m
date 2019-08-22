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
%  This code takes input data and removes outliers. The outliers to remove
%  are taken from .mat files, one per channel:
%
%    CH1: /data/+_ch1_outliers.mat
%    CH2: /data/+_ch2_outliers.mat
%
%  each of these workspaces contain a variable 'outliers' which is an MxN
%  matrix. M is the number of outliers to remove. Each row has the 
%  following data:
%
%  [x1 x2 y1 y2]
%
%  With:
%  - (x1, y1): point where the outlier begins.
%  - (x2, y2): point where the outlier ends.
%
%  The script removes the data between those points and then links them
%  through simple interpolation.
%  It returns a matrix with the filtered input data (no outliers).
%**************************************************************************

function channel = fill_outliers_auto(channel, srate)
%% Channel 1  
    
    fs = 1/srate;
    time=0:fs:length(channel)*fs - fs;
    
    N_samples = length(channel(:,2));
    N_windows = 100;
    window_size = N_samples/N_windows;
    
    d2 = diff(channel(2:end, 2))-diff(channel(1:end-1, 2));
    
    d2_cut = zeros(N_samples, 1);
    idxs = find(d2<-0.55);
    length(idxs)
    d2_cut(idxs) = d2(idxs);
    
    figure
    plot(find(d2<-0.55),d2(find(d2<-0.55)));
    
%     for i=1:N_samples
% %     figure
% %     plot(d2_cut);
% %     stem(find(d2<-0.55),d2(find(d2<-0.55)))
%        
%     figure
%     stem(d2_cut);
%     
    peaks = [];
    peaks_base = [];
    all_peaks = [];
    
    [pks, locs] = findpeaks(d2_cut);
    peaks = [locs, pks];
    disp 'peaks'
    size(peaks)
%     for i=1:N_windows
%         i_min= window_size *(i -1) + 1;
%         i_max= window_size * i;
%         data_chunk = d2_cut(i_min:i_max);
%         [pks, locs] = findpeaks(d2_cut, 'MinPeakDistance', 200);
%         
%         for j=1:length(pks)
%             peak_x = window_size * (i-1) + locs(j) + 1;
%             peak_y = pks(j);
%             all_peaks = [all_peaks, peak_x];
%             
%             if (peak_x - 5 < 1) || (peak_x + 5 > N_samples) 
%                 continue
%             end
%             
%             peaks = [peaks; [peak_x  peak_y]];
%         end
%     end
        
    size(peaks)
    peaks_x_2 =  fs * (peaks(:, 1) -1);
    peaks_y_2 = channel(peaks(:, 1), 2);
        
    figure
    plot(time,channel(:, 2));hold on
    plot(peaks_x_2,peaks_y_2,'ko','MarkerFaceColor','r');
    
    figure
    plot(channel(:, 2));
     
%     for j=1:size(outliers,1)
%         coefficients = polyfit([outliers(j,1), outliers(j,2)], [outliers(j,3), outliers(j,4)], 1);
%         a = coefficients (1);
%         b = coefficients (2);
%         
%         for n=round(outliers(j,1)*250):1:round(outliers(j,2)*250)
%             channel(n, 1) = a * (n/250) + b;
%         end
%     end
% %% Channel 2
%    outliers_data = load('data/09_09_2018_19_30_28_ch2_outliers.mat');
%    outliers = outliers_data.outliers;
%    
%    outliers = [[6, 6.496, 129.2, 84.15]; outliers];
%     
%     for j=1:size(outliers,1)
%         coefficients = polyfit([outliers(j,1), outliers(j,2)], [outliers(j,3), outliers(j,4)], 1);
%         a = coefficients (1);
%         b = coefficients (2);
%         
%         for n=round(outliers(j,1)*250):1:round(outliers(j,2)*250)
%             channel(n, 2) = a * (n/250) + b;
%         end
%     end
%    

end
