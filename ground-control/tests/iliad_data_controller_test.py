from data_controllers.iliad_data_controller import IliadDataController
import utils.packet_util as packet_util
import serial
import math
import pytest

# TODO: Don't hardcode port values. Maybe make virtual linked ports?

def test_update():
    test = IliadDataController()
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

def setup_packet_test() -> tuple[IliadDataController, serial.Serial]:
    """
    Utility function for packet tests.
    Starts and opens an IliadDataController instance.
    Opens a serial port.

    Both must be closed when finished.
    """
    # TODO: Rewrite as a context manager? The `with` syntax is perfect for opening/closing resources.
    test = IliadDataController()
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
    (test, port) = setup_packet_test()
    print(f'{timestamp}')
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_ARM_STATUS, timestamp, (status_1, status_2, status_3)))
    for i in range(100):
        test.update()
    assert len(test.arm_status_1_data) == 1
    assert len(test.arm_status_2_data) == 1
    assert len(test.arm_status_3_data) == 1
    assert len(test.altitude_1_data) == 0
    assert math.isclose(test.arm_status_1_data[0][0], timestamp, rel_tol=1e-6) # TODO: Figure out specific tolerances.
    assert math.isclose(test.arm_status_2_data[0][0], timestamp, rel_tol=1e-6)
    assert math.isclose(test.arm_status_3_data[0][0], timestamp, rel_tol=1e-6)
    assert test.arm_status_1_data[0][1] == status_1
    assert test.arm_status_2_data[0][1] == status_2
    assert test.arm_status_3_data[0][1] == status_3
    test.close()
    port.close()

@pytest.mark.parametrize(
    "timestamp, altitude_1, altitude_2",
    [
        (0.0, 0.0, 0.0),
        (123.456, 999.999, -999.999),
        (789.012, -999.999, 999.999),
    ]
)
def test_altitude_packet(timestamp: float, altitude_1: float, altitude_2: float):
    (test, port) = setup_packet_test()
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_ALTITUDE, timestamp, (altitude_1, altitude_2)))
    for i in range(100):
        test.update()
    assert len(test.altitude_1_data) == 1
    assert len(test.altitude_2_data) == 1
    assert math.isclose(test.altitude_1_data[0][0], timestamp, rel_tol=1e-6)
    assert math.isclose(test.altitude_2_data[0][0], timestamp, rel_tol=1e-6)
    assert math.isclose(test.altitude_1_data[0][1], altitude_1, rel_tol=1e-6)
    assert math.isclose(test.altitude_2_data[0][1], altitude_2, rel_tol=1e-6)
    test.close()
    port.close()

@pytest.mark.parametrize(
    "timestamp, acceleration_x, acceleration_y, acceleration_z",
    [
        (0.0, 0.0, 0.0, 0.0),
        (123.456, 999.999, -999.999, 999.999),
        (789.012, -999.999, 999.999, -999.999),
    ]
)
def test_acceleration_packet(timestamp: float, acceleration_x: float, acceleration_y: float, acceleration_z: float):
    (test, port) = setup_packet_test()
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_ACCELERATION, timestamp, (acceleration_x, acceleration_y, acceleration_z)))
    for i in range(100):
        test.update()
    assert len(test.acceleration_x_data) == 1
    assert len(test.acceleration_y_data) == 1
    assert len(test.acceleration_z_data) == 1
    assert math.isclose(test.acceleration_x_data[0][0], timestamp, rel_tol=1e-6)
    assert math.isclose(test.acceleration_y_data[0][0], timestamp, rel_tol=1e-6)
    assert math.isclose(test.acceleration_z_data[0][0], timestamp, rel_tol=1e-6)
    assert math.isclose(test.acceleration_x_data[0][1], acceleration_x, rel_tol=1e-6)
    assert math.isclose(test.acceleration_y_data[0][1], acceleration_y, rel_tol=1e-6)
    assert math.isclose(test.acceleration_z_data[0][1], acceleration_z, rel_tol=1e-6)
    test.close()
    port.close()

@pytest.mark.parametrize(
    "timestamp, latitude, longitude",
    [
        (0.0, 0.0, 0.0),
        (123.456, 999.999, -999.999),
        (789.012, -999.999, 999.999),
    ]
)
def test_gps_coordinate_packet(timestamp: float, latitude: float, longitude: float):
    (test, port) = setup_packet_test()
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_COORDINATES, timestamp, (latitude, longitude)))
    for i in range(100):
        test.update()
    assert len(test.gps_latitude_data) == 1
    assert len(test.gps_longitude_data) == 1
    assert math.isclose(test.gps_latitude_data[0][0], timestamp, rel_tol=1e-6)
    assert math.isclose(test.gps_longitude_data[0][0], timestamp, rel_tol=1e-6)
    assert math.isclose(test.gps_latitude_data[0][1], latitude, rel_tol=1e-6)
    assert math.isclose(test.gps_longitude_data[0][1], longitude, rel_tol=1e-6)
    test.close()
    port.close()

@pytest.mark.parametrize(
    "timestamp, temp_1, temp_2, temp_3, temp_4",
    [
        (0.0, 0.0, 0.0, 0.0, 0.0),
        (123.456, -789.012, 345.678, -901.234, 567.890),
        (-901.234, 999.999, 999.999, 999.999, 999.999),
    ]
)
def test_board_temperature_packet(timestamp: float, temp_1: float, temp_2: float, temp_3: float, temp_4: float):
    (test, port) = setup_packet_test()
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_BOARD_TEMPERATURE, timestamp, (temp_1, temp_2, temp_3, temp_4)))
    for i in range(100):
        test.update()
    assert len(test.board_1_temperature_data) == 1
    assert len(test.board_2_temperature_data) == 1
    assert len(test.board_3_temperature_data) == 1
    assert len(test.board_4_temperature_data) == 1
    assert math.isclose(test.board_1_temperature_data[0][0], timestamp, rel_tol=1e-6)
    assert math.isclose(test.board_2_temperature_data[0][0], timestamp, rel_tol=1e-6)
    assert math.isclose(test.board_3_temperature_data[0][0], timestamp, rel_tol=1e-6)
    assert math.isclose(test.board_4_temperature_data[0][0], timestamp, rel_tol=1e-6)
    assert math.isclose(test.board_1_temperature_data[0][1], temp_1, rel_tol=1e-6)
    assert math.isclose(test.board_2_temperature_data[0][1], temp_2, rel_tol=1e-6)
    assert math.isclose(test.board_3_temperature_data[0][1], temp_3, rel_tol=1e-6)
    assert math.isclose(test.board_4_temperature_data[0][1], temp_4, rel_tol=1e-6)
    test.close()
    port.close()

@pytest.mark.parametrize(
    "timestamp, voltage_1, voltage_2, voltage_3, voltage_4",
    [
        (0.0, 0.0, 0.0, 0.0, 0.0),
        (123.456, -789.012, 345.678, -901.234, 567.890),
        (-901.234, 999.999, 999.999, 999.999, 999.999),
    ]
)
def test_board_voltage_packet(timestamp: float, voltage_1: float, voltage_2: float, voltage_3: float, voltage_4: float):
    (test, port) = setup_packet_test()
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_BOARD_VOLTAGE, timestamp, (voltage_1, voltage_2, voltage_3, voltage_4)))
    for i in range(100):
        test.update()
    assert len(test.board_1_voltage_data) == 1
    assert len(test.board_2_voltage_data) == 1
    assert len(test.board_3_voltage_data) == 1
    assert len(test.board_4_voltage_data) == 1
    assert math.isclose(test.board_1_voltage_data[0][0], timestamp, rel_tol=1e-6)
    assert math.isclose(test.board_2_voltage_data[0][0], timestamp, rel_tol=1e-6)
    assert math.isclose(test.board_3_voltage_data[0][0], timestamp, rel_tol=1e-6)
    assert math.isclose(test.board_4_voltage_data[0][0], timestamp, rel_tol=1e-6)
    assert math.isclose(test.board_1_voltage_data[0][1], voltage_1, rel_tol=1e-6)
    assert math.isclose(test.board_2_voltage_data[0][1], voltage_2, rel_tol=1e-6)
    assert math.isclose(test.board_3_voltage_data[0][1], voltage_3, rel_tol=1e-6)
    assert math.isclose(test.board_4_voltage_data[0][1], voltage_4, rel_tol=1e-6)
    test.close()
    port.close()

@pytest.mark.parametrize(
    "timestamp, current_1, current_2, current_3, current_4",
    [
        (0.0, 0.0, 0.0, 0.0, 0.0),
        (123.456, -789.012, 345.678, -901.234, 567.890),
        (-901.234, 999.999, 999.999, 999.999, 999.999),
    ]
)
def test_board_current_packet(timestamp: float, current_1: float, current_2: float, current_3: float, current_4: float):
    (test, port) = setup_packet_test()
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_BOARD_CURRENT, timestamp, (current_1, current_2, current_3, current_4)))
    for i in range(100):
        test.update()
    assert len(test.board_1_current_data) == 1
    assert len(test.board_2_current_data) == 1
    assert len(test.board_3_current_data) == 1
    assert len(test.board_4_current_data) == 1
    assert math.isclose(test.board_1_current_data[0][0], timestamp, rel_tol=1e-6)
    assert math.isclose(test.board_2_current_data[0][0], timestamp, rel_tol=1e-6)
    assert math.isclose(test.board_3_current_data[0][0], timestamp, rel_tol=1e-6)
    assert math.isclose(test.board_4_current_data[0][0], timestamp, rel_tol=1e-6)
    assert math.isclose(test.board_1_current_data[0][1], current_1, rel_tol=1e-6)
    assert math.isclose(test.board_2_current_data[0][1], current_2, rel_tol=1e-6)
    assert math.isclose(test.board_3_current_data[0][1], current_3, rel_tol=1e-6)
    assert math.isclose(test.board_4_current_data[0][1], current_4, rel_tol=1e-6)
    test.close()
    port.close()

@pytest.mark.parametrize(
    "timestamp, voltage_1, voltage_2, voltage_3",
    [
        (0.0, 0.0, 0.0, 0.0),
        (123.456, -789.012, 345.678, -901.234),
        (-901.234, 999.999, 999.999, 999.999),
    ]
)
def test_battery_voltage_packet(timestamp: float, voltage_1: float, voltage_2: float, voltage_3: float):
    (test, port) = setup_packet_test()
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_BATTERY_VOLTAGE, timestamp, (voltage_1, voltage_2, voltage_3)))
    for i in range(100):
        test.update()
    assert len(test.battery_1_voltage_data) == 1
    assert len(test.battery_2_voltage_data) == 1
    assert len(test.battery_3_voltage_data) == 1
    assert math.isclose(test.battery_1_voltage_data[0][0], timestamp, rel_tol=1e-6)
    assert math.isclose(test.battery_2_voltage_data[0][0], timestamp, rel_tol=1e-6)
    assert math.isclose(test.battery_3_voltage_data[0][0], timestamp, rel_tol=1e-6)
    assert math.isclose(test.battery_1_voltage_data[0][1], voltage_1, rel_tol=1e-6)
    assert math.isclose(test.battery_2_voltage_data[0][1], voltage_2, rel_tol=1e-6)
    assert math.isclose(test.battery_3_voltage_data[0][1], voltage_3, rel_tol=1e-6)
    test.close()
    port.close()

@pytest.mark.parametrize(
    "timestamp, magnetometer_1, magnetometer_2, magnetometer_3",
    [
        (0.0, 0.0, 0.0, 0.0),
        (123.456, -789.012, 345.678, -901.234),
        (-901.234, 999.999, 999.999, 999.999),
    ]
)
def test_magnetometer_packet(timestamp: float, magnetometer_1: float, magnetometer_2: float, magnetometer_3: float):
    (test, port) = setup_packet_test()
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_MAGNETOMETER, timestamp, (magnetometer_1, magnetometer_2, magnetometer_3)))
    for i in range(100):
        test.update()
    assert len(test.magnetometer_data_1) == 1
    assert len(test.magnetometer_data_2) == 1
    assert len(test.magnetometer_data_3) == 1
    assert math.isclose(test.magnetometer_data_1[0][0], timestamp, rel_tol=1e-6)
    assert math.isclose(test.magnetometer_data_2[0][0], timestamp, rel_tol=1e-6)
    assert math.isclose(test.magnetometer_data_3[0][0], timestamp, rel_tol=1e-6)
    assert math.isclose(test.magnetometer_data_1[0][1], magnetometer_1, rel_tol=1e-6)
    assert math.isclose(test.magnetometer_data_2[0][1], magnetometer_2, rel_tol=1e-6)
    assert math.isclose(test.magnetometer_data_3[0][1], magnetometer_3, rel_tol=1e-6)
    test.close()
    port.close()

@pytest.mark.parametrize(
    "timestamp, gyroscope_x, gyroscope_y, gyroscope_z",
    [
        (0.0, 0.0, 0.0, 0.0),
        (123.456, -789.012, 345.678, -901.234),
        (-901.234, 999.999, 999.999, 999.999),
    ]
)
def test_gyroscope_packet(timestamp: float, gyroscope_x: float, gyroscope_y: float, gyroscope_z: float):
    (test, port) = setup_packet_test()
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GYROSCOPE, timestamp, (gyroscope_x, gyroscope_y, gyroscope_z)))
    for i in range(100):
        test.update()
    assert len(test.gyroscope_x_data) == 1
    assert len(test.gyroscope_y_data) == 1
    assert len(test.gyroscope_z_data) == 1
    assert math.isclose(test.gyroscope_x_data[0][0], timestamp, rel_tol=1e-6)
    assert math.isclose(test.gyroscope_y_data[0][0], timestamp, rel_tol=1e-6)
    assert math.isclose(test.gyroscope_z_data[0][0], timestamp, rel_tol=1e-6)
    assert math.isclose(test.gyroscope_x_data[0][1], gyroscope_x, rel_tol=1e-6)
    assert math.isclose(test.gyroscope_y_data[0][1], gyroscope_y, rel_tol=1e-6)
    assert math.isclose(test.gyroscope_z_data[0][1], gyroscope_z, rel_tol=1e-6)
    test.close()
    port.close()

@pytest.mark.parametrize(
    "timestamp, satellites",
    [
        (0.0, 0),
        (123.456, 99),
        (-901.234, -99),
    ]
)
def test_gps_satellites_packet(timestamp: float, satellites: int):
    (test, port) = setup_packet_test()
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_SATELLITES, timestamp, (satellites,)))
    for i in range(100):
        test.update()
    assert math.isclose(test.gps_satellites_data[0][0], timestamp, rel_tol=1e-6)
    assert test.gps_satellites_data[0][1] == satellites
    test.close()
    port.close()

@pytest.mark.parametrize(
    "timestamp, speed",
    [
        (0.0, 0.0),
        (123.456, 789.012),
        (-901.234, -567.890),
    ]
)
def test_gps_ground_speed_packet(timestamp: float, speed: float):
    (test, port) = setup_packet_test()
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, timestamp, (speed,)))
    for i in range(100):
        test.update()
    assert len(test.gps_ground_speed_data) == 1
    assert math.isclose(test.gps_ground_speed_data[0][0], timestamp, rel_tol=1e-6)
    assert math.isclose(test.gps_ground_speed_data[0][1], speed, rel_tol=1e-6)
    test.close()
    port.close()

def test_multiple_packets():
    (test, port) = setup_packet_test()
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.0, (123.456,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.1, (123.456,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.2, (123.456,)))
    for i in range(100):
        test.update()
    assert len(test.gps_ground_speed_data) == 3
    assert math.isclose(test.gps_ground_speed_data[0][0], 0.0, rel_tol=1e-6)
    assert math.isclose(test.gps_ground_speed_data[1][0], 0.1, rel_tol=1e-6)
    assert math.isclose(test.gps_ground_speed_data[2][0], 0.2, rel_tol=1e-6)
    assert math.isclose(test.gps_ground_speed_data[0][1], 123.456, rel_tol=1e-6)
    assert math.isclose(test.gps_ground_speed_data[1][1], 123.456, rel_tol=1e-6)
    assert math.isclose(test.gps_ground_speed_data[2][1], 123.456, rel_tol=1e-6)
    test.close()
    port.close()

def test_mixed_packets():
    (test, port) = setup_packet_test()
    port.write(packet_util.create_packet(
        packet_util.PACKET_TYPE_GPS_SATELLITES + packet_util.PACKET_TYPE_GPS_GROUND_SPEED,
        0.0,
        (0, 123.456)))
    for i in range(100):
        test.update()
    assert len(test.gps_satellites_data) == 1
    assert math.isclose(test.gps_satellites_data[0][0], 0.0, rel_tol=1e-6)
    assert test.gps_satellites_data[0][1] == 0
    assert len(test.gps_ground_speed_data) == 1
    assert math.isclose(test.gps_ground_speed_data[0][0], 0.0, rel_tol=1e-6)
    assert math.isclose(test.gps_ground_speed_data[0][1], 123.456, rel_tol=1e-6)
    test.close()
    port.close()

def test_resync_on_corrupted_packet():
    (test, port) = setup_packet_test()
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.0, (123.456,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.1, (789.012,)))
    corrupted_packet = bytearray(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.2, (345.678,)))
    corrupted_packet = corrupted_packet[1:]
    port.write(corrupted_packet)
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.3, (901.234,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.4, (567.890,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.4, (567.890,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.4, (567.890,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.4, (567.890,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.4, (567.890,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.4, (567.890,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.4, (567.890,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.4, (567.890,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.4, (567.890,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.4, (567.890,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.4, (567.890,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.4, (567.890,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.4, (567.890,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.4, (567.890,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.4, (567.890,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.4, (567.890,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.4, (567.890,)))
    for i in range(100):
        test.update()
    assert len(test.gps_ground_speed_data) == 20
    test.close()
    port.close()

def test_resync_speed():
    # TODO: This test fails because the parsing algorithm / resync algorithm waits for the full packet, even if the type is corrupted. We need to add a second checksum just for the header.
    (test, port) = setup_packet_test()
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.0, (123.456,)))
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.1, (789.012,)))
    corrupted_packet = bytearray(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.2, (345.678,)))
    corrupted_packet = corrupted_packet[1:]
    port.write(corrupted_packet)
    port.write(packet_util.create_packet(packet_util.PACKET_TYPE_GPS_GROUND_SPEED, 0.3, (901.234,)))
    for i in range(100):
        test.update()
    assert len(test.gps_ground_speed_data) == 3
    test.close()
    port.close()
