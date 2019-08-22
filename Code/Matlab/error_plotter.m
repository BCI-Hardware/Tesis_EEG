close all;
clear all;

x_train_avg = [];
x_train_std = [];
y_train_avg = [];
y_train_std = [];
x_test_avg = [];
x_test_std = [];
y_test_avg = [];
y_test_std = [];

train_avg = [];
train_std = [];
test_avg = [];
test_std = [];
    
for i=2:2:10
    errors_file = strcat('data\', '02_05_2019_22_49_08_N', num2str(i), '_10000_0.001.mat');

    accum_errors = load(errors_file);
    x_train_error = accum_errors.x_train_error;
    y_train_error = accum_errors.y_train_error;
    x_test_error = accum_errors.x_test_error;
    y_test_error = accum_errors.y_test_error;
    
    x_train_avg = [x_train_avg mean(x_train_error(1:10))];
    x_train_std = [x_train_std std(x_train_error(1:10))];
    y_train_avg = [y_train_avg mean(y_train_error(1:10))];
    y_train_std = [y_train_std std(y_train_error(1:10))];
    x_test_avg = [x_test_avg mean(x_test_error(1:10))];
    x_test_std = [x_test_std std(x_test_error(1:10))];
    y_test_avg = [y_test_avg mean(y_test_error(1:10))];
    y_test_std = [y_test_std std(y_test_error(1:10))];
    
    train_avg = [train_avg mean([x_train_error(1:10) y_train_error(1:10)])];
    train_std = [train_std std([x_train_error(1:10) y_train_error(1:10)])];
    test_avg = [test_avg mean([x_test_error(1:10) y_test_error(1:10)])];
    test_std = [test_std std([x_test_error(1:10) y_test_error(1:10)])];
end

figure
errorbar(x_train_avg, x_train_std)
hold on
errorbar(x_test_avg, x_test_std)
title('X - c=1e-3')
legend( 'TRAIN', 'TEST','Location', 'northeastoutside');
grid on;

figure
errorbar(train_avg, train_std)
hold on
errorbar(y_test_avg, y_test_std)
title('Y - c=1e-4')
legend( 'TRAIN', 'TEST','Location', 'northeastoutside');
grid on;

figure
errorbar(train_avg, train_std)
hold on
errorbar(test_avg, test_std)
title('X&Y - c=1e-4')
legend( 'TRAIN', 'TEST','Location', 'northeastoutside');
grid on;

