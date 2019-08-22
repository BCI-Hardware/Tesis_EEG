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
%  This function gets the perceptron's input for a perceptron with a single
%  hidden layer and the corresponding matrices of weights (w1: input to
%  hidden layer; w2: hidden to output) already calculated to compute the
%  predicted output. The real output (expected) is also received as an
%  input argument.
%  It returns the MSE between real and predicted values on each direction
%  (x, y).
%
%  Additionally, two graphs are obtained:
%  1) Network's ouput vs real output for X axis data.
%  2) Network's ouput vs real output for Y axis data. 
%**************************************************************************

function [error_x_train, error_y_train, error_x_test, error_y_test,corr_x, corr_y] = get_perceptron_output(w1, w2, bias1, bias2, input, real_output, train_indices, test_indices)
% Apply the input pattern to the first layer.
v0 = input;

% Propagate the input signal thrwough the network.
% m = 1
h_1 = v0 * w1';
h_1 = h_1 + repmat(bias1, size(h_1, 1), 1);
v_1 = poslin(h_1); % poslin=h_relu

% m = 2
h_2 =  v_1 * w2'; %+ bias2;
h_2 = h_2 + repmat(bias2, size(h_2, 1), 1);
v_2 = poslin(h_2); % poslin=h_relu

x_pred = v_2(:, 1);
y_pred = v_2(:, 2);

x_real = real_output(:, 1);
y_real = real_output(:, 2);

figure
plot(1:size(x_real, 1), x_real, '-*', 'color', [0.4660 0.6740 0.1880]);
hold on
plot(1:size(x_pred, 1), x_pred, '-+', 'color', [0.4940 0.1840 0.5560]);
hold on
plot(test_indices, x_real(test_indices,:), 'r*');
hold on
plot(test_indices, x_pred(test_indices,:), 'r+');
title('X')
legend( 'Expected ouput - TRAIN', 'Prediction - TRAIN', 'Expected ouput - TEST', 'Prediction - TEST', 'Location', 'northeastoutside');
grid on;

figure
plot(1:size(y_real, 1), y_real, '-*', 'color', [0.4660 0.6740 0.1880]);
hold on
plot(1:size(y_pred, 1), y_pred, '-+', 'color', [0.4940 0.1840 0.5560]);
hold on
plot(test_indices, y_real(test_indices,:), 'r*');
hold on
plot(test_indices, y_pred(test_indices,:), 'r+');
title('Y')
legend( 'Expected ouput - TRAIN', 'Prediction - TRAIN', 'Expected ouput - TEST', 'Prediction - TEST', 'Location', 'northeastoutside');
grid on;

% % Compute accuracy (MSE)
error_x_train =immse(x_real(train_indices, :), x_pred(train_indices, :));
error_y_train =immse(y_real(train_indices, :), y_pred(train_indices, :));

error_x_test =immse(x_real(test_indices, :), x_pred(test_indices, :));
error_y_test =immse(y_real(test_indices, :), y_pred(test_indices, :));

corr_x = corr(x_real, x_pred);
corr_y = corr(y_real, y_pred);
end