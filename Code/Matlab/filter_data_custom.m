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

function channel_data_notch = filter_data(channel, srate)

active_channels = size(channel, 2);

MIN_EEG_FILT = 57000;
% First add elements to the vectors to use EEG filt (minimum supported
% is 25000)
initial_length = size(channel,1);
if size(channel,1) < MIN_EEG_FILT
    channel = [channel; zeros(MIN_EEG_FILT - size(channel,1), active_channels)];
end

% Notch filter at 50 Hz
wo=50/(250/2);bw=wo/5;
[bn,an]=iirnotch(wo,bw);

fc_hp=0.05/(250/2);
[b_hp,a_hp]= fir1(4000,fc_hp,'high');

for i=1:active_channels   
    % Alpha Test filters
    freq_low=0.01;
    freq_high=12;
    
    % High pass filter to remove DC
    channel_data_hp(:,i) = filter(b_hp, a_hp, channel(:, i));
    %Low pass filter to remove high frequency noise
    %channel_data_lp(:,i) = detrend(channel_data_hp(i,:));
    channel_data_lp(:,i) = eegfilt(channel_data_hp(:,i)', srate, 0, freq_high)';
    
    % Notch filter at 50 Hz
    channel_data_notch(:,i) = filter(bn, an, channel_data_lp(:, i));
end

channel_data_notch = channel_data_notch(1:initial_length, :);

end