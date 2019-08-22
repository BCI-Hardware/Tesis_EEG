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
%  Splits the data 
%**************************************************************************
function [split_data] = signal_cut(data,sr,dots_to_remove)
window_time = 2; %time in sec window
iteration = length(data)/(window_time*sr); % cantidad de veces
time_samples = window_time*sr; % ancho de ventana en muestras
remove_dot = 2; %puntos iniciales a sacar

for j = 1:iteration
    for i = 1:time_samples
        split_data(j,i) = data(i+time_samples*(j-1));
    end
end

%% Saco los primeros puntos
for j = 1:iteration-remove_dot
    split_data(j,:) = split_data(j+remove_dot, :);
end

%% Saco los puntos que quiero remover. El vector dots_to_remove me da cada uno que quiero sacar ej (5, 8, 9, 25)

dots_counter = 1;
for j = 1:size(split_data,1)
    while j = dots_to_remove(dots_counter)
            j = j+1;
            dots_counter = dots_counter+1;
    end
split_data(j-(dots_counter-1),:) = split_data(j,:);
end    


