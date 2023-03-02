"""
Simulates launch using telmetry data from summer 2022.

Uses data/flight_data_2.csv which you'll need to get from Peter.
"""

from utils import packet_util
import serial
import csv
import time
import ctypes as ct

if __name__ == '__main__':

    # Setup sender port.
    port = serial.Serial(
        port='COM1',
        # baudrate=9600,
        baudrate=999999999999999,
        stopbits=serial.STOPBITS_ONE,
        parity=serial.PARITY_NONE,
        bytesize=serial.EIGHTBITS,
    )

    _lib_path = '.\libpacket_shared.dll'
    _lib = ct.CDLL(_lib_path)
    _lib.write_altitude_packet.argtypes = [ct.POINTER(ct.c_ubyte*64), ct.c_float, ct.c_float, ct.c_float]
    _lib.write_acceleration_packet.argtypes = [ct.POINTER(ct.c_ubyte), ct.c_float, ct.c_float, ct.c_float, ct.c_float]
    _lib.write_gps_position_packet.argtypes = [ct.POINTER(ct.c_ubyte), ct.c_float, ct.c_float, ct.c_float]
    _lib.write_board_voltage_packet.argtypes = [ct.POINTER(ct.c_ubyte), ct.c_float, ct.c_float, ct.c_float, ct.c_float, ct.c_float]
    _lib.write_board_current_packet.argtypes = [ct.POINTER(ct.c_ubyte), ct.c_float, ct.c_float, ct.c_float, ct.c_float, ct.c_float]
    _lib.write_battery_voltage_packet.argtypes = [ct.POINTER(ct.c_ubyte), ct.c_float, ct.c_float, ct.c_float, ct.c_float, ct.c_float]
    _lib.write_magnetometer_packet.argtypes = [ct.POINTER(ct.c_ubyte), ct.c_float, ct.c_float, ct.c_float, ct.c_float]
    _lib.write_gyroscope_packet.argtypes = [ct.POINTER(ct.c_ubyte), ct.c_float, ct.c_float, ct.c_float, ct.c_float]
    _lib.write_gps_satellite_count_packet.argtypes = [ct.POINTER(ct.c_ubyte), ct.c_float, ct.c_int]
    _lib.write_gps_ground_speed_packet.argtypes = [ct.POINTER(ct.c_ubyte), ct.c_float, ct.c_float]

    with open('data/flight_data_2.csv') as csv_file:
        reader = csv.DictReader(csv_file)
        for row in reader:
            timestamp: float = float(row['time'])

            # Altitude packets
            altitude_1: float = float(row['baro_height'])
            altitude_2: float = float(row['gps_height'])
            altitude_payload = (altitude_1, altitude_2)
            packetP = packet_util.create_packet(packet_util.PACKET_TYPE_ALTITUDE, timestamp, altitude_payload)
            port.write(packetP)
            packetC = ct.POINTER(ct.c_ubyte*64)()
            bytesWritten = _lib.write_altitude_packet(packetC, timestamp, altitude_1, altitude_2)
            for i in range(0,bytesWritten):
                 port.write(packetC[i])
            

            # Acceleration packets
            acceleration_x: float = float(row['bmx_x_accel'])
            acceleration_y: float = float(row['bmx_y_accel'])
            acceleration_z: float = float(row['bmx_z_accel'])
            acceleration_payload = (acceleration_x, acceleration_y, acceleration_z)
            port.write(packet_util.create_packet(packet_util.PACKET_TYPE_ACCELERATION, timestamp, acceleration_payload))

            # GPS coordinate packets
            gps_latitude: float = float(row['gps_lat'])
            gps_longitude: float = float(row['gps_lon'])
            gps_coordinate_payload = (gps_latitude, gps_longitude)
            port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_COORDINATES, timestamp, gps_coordinate_payload))

            # Board voltage packets
            board_1_voltage: float = float(row['telemetrum_board.voltage'])
            board_2_voltage: float = float(row['stratologger_board.voltage'])
            board_3_voltage: float = float(row['camera_board.voltage'])
            board_4_voltage: float = 1.5
            board_voltage_payload = (board_1_voltage, board_2_voltage, board_3_voltage, board_4_voltage)
            port.write(packet_util.create_packet(packet_util.PACKET_TYPE_BOARD_VOLTAGE, timestamp, board_voltage_payload))
            
            # Board current packets
            board_1_current: float = float(row['telemetrum_board.current'])
            board_2_current: float = float(row['stratologger_board.current'])
            board_3_current: float = float(row['camera_board.current'])
            board_4_current: float = 1.5
            board_current_payload = (board_1_current, board_2_current, board_3_current, board_4_current)
            port.write(packet_util.create_packet(packet_util.PACKET_TYPE_BOARD_CURRENT, timestamp, board_current_payload))

            # Battery voltage packets
            battery_1_voltage: float = float(row['mainBatteryVoltage'])
            battery_2_voltage: float = 1.5
            battery_3_voltage: float = 1.5
            battery_voltage_payload = (battery_1_voltage, battery_2_voltage, battery_3_voltage)
            port.write(packet_util.create_packet(packet_util.PACKET_TYPE_BATTERY_VOLTAGE, timestamp, battery_voltage_payload))

            # Magnetometer data
            magnetometer_data_1: float = float(row['bmx_x_magn'])
            magnetometer_data_2: float = float(row['bmx_y_magn'])
            magnetometer_data_3: float = float(row['bmx_z_magn'])
            magnetometer_payload = (magnetometer_data_1, magnetometer_data_2, magnetometer_data_3)
            port.write(packet_util.create_packet(packet_util.PACKET_TYPE_MAGNETOMETER, timestamp, magnetometer_payload))
            
            # Gyroscope data
            gyroscope_x: float = float(row['bmx_x_gyro'])
            gyroscope_y: float = float(row['bmx_y_gyro'])
            gyroscope_z: float = float(row['bmx_z_gyro'])
            gyroscope_payload = (gyroscope_x, gyroscope_y, gyroscope_z)
            port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GYROSCOPE, timestamp, gyroscope_payload))
                        
            # GPS satellites data
            gps_satellites: int = int(row['gps_satCount'])
            gps_satellites_payload = (gps_satellites,)
            port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_SATELLITES, timestamp, gps_satellites_payload))
            
            # GPS ground speed data
            gps_ground_speed: float = float(row['gps_groundSpeed'])
            gps_ground_speed_payload = (gps_ground_speed,)
            port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, timestamp, gps_ground_speed_payload))
            print(f'[{timestamp}]')

            #time.sleep(0.190540169) # Average time per packet in data.

        # for i in [0x01, 0x21, 0x10, 0x6D, 0xE7, 0xFB, 0x3D, 0x01, 0x00, 0x01, 0x90, 0xE5]:
        #     b = ct.c_ubyte(i)
        #     port.write(b)
        # test = packet_util.create_packet(2,.123,(.123,.123,.123))
        # for byte in test:
        #     print(hex(byte))
    # Wait until the buffer has been written to COM1
    while(port.out_waiting > 0):
        time.sleep(.1)
    
    port.close()