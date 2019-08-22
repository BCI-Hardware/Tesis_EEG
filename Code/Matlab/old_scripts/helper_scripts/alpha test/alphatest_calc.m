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
%  Splits the data received in two arrays, each containing data for
%  different sequences of the alpha test:
%       1) Closed eyes
%       2) Opened ayes
%**************************************************************************
function [openedeyes_resized, closedeyes_resized] = alphatest_calc(data,sr)
time = 5; %time in sec opened/closed eyes
iteration = length(data)/(2*time*sr); % cantidad de veces que hice cada abrir o cerrar de ojos
time_samples = time*sr; % ancho de ventana
window_start = sr + 1; % muestras descartadas

for j = 1:iteration
    for i = 1:time_samples
        openedeyes(j,i) = data(i+time_samples*2*(j-1));
        closedeyes(j,i) = data(i+time_samples*(2*j-1));
    end
    
    openedeyes_resized(j,:) = openedeyes(j, window_start:end);
    closedeyes_resized(j,:) = closedeyes(j, window_start:end);
end
end

