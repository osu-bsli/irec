import data_controllers.serial_data_controller as serial_data_controller
from components.data_series import DataSeries
import struct
import utils.packet_util as packet_util
import crc
import time
import dearpygui.dearpygui as gui

class IliadDataController(serial_data_controller.SerialDataController):

    def __init__(self, identifier: str) -> None:
        super().__init__(identifier)

        # Create a gui for opening / closing the connection
        with gui.window(label='Telemetry Connection'):
            with gui.group(horizontal=True):
                gui.add_text('DISCONNECTED', tag=f'{self.identifier}.connection.status')
                gui.add_button(label='CONNECT', tag=f'{self.identifier}.connection.connect', callback=lambda: self._on_connect_button_clicked())
                gui.add_button(label='DISCONNECT', tag=f'{self.identifier}.connection.disconnect', callback=lambda: self._on_disconnect_button_clicked())
                gui.add_text(self.port_name, tag=f'{self.identifier}.connection.name')
            gui.add_text('', show=False, tag=f'{self.identifier}.connection.error')
            gui.hide_item(f'{self.identifier}.connection.disconnect')

        self.data_buffer = bytearray()
        self.checksum_calculator = crc.Calculator(crc.Crc16.CCITT)

        self.arm_status_1_data =        DataSeries('time', 'Board 1 Arm Status')    # float, bool
        self.arm_status_2_data =        DataSeries('time', 'Board 1 Arm Status')    # float, bool
        self.arm_status_3_data =        DataSeries('time', 'Board 1 Arm Status')    # float, bool
        self.altitude_1_data =          DataSeries('time', 'Barometer Altitude')    # float, float
        self.altitude_2_data =          DataSeries('time', 'GPS Altitude')          # float, float
        self.acceleration_x_data =      DataSeries('time', 'X Acceleration')        # float, float
        self.acceleration_y_data =      DataSeries('time', 'Y Acceleration')        # float, float
        self.acceleration_z_data =      DataSeries('time', 'Z Acceleration')        # float, float
        self.gps_latitude_data =        DataSeries('time', 'GPS Latitude')          # float, float
        self.gps_longitude_data =       DataSeries('time', 'GPS Longitude')         # float, float
        self.board_1_temperature_data = DataSeries('time', 'Board 1 Temperature')   # float, float
        self.board_2_temperature_data = DataSeries('time', 'Board 1 Temperature')   # float, float
        self.board_3_temperature_data = DataSeries('time', 'Board 1 Temperature')   # float, float
        self.board_4_temperature_data = DataSeries('time', 'Board 1 Temperature')   # float, float
        self.board_1_voltage_data =     DataSeries('time', 'Board 1 Voltage')       # float, float
        self.board_2_voltage_data =     DataSeries('time', 'Board 2 Voltage')       # float, float
        self.board_3_voltage_data =     DataSeries('time', 'Board 3 Voltage')       # float, float
        self.board_4_voltage_data =     DataSeries('time', 'Board 4 Voltage')       # float, float
        self.board_1_current_data =     DataSeries('time', 'Board 1 Current')       # float, float
        self.board_2_current_data =     DataSeries('time', 'Board 2 Current')       # float, float
        self.board_3_current_data =     DataSeries('time', 'Board 3 Current')       # float, float
        self.board_4_current_data =     DataSeries('time', 'Board 4 Current')       # float, float
        self.battery_1_voltage_data =   DataSeries('time', 'Battery 1 Voltage')     # float, float
        self.battery_2_voltage_data =   DataSeries('time', 'Battery 2 Voltage')     # float, float
        self.battery_3_voltage_data =   DataSeries('time', 'Battery 3 Voltage')     # float, float
        self.magnetometer_data_1 =      DataSeries('time', 'Magnetometer X')        # float, float
        self.magnetometer_data_2 =      DataSeries('time', 'Magnetometer Y')        # float, float
        self.magnetometer_data_3 =      DataSeries('time', 'Magnetometer Z')        # float, float
        self.gyroscope_x_data =         DataSeries('time', 'Gyroscope X')           # float, float
        self.gyroscope_y_data =         DataSeries('time', 'Gyroscope Y')           # float, float
        self.gyroscope_z_data =         DataSeries('time', 'Gyroscope Z')           # float, float
        self.gps_satellites_data =      DataSeries('time', 'GPS Satellite Count')   # float, int
        self.gps_ground_speed_data =    DataSeries('time', 'GPS Ground Speed')      # float, float

        # Temporary variables to store data while we check the packet's checksum.
        self._current_packet_types: int = None
        self._current_arm_status_1_data: tuple[float, bool] = None
        self._current_arm_status_2_data: tuple[float, bool] = None
        self._current_arm_status_3_data: tuple[float, bool] = None
        self._current_altitude_1_data: tuple[float, float] = None
        self._current_altitude_2_data: tuple[float, float] = None
        self._current_acceleration_x_data: tuple[float, float] = None
        self._current_acceleration_y_data: tuple[float, float] = None
        self._current_acceleration_z_data: tuple[float, float] = None
        self._current_gps_latitude_data: tuple[float, float] = None
        self._current_gps_longitude_data: tuple[float, float] = None
        self._current_board_1_temperature_data: tuple[float, float] = None
        self._current_board_2_temperature_data: tuple[float, float] = None
        self._current_board_3_temperature_data: tuple[float, float] = None
        self._current_board_4_temperature_data: tuple[float, float] = None
        self._current_board_1_voltage_data: tuple[float, float] = None
        self._current_board_2_voltage_data: tuple[float, float] = None
        self._current_board_3_voltage_data: tuple[float, float] = None
        self._current_board_4_voltage_data: tuple[float, float] = None
        self._current_board_1_current_data: tuple[float, float] = None
        self._current_board_2_current_data: tuple[float, float] = None
        self._current_board_3_current_data: tuple[float, float] = None
        self._current_board_4_current_data: tuple[float, float] = None
        self._current_battery_1_voltage_data: tuple[float, float] = None
        self._current_battery_2_voltage_data: tuple[float, float] = None
        self._current_battery_3_voltage_data: tuple[float, float] = None
        self._current_magnetometer_data_1: tuple[float, float] = None
        self._current_magnetometer_data_2: tuple[float, float] = None
        self._current_magnetometer_data_3: tuple[float, float] = None
        self._current_gyroscope_x_data: tuple[float, float] = None
        self._current_gyroscope_y_data: tuple[float, float] = None
        self._current_gyroscope_z_data: tuple[float, float] = None
        self._current_gps_satellites_data: tuple[float, int] = None
        self._current_gps_ground_speed_data: tuple[float, float] = None
    
    def _on_connect_button_clicked(self) -> None:
        try:
            gui.hide_item(f'{self.identifier}.connection.error')
            self.open()
            gui.set_value(f'{self.identifier}.connection.status', 'CONNECTED')
            gui.hide_item(f'{self.identifier}.connection.connect')
            gui.show_item(f'{self.identifier}.connection.disconnect')
        except serial_data_controller.SerialDataController.DataControllerException as e:
            gui.set_value(f'{self.identifier}.connection.error', str(e))
            gui.show_item(f'{self.identifier}.connection.error')
            gui.set_value(f'{self.identifier}.connection.status', 'DISCONNECTED')
    def _on_disconnect_button_clicked(self) -> None:
        gui.hide_item(f'{self.identifier}.connection.error')
        self.close()
        gui.set_value(f'{self.identifier}.connection.status', 'DISCONNECTED')
        gui.show_item(f'{self.identifier}.connection.connect')
        gui.hide_item(f'{self.identifier}.connection.disconnect')

    def update(self) -> None:
        if self.is_open():
            
            # Poll serial port and put anything there into data_buffer
            if self.port.in_waiting > 0:
                data = self.port.read_all()
                self.data_buffer += bytearray(data)
            
            # If the buffer has enough data, try to parse some of it
            if len(self.data_buffer) > 0:
                
                self.idx_cursor = 0 # Current index in data_buffer.

                packet_types_bytes: bytes = None
                packet_types: list[int] = []
                packet_timestamp_bytes: bytes = None
                packet_timestamp: float = None
                packet_header_checksum_bytes: bytes = None
                packet_header_checksum: int = None
                packet_payload_bytes = bytearray()
                packet_payload: dict[int] = {}
                packet_checksum_bytes: bytes = None
                packet_checksum: int = None

                # Parse header:
                if len(self.data_buffer) - self.idx_cursor >= 10:
                    packet_types_bytes = self.data_buffer[self.idx_cursor:(self.idx_cursor + 2)]
                    (packet_types_raw,) = struct.unpack('>h', packet_types_bytes)
                    packet_types: list[int] = list(packet_util.get_packet_types(packet_types_raw))
                    self.idx_cursor += 2

                    packet_timestamp_bytes = self.data_buffer[self.idx_cursor:(self.idx_cursor + 4)]
                    (packet_timestamp,) = struct.unpack('>f', packet_timestamp_bytes)
                    self.idx_cursor += 4

                    packet_header_checksum_bytes = self.data_buffer[self.idx_cursor:(self.idx_cursor + 4)]
                    (packet_header_checksum,) = struct.unpack('>i', packet_header_checksum_bytes)
                    self.idx_cursor += 4

                    """
                    The basic algorithm for recovery is:
                    If crc doesn't match up, don't read the packet, discard one byte at a time and try to parse again.
                    """
                    if not self.checksum_calculator.verify(packet_types_bytes + packet_timestamp_bytes, packet_header_checksum):
                        # Packet is not ok.
                        self.data_buffer = self.data_buffer[1:]
                        self.idx_cursor = 0
                    else:
                        self._current_packet_types = packet_types_raw
                
                        # Parse body:
                        for packet_type in [
                            packet_util.PACKET_TYPE_ARM_STATUS,
                            packet_util.PACKET_TYPE_ALTITUDE,
                            packet_util.PACKET_TYPE_ACCELERATION,
                            packet_util.PACKET_TYPE_GPS_COORDINATES,
                            packet_util.PACKET_TYPE_BOARD_TEMPERATURE,
                            packet_util.PACKET_TYPE_BOARD_VOLTAGE,
                            packet_util.PACKET_TYPE_BOARD_CURRENT,
                            packet_util.PACKET_TYPE_BATTERY_VOLTAGE,
                            packet_util.PACKET_TYPE_MAGNETOMETER,
                            packet_util.PACKET_TYPE_GYROSCOPE,
                            packet_util.PACKET_TYPE_GPS_SATELLITES,
                            packet_util.PACKET_TYPE_GPS_GROUND_SPEED
                        ]:
                            if packet_type in packet_types:
                                payload_size = packet_util.PAYLOAD_SIZE[packet_type]
                                payload_format = packet_util.PAYLOAD_FORMAT[packet_type]
                                if len(self.data_buffer) - self.idx_cursor >= payload_size:
                                    payload_bytes = self.data_buffer[self.idx_cursor:(self.idx_cursor + payload_size)]
                                    payload = struct.unpack(payload_format, payload_bytes)
                                    self.idx_cursor += payload_size

                                    packet_payload_bytes += payload_bytes
                                    packet_payload[packet_type] = payload
                                            
                                    if packet_type == packet_util.PACKET_TYPE_ARM_STATUS:
                                        self._current_arm_status_1_data = (packet_timestamp, payload[0])
                                        self._current_arm_status_2_data = (packet_timestamp, payload[1])
                                        self._current_arm_status_3_data = (packet_timestamp, payload[2])
                                    elif packet_type == packet_util.PACKET_TYPE_ALTITUDE:
                                        self._current_altitude_1_data = (packet_timestamp, payload[0])
                                        self._current_altitude_2_data = (packet_timestamp, payload[1])
                                    elif packet_type == packet_util.PACKET_TYPE_ACCELERATION:
                                        self._current_acceleration_x_data = (packet_timestamp, payload[0])
                                        self._current_acceleration_y_data = (packet_timestamp, payload[1])
                                        self._current_acceleration_z_data = (packet_timestamp, payload[2])
                                    elif packet_type == packet_util.PACKET_TYPE_GPS_COORDINATES:
                                        self._current_gps_latitude_data = (packet_timestamp, payload[0])
                                        self._current_gps_longitude_data = (packet_timestamp, payload[1])
                                    elif packet_type == packet_util.PACKET_TYPE_BOARD_TEMPERATURE:
                                        self._current_board_1_temperature_data = (packet_timestamp, payload[0])
                                        self._current_board_2_temperature_data = (packet_timestamp, payload[1])
                                        self._current_board_3_temperature_data = (packet_timestamp, payload[2])
                                        self._current_board_4_temperature_data = (packet_timestamp, payload[3])
                                    elif packet_type == packet_util.PACKET_TYPE_BOARD_VOLTAGE:
                                        self._current_board_1_voltage_data = (packet_timestamp, payload[0])
                                        self._current_board_2_voltage_data = (packet_timestamp, payload[1])
                                        self._current_board_3_voltage_data = (packet_timestamp, payload[2])
                                        self._current_board_4_voltage_data = (packet_timestamp, payload[3])
                                    elif packet_type == packet_util.PACKET_TYPE_BOARD_CURRENT:
                                        self._current_board_1_current_data = (packet_timestamp, payload[0])
                                        self._current_board_2_current_data = (packet_timestamp, payload[1])
                                        self._current_board_3_current_data = (packet_timestamp, payload[2])
                                        self._current_board_4_current_data = (packet_timestamp, payload[3])
                                    elif packet_type == packet_util.PACKET_TYPE_BATTERY_VOLTAGE:
                                        self._current_battery_1_voltage_data = (packet_timestamp, payload[0])
                                        self._current_battery_2_voltage_data = (packet_timestamp, payload[1])
                                        self._current_battery_3_voltage_data = (packet_timestamp, payload[2])
                                    elif packet_type == packet_util.PACKET_TYPE_MAGNETOMETER:
                                        self._current_magnetometer_data_1 = (packet_timestamp, payload[0])
                                        self._current_magnetometer_data_2 = (packet_timestamp, payload[1])
                                        self._current_magnetometer_data_3 = (packet_timestamp, payload[2])
                                    elif packet_type == packet_util.PACKET_TYPE_GYROSCOPE:
                                        self._current_gyroscope_x_data = (packet_timestamp, payload[0])
                                        self._current_gyroscope_y_data = (packet_timestamp, payload[1])
                                        self._current_gyroscope_z_data = (packet_timestamp, payload[2])
                                    elif packet_type == packet_util.PACKET_TYPE_GPS_SATELLITES:
                                        self._current_gps_satellites_data = (packet_timestamp, payload[0])
                                    elif packet_type == packet_util.PACKET_TYPE_GPS_GROUND_SPEED:
                                        self._current_gps_ground_speed_data = (packet_timestamp, payload[0])
                        
                        # Parse footer:
                        if len(self.data_buffer) - self.idx_cursor >= 4:
                            packet_checksum_bytes = self.data_buffer[self.idx_cursor:(self.idx_cursor + 4)]
                            (packet_checksum,) = struct.unpack('>i', packet_checksum_bytes)
                            self.idx_cursor += 4

                            """
                            The basic algorithm for recovery is:
                            If crc doesn't match up, discard one byte at a time and try to parse again.
                            """
                            if not self.checksum_calculator.verify(packet_types_bytes + packet_timestamp_bytes + packet_header_checksum_bytes + packet_payload_bytes, packet_checksum):
                                # Packet is not ok.
                                self.data_buffer = self.data_buffer[1:]
                                self.idx_cursor = 0
                            else:
                                # Packet is ok.
                                self.data_buffer = self.data_buffer[self.idx_cursor:]
                                self.idx_cursor = 0

                                # Save the packet's data.
                                for current_packet_type in packet_util.get_packet_types(self._current_packet_types):
                                    if current_packet_type == packet_util.PACKET_TYPE_ARM_STATUS:
                                        self.arm_status_1_data.add_point(self._current_arm_status_1_data)
                                        self.arm_status_2_data.add_point(self._current_arm_status_2_data)
                                        self.arm_status_3_data.add_point(self._current_arm_status_3_data)
                                    elif current_packet_type == packet_util.PACKET_TYPE_ALTITUDE:
                                        self.altitude_1_data.add_point(self._current_altitude_1_data)
                                        self.altitude_2_data.add_point(self._current_altitude_2_data)
                                    elif current_packet_type == packet_util.PACKET_TYPE_ACCELERATION:
                                        self.acceleration_x_data.add_point(self._current_acceleration_x_data)
                                        self.acceleration_y_data.add_point(self._current_acceleration_y_data)
                                        self.acceleration_z_data.add_point(self._current_acceleration_z_data)
                                    elif current_packet_type == packet_util.PACKET_TYPE_GPS_COORDINATES:
                                        self.gps_latitude_data.add_point(self._current_gps_latitude_data)
                                        self.gps_longitude_data.add_point(self._current_gps_longitude_data)
                                    elif current_packet_type == packet_util.PACKET_TYPE_BOARD_TEMPERATURE:
                                        self.board_1_temperature_data.add_point(self._current_board_1_temperature_data)
                                        self.board_2_temperature_data.add_point(self._current_board_2_temperature_data)
                                        self.board_3_temperature_data.add_point(self._current_board_3_temperature_data)
                                        self.board_4_temperature_data.add_point(self._current_board_4_temperature_data)
                                    elif current_packet_type == packet_util.PACKET_TYPE_BOARD_VOLTAGE:
                                        self.board_1_voltage_data.add_point(self._current_board_1_voltage_data)
                                        self.board_2_voltage_data.add_point(self._current_board_2_voltage_data)
                                        self.board_3_voltage_data.add_point(self._current_board_3_voltage_data)
                                        self.board_4_voltage_data.add_point(self._current_board_4_voltage_data)
                                    elif current_packet_type == packet_util.PACKET_TYPE_BOARD_CURRENT:
                                        self.board_1_current_data.add_point(self._current_board_1_current_data)
                                        self.board_2_current_data.add_point(self._current_board_2_current_data)
                                        self.board_3_current_data.add_point(self._current_board_3_current_data)
                                        self.board_4_current_data.add_point(self._current_board_4_current_data)
                                    elif current_packet_type == packet_util.PACKET_TYPE_BATTERY_VOLTAGE:
                                        self.battery_1_voltage_data.add_point(self._current_battery_1_voltage_data)
                                        self.battery_2_voltage_data.add_point(self._current_battery_2_voltage_data)
                                        self.battery_3_voltage_data.add_point(self._current_battery_3_voltage_data)
                                    elif current_packet_type == packet_util.PACKET_TYPE_MAGNETOMETER:
                                        self.magnetometer_data_1.add_point(self._current_magnetometer_data_1)
                                        self.magnetometer_data_2.add_point(self._current_magnetometer_data_2)
                                        self.magnetometer_data_3.add_point(self._current_magnetometer_data_3)
                                    elif current_packet_type == packet_util.PACKET_TYPE_GYROSCOPE:
                                        self.gyroscope_x_data.add_point(self._current_gyroscope_x_data)
                                        self.gyroscope_y_data.add_point(self._current_gyroscope_y_data)
                                        self.gyroscope_z_data.add_point(self._current_gyroscope_z_data)
                                    elif current_packet_type == packet_util.PACKET_TYPE_GPS_SATELLITES:
                                        self.gps_satellites_data.add_point(self._current_gps_satellites_data)
                                    elif current_packet_type == packet_util.PACKET_TYPE_GPS_GROUND_SPEED:
                                        self.gps_ground_speed_data.add_point(self._current_gps_ground_speed_data)
        # Update gui
        if self.is_open():
            gui.set_value(f'{self.identifier}.connection.status', 'CONNECTED')
            gui.hide_item(f'{self.identifier}.connection.connect')
            gui.show_item(f'{self.identifier}.connection.disconnect')
        else:
            gui.set_value(f'{self.identifier}.connection.status', 'DISCONNECTED')
            gui.show_item(f'{self.identifier}.connection.connect')
            gui.hide_item(f'{self.identifier}.connection.disconnect')
    
    def set_config(self, config: dict[str]) -> None:
        # Note: This gets called in the superclass's constructor, so GUI may not exist yet!
        super().set_config(config)
        if gui.does_item_exist(f'{self.identifier}.connection.name'):
            gui.set_value(f'{self.identifier}.connection.name', self.port_name)
    
    def apply_config(self) -> None:
        super().apply_config()
        if gui.does_item_exist(f'{self.identifier}.connection.name'):
            gui.set_value(f'{self.identifier}.connection.name', self.port_name)
    
    def arm_camera(self) -> None:
        packet = packet_util.create_packet(packet_util.PACKET_TYPE_ARM_CAMERA, time.time(), (True,))
        self.port.write(packet)
        print(f'-> PACKET_TYPE_ARM_CAMERA {time.time()} True')
    def disarm_camera(self) -> None:
        packet = packet_util.create_packet(packet_util.PACKET_TYPE_ARM_CAMERA, time.time(), (False,))
        self.port.write(packet)
        print(f'-> PACKET_TYPE_ARM_CAMERA {time.time()} False')
    
    def arm_srad_flight_computer(self) -> None:
        packet = packet_util.create_packet(packet_util.PACKET_TYPE_ARM_SRAD_FLIGHT_COMPUTER, time.time(), (True,))
        self.port.write(packet)
        print(f'-> PACKET_TYPE_ARM_SRAD_FLIGHT_COMPUTER {time.time()} True')
    def disarm_srad_flight_computer(self) -> None:
        packet = packet_util.create_packet(packet_util.PACKET_TYPE_ARM_SRAD_FLIGHT_COMPUTER, time.time(), (False,))
        self.port.write(packet)
        print(f'-> PACKET_TYPE_ARM_SRAD_FLIGHT_COMPUTER {time.time()} False')
    
    def arm_cots_flight_computer(self) -> None:
        packet = packet_util.create_packet(packet_util.PACKET_TYPE_ARM_COTS_FLIGHT_COMPUTER, time.time(), (True,))
        self.port.write(packet)
        print(f'-> PACKET_TYPE_ARM_COTS_FLIGHT_COMPUTER {time.time()} True')
    def disarm_cots_flight_computer(self) -> None:
        packet = packet_util.create_packet(packet_util.PACKET_TYPE_ARM_COTS_FLIGHT_COMPUTER, time.time(), (False,))
        self.port.write(packet)
        print(f'-> PACKET_TYPE_ARM_COTS_FLIGHT_COMPUTER {time.time()} False')

