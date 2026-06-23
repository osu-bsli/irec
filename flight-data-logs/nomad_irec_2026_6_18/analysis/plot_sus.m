data = readmatrix("2026-06-17 Nomad IREC SRAD Cropped.logv3.csv");
tiledlayout(6, 1);

ax1 = nexttile;

x = (data(:, 5) - data(1, 5))/1000;

hold on;
plot(x, data(:,8));
plot(x, data(:,9));
plot(x, data(:,10));
title("bmi323 acceleration")
legend("X, m/s^2", "Y, m/s^2", "Z, m/s^2")
hold off;

ax2 = nexttile;

hold on;
plot(x, data(:,11));
plot(x, data(:,12));
plot(x, data(:,13));
legend("X, deg/s", "Y, deg/s", "Z, deg/s")
title("bmi323 gyroscope")

ax3 = nexttile;

hold on;
plot(x, data(:,22));
legend("Meters")
title("gps altitude")

ax4 = nexttile;

hold on;
plot(x, data(:,20));
title("gps lng")

ax5 = nexttile;

hold on;
plot(x, data(:,6));
title("SRAD baro")

ax6 = nexttile;



data = readmatrix("2026-06-17 Nomad IREC EasyMini Poland.csv");

easymini_x = (data(:, 4) - data(1, 4));

hold on;
plot(easymini_x, data(:,8));
title("EasyMini baro, Poland")


linkaxes([ax1 ax2 ax3 ax4 ax5], "x")