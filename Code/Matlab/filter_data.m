%**************************************************************************
%                            TESIS DE GRADO
%                               EEG v1.0
%                   Instituto de Ingenieria Biomédica
%           Facultad de Ingenieria, Universidad de Buenos Aires
%
%               Brian Daniel Santillan, Florencia Grosso.
%                           Tutor: Sergio Lew
%
%  Code description:
%  This code takes input data and applies a low pass and a high pass
%  filter, and a notch filter to remove 50Hz noise.
%  It returns a matrix with the same dimensions of channel.
%**************************************************************************

function channel_data_BP = filter_data(channel, srate)

active_channels = size(channel, 2);
 
for i=1:active_channels  
    
    % Alpha Test filters
    freq_low=5;
    freq_high=12; 
        
    % Low pass filter to remove high frequency noise        
    channel_data_BP(:,i) = eegfilt(channel(:,i)', srate, freq_low, freq_high)';
end
end