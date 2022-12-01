from data_controllers.iliad_data_controller import IliadDataController
import utils.packet_util as packet_util
import utils.math_util as math_util
import serial
import math
import pytest
import dearpygui.dearpygui as gui

# TODO: Don't hardcode port values. Maybe make virtual linked ports?

def start_headless_gui() -> None:
    gui.create_context()
    gui.create_viewport(title='Iliad Ground Control', width=600, height=300)
    gui.setup_dearpygui()

def stop_headless_gui() -> None:
    gui.destroy_context()


def test_update():
    start_headless_gui()
    test = IliadDataController('test')
    config = {
        'port_name': 'COM2',
        'port_baud_rate': 9600,
        'port_stop_bits': serial.STOPBITS_ONE,
        'port_parity': serial.PARITY_NONE,
        'port_byte_size': serial.EIGHTBITS,
    }
    test.set_config(config)
    test.open()
    for i in range(1000):
        test.update()
    test.close()
    stop_headless_gui()

def setup_packet_test() -> tuple[IliadDataController, serial.Serial]:
    """
    Utility function for packet tests.
    Starts and opens an IliadDataController instance.
    Opens a serial port.

    Both must be closed when finished.
    """
    # TODO: Rewrite as a context manager? The `with` syntax is perfect for opening/closing resources.
    test = IliadDataController('test')
    test.set_config({
        'port_name': 'COM2',
        'port_baud_rate': 9600,
        'port_stop_bits': serial.STOPBITS_ONE,
        'port_parity': serial.PARITY_NONE,
        'port_byte_size': serial.EIGHTBITS,
    })
    test.open()
    port = serial.Serial(
        port='COM1',
        baudrate=9600,
        stopbits=serial.STOPBITS_ONE,
        parity=serial.PARITY_NONE,
        bytesize=serial.EIGHTBITS,
    )
    return (test, port)

@pytest.mark.parametrize(
    "timestamp, status_1, status_2, status_3",
    [
        (0.0, True, True, True),
        (999.999, True, False, True),
        (-999.999, False, False, False),
    ]
)
def test_arm_status_packet(timestamp: float, status_1: bool, status_2: bool, status_3: bool):
    start_headless_gui()
    (test, port) = setup_packet_test()
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_ARM_STATUS, timestamp, (status_1, status_2, status_3)))
    for i in range(100):
        test.update()
    assert math_util.is_list_close(test.arm_status_1_data.x_data, [timestamp])
    assert math_util.is_list_close(test.arm_status_2_data.x_data, [timestamp])
    assert math_util.is_list_close(test.arm_status_3_data.x_data, [timestamp])
    assert test.arm_status_1_data.y_data[0] == status_1
    assert test.arm_status_2_data.y_data[0] == status_2
    assert test.arm_status_3_data.y_data[0] == status_3
    test.close()
    port.close()
    stop_headless_gui()

@pytest.mark.parametrize(
    "timestamp, altitude_1, altitude_2",
    [
        (0.0, 0.0, 0.0),
        (123.456, 999.999, -999.999),
        (789.012, -999.999, 999.999),
    ]
)
def test_altitude_packet(timestamp: float, altitude_1: float, altitude_2: float):
    start_headless_gui()
    (test, port) = setup_packet_test()
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_ALTITUDE, timestamp, (altitude_1, altitude_2)))
    for i in range(100):
        test.update()
    assert math_util.is_list_close(test.altitude_1_data.x_data, [timestamp])
    assert math_util.is_list_close(test.altitude_2_data.x_data, [timestamp])
    assert math_util.is_list_close(test.altitude_1_data.y_data, [altitude_1])
    assert math_util.is_list_close(test.altitude_2_data.y_data, [altitude_2])
    test.close()
    port.close()
    stop_headless_gui()

@pytest.mark.parametrize(
    "timestamp, acceleration_x, acceleration_y, acceleration_z",
    [
        (0.0, 0.0, 0.0, 0.0),
        (123.456, 999.999, -999.999, 999.999),
        (789.012, -999.999, 999.999, -999.999),
    ]
)
def test_acceleration_packet(timestamp: float, acceleration_x: float, acceleration_y: float, acceleration_z: float):
    start_headless_gui()
    (test, port) = setup_packet_test()
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_ACCELERATION, timestamp, (acceleration_x, acceleration_y, acceleration_z)))
    for i in range(100):
        test.update()
    assert math_util.is_list_close(test.acceleration_x_data.x_data, [timestamp])
    assert math_util.is_list_close(test.acceleration_y_data.x_data, [timestamp])
    assert math_util.is_list_close(test.acceleration_z_data.x_data, [timestamp])
    assert math_util.is_list_close(test.acceleration_x_data.y_data, [acceleration_x])
    assert math_util.is_list_close(test.acceleration_y_data.y_data, [acceleration_y])
    assert math_util.is_list_close(test.acceleration_z_data.y_data, [acceleration_z])
    test.close()
    port.close()
    stop_headless_gui()

@pytest.mark.parametrize(
    "timestamp, latitude, longitude",
    [
        (0.0, 0.0, 0.0),
        (123.456, 999.999, -999.999),
        (789.012, -999.999, 999.999),
    ]
)
def test_gps_coordinate_packet(timestamp: float, latitude: float, longitude: float):
    start_headless_gui()
    (test, port) = setup_packet_test()
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_COORDINATES, timestamp, (latitude, longitude)))
    for i in range(100):
        test.update()
    assert math_util.is_list_close(test.gps_latitude_data.x_data, [timestamp])
    assert math_util.is_list_close(test.gps_longitude_data.x_data, [timestamp])
    assert math_util.is_list_close(test.gps_latitude_data.y_data, [latitude])
    assert math_util.is_list_close(test.gps_longitude_data.y_data, [longitude])
    test.close()
    port.close()
    stop_headless_gui()

@pytest.mark.parametrize(
    "timestamp, temp_1, temp_2, temp_3, temp_4",
    [
        (0.0, 0.0, 0.0, 0.0, 0.0),
        (123.456, -789.012, 345.678, -901.234, 567.890),
        (-901.234, 999.999, 999.999, 999.999, 999.999),
    ]
)
def test_board_temperature_packet(timestamp: float, temp_1: float, temp_2: float, temp_3: float, temp_4: float):
    start_headless_gui()
    (test, port) = setup_packet_test()
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_BOARD_TEMPERATURE, timestamp, (temp_1, temp_2, temp_3, temp_4)))
    for i in range(100):
        test.update()
    assert math_util.is_list_close(test.board_1_temperature_data.x_data, [timestamp])
    assert math_util.is_list_close(test.board_2_temperature_data.x_data, [timestamp])
    assert math_util.is_list_close(test.board_3_temperature_data.x_data, [timestamp])
    assert math_util.is_list_close(test.board_4_temperature_data.x_data, [timestamp])
    assert math_util.is_list_close(test.board_1_temperature_data.y_data, [temp_1])
    assert math_util.is_list_close(test.board_2_temperature_data.y_data, [temp_2])
    assert math_util.is_list_close(test.board_3_temperature_data.y_data, [temp_3])
    assert math_util.is_list_close(test.board_4_temperature_data.y_data, [temp_4])
    test.close()
    port.close()
    stop_headless_gui()

@pytest.mark.parametrize(
    "timestamp, voltage_1, voltage_2, voltage_3, voltage_4",
    [
        (0.0, 0.0, 0.0, 0.0, 0.0),
        (123.456, -789.012, 345.678, -901.234, 567.890),
        (-901.234, 999.999, 999.999, 999.999, 999.999),
    ]
)
def test_board_voltage_packet(timestamp: float, voltage_1: float, voltage_2: float, voltage_3: float, voltage_4: float):
    start_headless_gui()
    (test, port) = setup_packet_test()
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_BOARD_VOLTAGE, timestamp, (voltage_1, voltage_2, voltage_3, voltage_4)))
    for i in range(100):
        test.update()
    assert math_util.is_list_close(test.board_1_voltage_data.x_data, [timestamp])
    assert math_util.is_list_close(test.board_2_voltage_data.x_data, [timestamp])
    assert math_util.is_list_close(test.board_3_voltage_data.x_data, [timestamp])
    assert math_util.is_list_close(test.board_4_voltage_data.x_data, [timestamp])
    assert math_util.is_list_close(test.board_1_voltage_data.y_data, [voltage_1])
    assert math_util.is_list_close(test.board_2_voltage_data.y_data, [voltage_2])
    assert math_util.is_list_close(test.board_3_voltage_data.y_data, [voltage_3])
    assert math_util.is_list_close(test.board_4_voltage_data.y_data, [voltage_4])
    test.close()
    port.close()
    stop_headless_gui()

@pytest.mark.parametrize(
    "timestamp, current_1, current_2, current_3, current_4",
    [
        (0.0, 0.0, 0.0, 0.0, 0.0),
        (123.456, -789.012, 345.678, -901.234, 567.890),
        (-901.234, 999.999, 999.999, 999.999, 999.999),
    ]
)
def test_board_current_packet(timestamp: float, current_1: float, current_2: float, current_3: float, current_4: float):
    start_headless_gui()
    (test, port) = setup_packet_test()
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_BOARD_CURRENT, timestamp, (current_1, current_2, current_3, current_4)))
    for i in range(100):
        test.update()
    assert math_util.is_list_close(test.board_1_current_data.x_data, [timestamp])
    assert math_util.is_list_close(test.board_2_current_data.x_data, [timestamp])
    assert math_util.is_list_close(test.board_3_current_data.x_data, [timestamp])
    assert math_util.is_list_close(test.board_4_current_data.x_data, [timestamp])
    assert math_util.is_list_close(test.board_1_current_data.y_data, [current_1])
    assert math_util.is_list_close(test.board_2_current_data.y_data, [current_2])
    assert math_util.is_list_close(test.board_3_current_data.y_data, [current_3])
    assert math_util.is_list_close(test.board_4_current_data.y_data, [current_4])
    test.close()
    port.close()
    stop_headless_gui()

@pytest.mark.parametrize(
    "timestamp, voltage_1, voltage_2, voltage_3",
    [
        (0.0, 0.0, 0.0, 0.0),
        (123.456, -789.012, 345.678, -901.234),
        (-901.234, 999.999, 999.999, 999.999),
    ]
)
def test_battery_voltage_packet(timestamp: float, voltage_1: float, voltage_2: float, voltage_3: float):
    start_headless_gui()
    (test, port) = setup_packet_test()
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_BATTERY_VOLTAGE, timestamp, (voltage_1, voltage_2, voltage_3)))
    for i in range(100):
        test.update()
    assert math_util.is_list_close(test.battery_1_voltage_data.x_data, [timestamp])
    assert math_util.is_list_close(test.battery_2_voltage_data.x_data, [timestamp])
    assert math_util.is_list_close(test.battery_3_voltage_data.x_data, [timestamp])
    assert math_util.is_list_close(test.battery_1_voltage_data.y_data, [voltage_1])
    assert math_util.is_list_close(test.battery_2_voltage_data.y_data, [voltage_2])
    assert math_util.is_list_close(test.battery_3_voltage_data.y_data, [voltage_3])
    test.close()
    port.close()
    stop_headless_gui()

@pytest.mark.parametrize(
    "timestamp, magnetometer_1, magnetometer_2, magnetometer_3",
    [
        (0.0, 0.0, 0.0, 0.0),
        (123.456, -789.012, 345.678, -901.234),
        (-901.234, 999.999, 999.999, 999.999),
    ]
)
def test_magnetometer_packet(timestamp: float, magnetometer_1: float, magnetometer_2: float, magnetometer_3: float):
    start_headless_gui()
    (test, port) = setup_packet_test()
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_MAGNETOMETER, timestamp, (magnetometer_1, magnetometer_2, magnetometer_3)))
    for i in range(100):
        test.update()
    assert math_util.is_list_close(test.magnetometer_data_1.x_data, [timestamp])
    assert math_util.is_list_close(test.magnetometer_data_2.x_data, [timestamp])
    assert math_util.is_list_close(test.magnetometer_data_3.x_data, [timestamp])
    assert math_util.is_list_close(test.magnetometer_data_1.y_data, [magnetometer_1])
    assert math_util.is_list_close(test.magnetometer_data_2.y_data, [magnetometer_2])
    assert math_util.is_list_close(test.magnetometer_data_3.y_data, [magnetometer_3])
    test.close()
    port.close()
    stop_headless_gui()

@pytest.mark.parametrize(
    "timestamp, gyroscope_x, gyroscope_y, gyroscope_z",
    [
        (0.0, 0.0, 0.0, 0.0),
        (123.456, -789.012, 345.678, -901.234),
        (-901.234, 999.999, 999.999, 999.999),
    ]
)
def test_gyroscope_packet(timestamp: float, gyroscope_x: float, gyroscope_y: float, gyroscope_z: float):
    start_headless_gui()
    (test, port) = setup_packet_test()
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GYROSCOPE, timestamp, (gyroscope_x, gyroscope_y, gyroscope_z)))
    for i in range(100):
        test.update()
    assert math_util.is_list_close(test.gyroscope_x_data.x_data, [timestamp])
    assert math_util.is_list_close(test.gyroscope_y_data.x_data, [timestamp])
    assert math_util.is_list_close(test.gyroscope_z_data.x_data, [timestamp])
    assert math_util.is_list_close(test.gyroscope_x_data.y_data, [gyroscope_x])
    assert math_util.is_list_close(test.gyroscope_y_data.y_data, [gyroscope_y])
    assert math_util.is_list_close(test.gyroscope_z_data.y_data, [gyroscope_z])
    test.close()
    port.close()
    stop_headless_gui()

@pytest.mark.parametrize(
    "timestamp, satellites",
    [
        (0.0, 0),
        (123.456, 99),
        (-901.234, -99),
    ]
)
def test_gps_satellites_packet(timestamp: float, satellites: int):
    start_headless_gui()
    (test, port) = setup_packet_test()
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_SATELLITES, timestamp, (satellites,)))
    for i in range(100):
        test.update()
    assert math_util.is_list_close(test.gps_satellites_data.x_data, [timestamp])
    assert test.gps_satellites_data.y_data == [satellites]
    test.close()
    port.close()
    stop_headless_gui()

@pytest.mark.parametrize(
    "timestamp, speed",
    [
        (0.0, 0.0),
        (123.456, 789.012),
        (-901.234, -567.890),
    ]
)
def test_gps_ground_speed_packet(timestamp: float, speed: float):
    start_headless_gui()
    (test, port) = setup_packet_test()
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, timestamp, (speed,)))
    for i in range(100):
        test.update()
    assert math_util.is_list_close(test.gps_ground_speed_data.x_data, [timestamp])
    assert math_util.is_list_close(test.gps_ground_speed_data.y_data, [speed])
    test.close()
    port.close()
    stop_headless_gui()

def test_multiple_packets():
    start_headless_gui()
    (test, port) = setup_packet_test()
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.0, (123.456,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.1, (123.456,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.2, (123.456,)))
    for i in range(100):
        test.update()
    math_util.is_list_close(test.gps_ground_speed_data.x_data, [0.0, 0.1, 0.2])
    math_util.is_list_close(test.gps_ground_speed_data.y_data, [123.456, 123.456, 123.456])
    test.close()
    port.close()
    stop_headless_gui()

def test_mixed_packets():
    start_headless_gui()
    (test, port) = setup_packet_test()
    port.write(packet_util.create_packet(
        packet_util.PACKET_TYPE_GPS_SATELLITES + packet_util.PACKET_TYPE_GPS_GROUND_SPEED,
        0.0,
        (0, 123.456)))
    for i in range(100):
        test.update()
    assert math_util.is_list_close(test.gps_satellites_data.x_data, [0.0])
    assert test.gps_satellites_data.y_data == [0]
    assert math_util.is_list_close(test.gps_ground_speed_data.x_data, [0.0])
    assert math_util.is_list_close(test.gps_ground_speed_data.y_data, [123.456])
    test.close()
    port.close()
    stop_headless_gui()

def test_resync_on_corrupted_packet():
    start_headless_gui()
    (test, port) = setup_packet_test()
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.0, (123.456,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.1, (789.012,)))
    corrupted_packet = bytearray(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.2, (345.678,)))
    corrupted_packet = corrupted_packet[1:]
    port.write(corrupted_packet)
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.3, (901.234,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.4, (567.890,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.5, (567.890,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.6, (567.890,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.7, (567.890,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.8, (567.890,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.9, (567.890,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 1.0, (567.890,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 1.1, (567.890,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 1.2, (567.890,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 1.3, (567.890,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 1.4, (567.890,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 1.5, (567.890,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 1.6, (567.890,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 1.7, (567.890,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 1.8, (567.890,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 1.9, (567.890,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 2.0, (567.890,)))
    for i in range(100):
        test.update()
    assert math_util.is_list_close(test.gps_ground_speed_data.x_data, [
        0.0,
        0.1,
        0.3,
        0.4,
        0.5,
        0.6,
        0.7,
        0.8,
        0.9,
        1.0,
        1.1,
        1.2,
        1.3,
        1.4,
        1.5,
        1.6,
        1.7,
        1.8,
        1.9,
        2.0,
    ])
    assert math_util.is_list_close(test.gps_ground_speed_data.y_data, [
        123.456,
        789.012,
        901.234,
        567.890,
        567.890,
        567.890,
        567.890,
        567.890,
        567.890,
        567.890,
        567.890,
        567.890,
        567.890,
        567.890,
        567.890,
        567.890,
        567.890,
        567.890,
        567.890,
        567.890,
    ])
    test.close()
    port.close()
    stop_headless_gui()

def test_resync_speed():
    start_headless_gui()
    (test, port) = setup_packet_test()
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.0, (123.456,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.1, (789.012,)))
    corrupted_packet = bytearray(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.2, (345.678,)))
    corrupted_packet = corrupted_packet[1:]
    port.write(corrupted_packet)
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.3, (901.234,)))
    for i in range(100):
        test.update()
    assert math_util.is_list_close(test.gps_ground_speed_data.x_data, [0.0, 0.1, 0.3])
    assert math_util.is_list_close(test.gps_ground_speed_data.y_data, [123.456, 789.012, 901.234])
    test.close()
    port.close()
    stop_headless_gui()

def test_resync_on_corrupted_header():
    start_headless_gui()
    (test, port) = setup_packet_test()
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.0, (123.456,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.1, (789.012,)))
    corrupted_packet = bytearray(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.2, (345.678,)))
    corrupted_packet[1] = 11
    port.write(corrupted_packet)
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.3, (901.234,)))
    for i in range(100):
        test.update()
    assert math_util.is_list_close(test.gps_ground_speed_data.x_data, [0.0, 0.1, 0.3])
    assert math_util.is_list_close(test.gps_ground_speed_data.y_data, [123.456, 789.012, 901.234])
    test.close()
    port.close()
    stop_headless_gui()

def test_resync_on_corrupted_body():
    start_headless_gui()
    (test, port) = setup_packet_test()
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.0, (123.456,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.1, (789.012,)))
    corrupted_packet = bytearray(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.2, (345.678,)))
    corrupted_packet[11] = 255
    port.write(corrupted_packet)
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.3, (901.234,)))
    for i in range(100):
        test.update()
    assert math_util.is_list_close(test.gps_ground_speed_data.x_data, [0.0, 0.1, 0.3])
    assert math_util.is_list_close(test.gps_ground_speed_data.y_data, [123.456, 789.012, 901.234])
    test.close()
    port.close()
    stop_headless_gui()

def test_resync_on_double_corrupted_head():
    start_headless_gui()
    (test, port) = setup_packet_test()
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.0, (123.456,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.1, (789.012,)))
    corrupted_packet = bytearray(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.2, (345.678,)))
    corrupted_packet[1] = 11
    port.write(corrupted_packet)
    corrupted_packet = bytearray(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.2, (345.678,)))
    corrupted_packet[1] = 11
    port.write(corrupted_packet)
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.3, (901.234,)))
    for i in range(100):
        test.update()
    assert math_util.is_list_close(test.gps_ground_speed_data.x_data, [0.0, 0.1, 0.3])
    assert math_util.is_list_close(test.gps_ground_speed_data.y_data, [123.456, 789.012, 901.234])
    test.close()
    port.close()
    stop_headless_gui()

def test_resync_on_double_corrupted_body():
    start_headless_gui()
    (test, port) = setup_packet_test()
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.0, (123.456,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.1, (789.012,)))
    corrupted_packet = bytearray(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.2, (345.678,)))
    corrupted_packet[11] = 255
    port.write(corrupted_packet)
    corrupted_packet = bytearray(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.2, (345.678,)))
    corrupted_packet[11] = 255
    port.write(corrupted_packet)
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.3, (901.234,)))
    for i in range(100):
        test.update()
    assert math_util.is_list_close(test.gps_ground_speed_data.x_data, [0.0, 0.1, 0.3])
    assert math_util.is_list_close(test.gps_ground_speed_data.y_data, [123.456, 789.012, 901.234])
    test.close()
    port.close()
    stop_headless_gui()

def test_resync_on_double_corrupted_mixed():
    start_headless_gui()
    (test, port) = setup_packet_test()
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.0, (123.456,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.1, (789.012,)))
    corrupted_packet = bytearray(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.2, (345.678,)))
    corrupted_packet[1] = 11
    port.write(corrupted_packet)
    corrupted_packet = bytearray(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.2, (345.678,)))
    corrupted_packet[11] = 255
    port.write(corrupted_packet)
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.3, (901.234,)))
    for i in range(100):
        test.update()
    assert math_util.is_list_close(test.gps_ground_speed_data.x_data, [0.0, 0.1, 0.3])
    assert math_util.is_list_close(test.gps_ground_speed_data.y_data, [123.456, 789.012, 901.234])
    test.close()
    port.close()
    stop_headless_gui()
