% ts_file = 'data/02_05_2019_22_49_08_up.mat';
% stimuli_data = load(ts_file);
% stimuli_position = stimuli_data.stimuli_position
% stimuli_position(93,3) = stimuli_position(1, 3) + ((stimuli_position(93,3) - stimuli_position(1, 3)).*86400 - 1.9)/86400
% save('data/02_05_2019_22_49_08_up.mat', 'stimuli_position')