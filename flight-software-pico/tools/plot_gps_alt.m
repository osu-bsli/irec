% Plot GPS altitude from flight log CSV
clear; clc; close all;

% Read CSV file
[file, path] = uigetfile('*.csv', 'Select flight log CSV');
if isequal(file, 0)
    return;
end

csv_path = fullfile(path, file);
data = readtable(csv_path);

% Extract and plot GPS altitude
if ismember('gps_alt', data.Properties.VariableNames)
    gps_alt = data.gps_alt;

    figure('Name', 'GPS Altitude', 'NumberTitle', 'off');
    plot(gps_alt, 'LineWidth', 1.5);
    grid on;
    xlabel('Sample');
    ylabel('GPS Altitude (m)');
    title('GPS Altitude vs Time');

else
    error('Column gps_alt not found in CSV');
end
