data = readmatrix("2026-06-17 Nomad IREC SRAD Cropped.logv3.csv");
tiledlayout(4, 1);

ax1 = nexttile;

hold on;
plot((data(:, 5) - data(1, 5))/1000, data(:,8));
plot((data(:, 5) - data(1, 5))/1000, data(:,9));
plot((data(:, 5) - data(1, 5))/1000, data(:,10));
title("bmi323 acceleration")
legend("X, m/s^2", "Y, m/s^2", "Z, m/s^2")
hold off;

ax2 = nexttile;

hold on;
plot((data(:, 5) - data(1, 5))/1000, data(:,11));
plot((data(:, 5) - data(1, 5))/1000, data(:,12));
plot((data(:, 5) - data(1, 5))/1000, data(:,13));
legend("X, deg/s", "Y, deg/s", "Z, deg/s")
title("bmi323 gyroscope")

ax3 = nexttile;

hold on;
plot((data(:, 5) - data(1, 5))/1000, data(:,22));
legend("Meters")
title("gps altitude")

ax4 = nexttile;

hold on;
plot((data(:, 5) - data(1, 5))/1000, data(:,20));
title("gps lng")