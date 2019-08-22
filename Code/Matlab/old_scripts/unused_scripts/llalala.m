FigH = figure('Color', [1, 1, 1]);
WindowAPI(FigH, 'Maximize');
% Full screen AXES object with a sphere:
AxesH = axes('Units', 'normalized','Position', [0 0 1 1], 'Visible', 'off');
WindowAPI(FigH, 'Alpha', 0.8, uint8([255, 255, 255]));
% Fix the axis limits.
xlim([0 1])
ylim([0 1])
rectangle('Position', [0.9  0.9 0.01  0.02], 'EdgeColor', 'r', 'FaceColor','r')
pause(5);
hold on;
cla
rectangle('Position', [0.2  0.2 0.01  0.02], 'EdgeColor', 'r', 'FaceColor','r')
%viscircles([0.5 0.5],0.01)
% Now cut out the background: