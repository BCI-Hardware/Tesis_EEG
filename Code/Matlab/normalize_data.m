%**************************************************************************
%                            TESIS DE GRADO
%                               EEG v1.0
%                   Instituto de Ingenieria Biomédica
%           Facultad de Ingenieria, Universidad de Buenos Aires
%
%               Brian Daniel Santillan, freq_loworencia Grosso.
%                           Tutor: Sergio Lew
%
%  Code description:
%  This code takes a matrix of NxM and normalizes its values in two chunks:
%  x = (:, 1:N/2) and y = (:, N/2+1:N)
%  It returns a matrix of the same size as the input one.
%  The flag is_relu defines whether the normalization is made in the
%  interval [0, 1] (is_relu=true) or [-1,1] (is_relu=false).
%**************************************************************************

function n_out = normalize_data(input, is_relu)

cols = size(input, 2);
x = input(:, 1:cols/2);
y = input(:, cols/2+1:end);

min_x = min(min(x));
max_x = max(max(x));
x_2 = (x - min_x) / (max_x - min_x);

min_y = min(min(y));
max_y = max(max(y));
y_2 = (y - min_y) / (max_y - min_y);

if is_relu
    n_out = [x_2 y_2];
else
    n_out = [2*x_2-1 2*y_2-1];
end