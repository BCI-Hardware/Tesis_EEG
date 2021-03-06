%**************************************************************************
%                            TESIS DE GRADO
%                               EEG v1.0
%                   Instituto de Ingenieria Biom�dica
%           Facultad de Ingenieria, Universidad de Buenos Aires
%
%                           Florencia Grosso
%                           Tutor: Sergio Lew
%
%  Code description:
%  This function trains a multilayer perceptron with the 
%**************************************************************************

function [error_x, error_y] = test_perceptron_output(prediction, real_output)
%% Grafico las se�ales (output real vs estimado por la red)

N1 = 35;
N2 = 2;

% pred = [[-0.5881739  -0.09830949]
%  [ 0.8680297  -0.30890203]
%  [-1.         -0.54433125]
%  [-0.15271513 -0.50023836]
%  [-0.60059446  0.654467  ]
%  [ 0.37361678  0.8387032 ]
%  [ 0.10275494  0.4402696 ]
%  [-1.          0.14973316]
%  [ 0.6564819  -0.82894194]
%  [ 0.6056838   0.49158582]
%  [-0.21428932  0.06480136]
%  [ 0.49639708 -0.18223526]
%  [-0.44943315 -0.3951591 ]
%  [ 0.24902365  0.53283215]
%  [-0.41563654 -0.43858126]
%  [ 0.66505235  0.22429694]
%  [ 0.67818654 -0.6834938 ]
%  [ 0.47928864  0.30196062]
%  [-0.51543474 -0.09169735]
%  [-0.19744204  0.36032367]
%  [ 0.55200315 -0.8320054 ]
%  [ 0.30624345  0.49435362]
%  [-0.33141547 -0.37461045]
%  [-0.29134682  0.09297289]
%  [ 0.48597768  0.38035494]
%  [-0.41367495 -0.4423262 ]
%  [ 0.82235694  0.1409174 ]];

% pred = [[-0.51191396 -0.03595471]
%  [ 0.8586602  -0.4137113 ]
%  [-0.6546464  -0.3793279 ]
%  [-0.07018025 -0.2385219 ]
%  [-0.43783808  0.25019646]
%  [ 0.36319196  0.7577651 ]
%  [ 0.23551895  0.60173   ]
%  [-0.89327717  0.1769853 ]
%  [ 0.6811497  -0.6532301 ]
%  [ 0.56443596  0.3712076 ]
%  [-0.16402198  0.24039473]
%  [ 0.21218422 -0.31221437]
%  [-0.4100258  -0.42073247]
%  [ 0.09360345  0.68533266]
%  [-0.48494792 -0.38048688]
%  [ 0.4712703   0.49676117]
%  [ 0.7244655  -0.5082505 ]
%  [ 0.49324363  0.44814473]
%  [-0.6283735   0.19477749]
%  [-0.12056781  0.4634764 ]
%  [ 0.5411662  -0.9985858 ]
%  [ 0.21124847  0.54559577]
%  [-0.37807438 -0.52449536]
%  [-0.18994427  0.16873392]
%  [ 0.4442943   0.24894403]
%  [-0.4976826  -0.3692498 ]
%  [ 0.839126    0.07371002]];

% pred = [[-0.45066023 -0.2708249 ]
%  [ 0.99134535 -0.3269632 ]
%  [-0.5982031  -0.49792632]
%  [-0.16896531 -0.40815657]
%  [-0.37769422  0.41616184]
%  [ 0.2535164   0.9968165 ]
%  [ 0.01830612  0.59898245]
%  [-0.9154036   0.16940396]
%  [ 0.6295053  -0.7998879 ]
%  [ 0.7013259   0.68499804]
%  [-0.10011733  0.00667753]
%  [ 0.42028853 -0.44066048]
%  [-0.462612   -0.37299627]
%  [-0.02051209  0.5486363 ]
%  [-0.56705666 -0.29337022]
%  [ 0.52548045  0.3799209 ]
%  [ 0.67490697 -0.5958596 ]
%  [ 0.61983943  0.2590813 ]
%  [-0.6216581   0.04248349]
%  [-0.26106504  0.49494106]
%  [ 0.5525251  -0.9182015 ]
%  [ 0.28759444  0.53785694]
%  [-0.5268969  -0.2152827 ]
%  [-0.13490005  0.07450766]
%  [ 0.5626026   0.4572515 ]
%  [-0.5776565  -0.29170808]
%  [ 0.691363    0.13459058]];

pred = prediction;

size(pred, 1)
size(real_output, 1)
figure
plot(1:size(pred, 1), pred(:, 1), '-*');
hold on
plot(1:size(real_output, 1), real_output(:,1), '-+');
title('X')
legend('Network output', 'Real output','Location', 'northeastoutside');
grid on;

figure
plot(1:size(pred, 1), pred(:, 2), '-*');
hold on
plot(1:size(real_output, 1), real_output(:,2), '-+');
title('Y')
legend('Network output', 'Real output','Location', 'northeastoutside');
grid on;

% % Compute accuracy (MSE)
error_x = immse(real_output(:,1), pred(:, 1));
error_y = immse(real_output(:,2), pred(:, 2));
end

