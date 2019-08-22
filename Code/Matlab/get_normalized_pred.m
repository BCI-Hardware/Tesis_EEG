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

function [x_pred, y_pred] = get_normalized_pred(input, train_data_id)

w1 = csvread(strcat('..\..\Pytorch\output\w1_', train_data_id, '.txt'));
w2 = csvread(strcat('..\..\Pytorch\output\w2_', train_data_id, '.txt'));

bias1 = csvread(strcat('..\..\Pytorch\output\bias1_', train_data_id, '.txt'));
bias2 = csvread(strcat('..\..\Pytorch\output\bias2_', train_data_id, '.txt'));

% Apply the input pattern to the first layer.
v0 = input;

% Propagate the input signal thrwough the network.
% m = 1
h_1 = v0 * w1'  + bias1';
v_1 = poslin(h_1); % poslin=h_relu

% m = 2
h_2 = v_1 * w2'  + bias2';
v_2 = poslin(h_2); % poslin=h_relu

x_pred = v_2(1);
y_pred = v_2(2); 
end