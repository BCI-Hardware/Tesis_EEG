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
data_date = '21_08_2019_22_50_16';
network_input_type = 1;

input_data_file_name = strcat('data\', data_date, '.txt');
ts_and_dot_data_file = strcat('data\', data_date, '.mat');

srate = 250;
%% READ & PREDICT LOOP

file_id = fopen(input_data_file_name,'r');
eeg_data = fscanf(file_id,'%f');
fclose(file_id);

accum_peaks = [];
last_c = [];
last_peaks = [ 0 0 ];
% figure

pause(1);
first_iteration = true;

for i=1:500:length(eeg_data)-500
    % Read samples from serial port
    c = eeg_data(i:i+500-1);
    
    if first_iteration ~= true
        % Split channels, filter signal and remove outliers
        [raw_data, filtered_data, peaks] = process_live_data([last_c(end-99:end); c], 50);
        figure
        subplot(3, 1, 1);
        plot(raw_data(:,1));
        ylim([-10000 -8400]);
        subplot(3, 1, 2);
        plot(filtered_data(:,1));
        
        accum_peaks = [accum_peaks; peaks];
        current_pos = sum(accum_peaks);
        
        % NOTE: this is done only for CH1 for now
        x=[current_pos(1),current_pos(1)];
        y=[0,10];
        subplot(3, 1, 3);
        plot(x,y);
        xlim([-1000 1000])
        hold on;
        pause(1);
    
    else
        first_iteration = false;
    end
    
    last_c = c;
end

% Close file and port
% fclose(output_file_id);
fclose(serial_port);
delete(instrfindall);