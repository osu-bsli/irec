import csv

ms5607_pressure_mbar = []
adxl375_accel_z_mps2_fc_frame = []

with open("test-flight-4-12-2025_flight-only.csv", newline='') as csvfile:
    reader = csv.DictReader(csvfile)  # uses header row as keys
    for row in reader:
        ms5607_pressure_mbar.append(row["ms5607_pressure_mbar"])
        adxl375_accel_z_mps2_fc_frame.append(row["adxl375_accel_z_mps2_fc_frame"])

# print(altitude_data)

def write_array_to_file(array_type, name, array):
    f.write(f"const static {array_type} {name}[] = " + "{\n")
    for d in array:
        f.write(f"    {d},\n")
    f.write("};\n\n")

n = 0
with open("main/data_array.h", "w") as f:
    f.write(f"#define DATA_LEN {len(ms5607_pressure_mbar)}\n")
    write_array_to_file("float", "ms5607_pressure_mbar", ms5607_pressure_mbar)
    write_array_to_file("float", "adxl375_accel_z_mps2_fc_frame", adxl375_accel_z_mps2_fc_frame)
