opts = detectImportOptions('nomad_test_flight_2026-4-11_flight_only.csv');
opts.SelectedVariableNames = ["time_boot_ms", "adxl375_accel_z"];
A = readtable('nomad_test_flight_2026-4-11_flight_only.csv', opts);

time_boot_s = A.time_boot_ms / 1000;
min_val = 690;
max_val = 700;
mask = (time_boot_s >= min_val) & (time_boot_s <= max_val);
filtered = lowpass(A.adxl375_accel_z, 0.1);
plot(time_boot_s(mask), filtered(mask));