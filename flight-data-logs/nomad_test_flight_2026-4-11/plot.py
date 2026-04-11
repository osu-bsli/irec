import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
data = pd.read_csv("nomad_test_flight_2026-4-11_flight_only.csv")

fig, ax = plt.subplots()

x = np.array(data["time_boot_ms"]) / 1000

plt.axhline(y=0, color='r', linestyle='--', label='Zero Line') # Add horizontal line at y=0
# ax.plot(x, data["adxl375_accel_x"], label="adxl375_accel_x")
# ax.plot(x, data["adxl375_accel_y"], label="adxl375_accel_y")
# ax.plot(x, data["adxl375_accel_z"], label="adxl375_accel_z")
# ax.plot(x, data["bmi323_gyro_x"], label="bmi323_gyro_x")
# ax.plot(x, data["bmi323_gyro_y"], label="bmi323_gyro_y")
# ax.plot(x, data["bmi323_gyro_z"], label="bmi323_gyro_z")
# ax.plot(x, data["bm1422_magn_x"], label="bm1422_magn_x")
# ax.plot(x, data["bm1422_magn_y"], label="bm1422_magn_y")
# ax.plot(x, data["bm1422_magn_z"], label="bm1422_magn_z")
ax.plot(x, data["bmi323_accel_z"], label="bmi323_accel_z")

ax.legend()
plt.xlabel("Time (s)")
plt.show()