"""
Simulates launch using telmetry data from summer 2022.

Uses data/flight_data_2.csv which you'll need to get from Peter.
"""
from datetime import datetime
import packetlib.packet as packet
import serial
import csv
import time
import ctypes as ct

if __name__ == '__main__':
    start_time = datetime.now()

    # Setup sender port.
    port = serial.Serial(
        port='COM1',
        # baudrate=9600,
        baudrate=1410065407,
        stopbits=serial.STOPBITS_ONE,
        parity=serial.PARITY_NONE,
        bytesize=serial.EIGHTBITS,
    )

    # _lib_path = '.\libpacket_shared.dll'
    # _lib = ct.CDLL(_lib_path)
    # _lib.write_altitude_packet.argtypes = [ct.POINTER(ct.c_ubyte*64), ct.c_float, ct.c_float, ct.c_float]
    # _lib.write_acceleration_packet.argtypes = [ct.POINTER(ct.c_ubyte), ct.c_float, ct.c_float, ct.c_float, ct.c_float]
    # _lib.write_gps_position_packet.argtypes = [ct.POINTER(ct.c_ubyte), ct.c_float, ct.c_float, ct.c_float]
    # _lib.write_board_voltage_packet.argtypes = [ct.POINTER(ct.c_ubyte), ct.c_float, ct.c_float, ct.c_float, ct.c_float, ct.c_float]
    # _lib.write_board_current_packet.argtypes = [ct.POINTER(ct.c_ubyte), ct.c_float, ct.c_float, ct.c_float, ct.c_float, ct.c_float]
    # _lib.write_battery_voltage_packet.argtypes = [ct.POINTER(ct.c_ubyte), ct.c_float, ct.c_float, ct.c_float, ct.c_float, ct.c_float]
    # _lib.write_magnetometer_packet.argtypes = [ct.POINTER(ct.c_ubyte), ct.c_float, ct.c_float, ct.c_float, ct.c_float]
    # _lib.write_gyroscope_packet.argtypes = [ct.POINTER(ct.c_ubyte), ct.c_float, ct.c_float, ct.c_float, ct.c_float]
    # _lib.write_gps_satellite_count_packet.argtypes = [ct.POINTER(ct.c_ubyte), ct.c_float, ct.c_int]
    # _lib.write_gps_ground_speed_packet.argtypes = [ct.POINTER(ct.c_ubyte), ct.c_float, ct.c_float]

    with open('data/flight_data_2.csv') as csv_file:
        reader = csv.DictReader(csv_file)
        for row in reader:
            timestamp: float = float(row['time'])

            port.write(packet.create_packet(
                packet.PACKET_TYPE_HIGH_G_ACCELEROMETER,
                timestamp,
                (
                    float(row['high_g_x']),
                    float(row['high_g_y']),
                    float(row['high_g_z']),
                )
            ))
            
            port.write(packet.create_packet(
                packet.PACKET_TYPE_GYROSCOPE,
                timestamp,
                (
                    float(row['bmx_x_gyro']),
                    float(row['bmx_y_gyro']),
                    float(row['bmx_z_gyro']),
                )
            ))
            
            port.write(packet.create_packet(
                packet.PACKET_TYPE_ACCELEROMETER,
                timestamp,
                (
                    float(row['bmx_x_accel']),
                    float(row['bmx_y_accel']),
                    float(row['bmx_z_accel']),
                )
            ))
            
            port.write(packet.create_packet(
                packet.PACKET_TYPE_ACCELEROMETER,
                timestamp,
                (
                    float(row['bmx_x_accel']),
                    float(row['bmx_y_accel']),
                    float(row['bmx_z_accel']),
                )
            ))

            port.write(packet.create_packet(
                packet.PACKET_TYPE_BAROMETER,
                timestamp,
                (
                    float(row['baro_height']),
                )
            ))
            
            port.write(packet.create_packet(
                packet.PACKET_TYPE_GPS,
                timestamp,
                (
                    float(row['gps_height']),
                    int(row['gps_satCount']),
                    float(row['gps_lat']),
                    float(row['gps_lon']),
                    float(row['gps_ascent']),
                    float(row['gps_groundSpeed']),
                )
            ))
            
            port.write(packet.create_packet(
                packet.PACKET_TYPE_TELEMETRUM,
                timestamp,
                (
                    bool(row['telemetrum_board.arm_status']),
                    float(row['telemetrum_board.current']),
                    float(row['telemetrum_board.voltage']),
                )
            ))
            
            port.write(packet.create_packet(
                packet.PACKET_TYPE_STRATOLOGGER,
                timestamp,
                (
                    bool(row['stratologger_board.arm_status']),
                    float(row['stratologger_board.current']),
                    float(row['stratologger_board.voltage']),
                )
            ))
            
            port.write(packet.create_packet(
                packet.PACKET_TYPE_CAMERA,
                timestamp,
                (
                    bool(row['camera_board.arm_status']),
                    float(row['camera_board.current']),
                    float(row['camera_board.voltage']),
                )
            ))
            
            port.write(packet.create_packet(
                packet.PACKET_TYPE_BATTERY,
                timestamp,
                (
                    float(row['mainBatteryVoltage']),
                    float(row['mainBatteryTemperature']),
                )
            ))

            print(timestamp)
            time.sleep(0.1)

    # Wait until the buffer has been written to COM1
    while(port.out_waiting > 0):
        time.sleep(.01)
    
    port.close()

    stop_time = datetime.now()
    print(f'elapsed time: {stop_time - start_time}')
