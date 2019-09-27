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

function channel_data_lp = filter_live_data(channel, srate)

active_channels = size(channel, 2);

% Butterworth filter, second order, high pass
fc_lp=10/(250/2);
[b_lp,a_lp]=butter(1,fc_lp);

fc_hp=5/(250/2);
[b_hp,a_hp]=butter(1,fc_hp,'high');

% Notch filter at 50 Hz
w1=50/(srate/2);bw=w1/5;
[bn,an]=iirnotch(w1,bw);

for i=1:active_channels        
%     % High pass filter to remove DC
    channel_data_hp(:,i) = filter(b_hp, a_hp, channel(:, i));
%     % Low pass filter to remove high frequencies + line noise (50Hz)
    channel_data_lp(:,i) = filter(b_lp, a_lp, channel_data_hp(:, i));
end
end