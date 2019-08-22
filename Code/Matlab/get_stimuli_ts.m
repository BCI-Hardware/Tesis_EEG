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
%  This code reads EEG eeg_data from a file and separates it according to
%  the number of active channels.
%**************************************************************************
function stimuli_rel_ts = get_stimuli_ts(stimuli_data)
stimuli_abs_ts = stimuli_data(:, 3);
stimuli_rel_ts = (stimuli_abs_ts - stimuli_data(1, 3)).*86400 + 0.48; 
end

% NOTES
% Offset for different data
% 09_09_2018_19_30_28 -> 0.44
% 02_05_2019_22_49_08 -> 3.65
% 19_06_2019_00_48_39 -> 0.48
