%**************************************************************************
%                            TESIS DE GRADO
%                               EEG v1.0
%                   Instituto de Ingenieria Biomédica
%           Facultad de Ingenieria, Universidad de Buenos Aires
%
%                            Florencia Grosso
%                           Tutor: Sergio Lew
%
%  Code description:
%  This code reads EEG eeg_data from a file and separates it according to
%  the number of active channels. Returns an MxN matrix with splitted 
%  channel data, where M is the number of samples per channel and N the
%  number of active channels.
%
%  This also undoes arduino amplification and converts samples to uV.
%**************************************************************************
function channel_data = split_channels(eeg_data, active_channels, arduino_gain)

for i=1:active_channels
    amplified_eeg_data(:,i) = eeg_data(i:active_channels:end, 1);
    
    % Undo amplification and convert to uV
    channel_data(:,i) = amplified_eeg_data(:,i) * 1000 / arduino_gain;
end
end
