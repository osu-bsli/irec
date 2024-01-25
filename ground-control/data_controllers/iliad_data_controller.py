import ctypes as ct
import time

import crc
import dearpygui.dearpygui as gui

import data_controllers.serial_data_controller as serial_data_controller
from packetlib import packet
import packetlib.packetlib as packetlib
from components.data_series import DataSeries


class IliadDataController(serial_data_controller.SerialDataController):

    def __init__(self, identifier: str) -> None:
        super().__init__(identifier)
        
        # Create a gui for opening / closing the connection
        with gui.tab(label='Telemetry Connection', parent='app.main_tab_bar'):
            with gui.group(horizontal=True):
                gui.add_text('DISCONNECTED', tag=f'{self.identifier}.connection.status')
                gui.add_button(label='CONNECT', tag=f'{self.identifier}.connection.connect', callback=lambda: self._on_connect_button_clicked())
                gui.add_button(label='DISCONNECT', tag=f'{self.identifier}.connection.disconnect', callback=lambda: self._on_disconnect_button_clicked())
                gui.add_text(self.port_name, tag=f'{self.identifier}.connection.name')
            gui.add_text('', show=False, tag=f'{self.identifier}.connection.error')
            gui.hide_item(f'{self.identifier}.connection.disconnect')

        self.data_buffer = bytearray()
        self.checksum_calculator = crc.Calculator(crc.Crc16.CCITT)

        # ~~~ Connection with C ~~~
        packetlib.initialize()
        self.packetPtr = packetlib.get_packet()
        self.packet = self.packetPtr.contents
        self.bufferPtr = packetlib.get_buffer()
        self.buffer = self.bufferPtr.contents
        # ~~~~~~~~~~~~~~~~~~~~~~~~~

        self.high_g_accelerometer_x =        DataSeries('time', 'High G Acceleration X')    # float, float
        self.high_g_accelerometer_y =        DataSeries('time', 'High G Acceleration Y')    # float, float
        self.high_g_accelerometer_z =        DataSeries('time', 'High G Acceleration Z')    # float, float
        self.gyroscope_x =                   DataSeries('time', 'Gyroscope X')              # float, float
        self.gyroscope_y =                   DataSeries('time', 'Gyroscope Y')              # float, float
        self.gyroscope_z =                   DataSeries('time', 'Gyroscope Z')              # float, float
        self.accelerometer_x =               DataSeries('time', 'Acceleration X')           # float, float
        self.accelerometer_y =               DataSeries('time', 'Acceleration Y')           # float, float
        self.accelerometer_z =               DataSeries('time', 'Acceleration Z')           # float, float
        self.barometer_altitude =            DataSeries('time', 'Altitude')                 # float, float
        self.gps_altitude =                  DataSeries('time', 'GPS Altitude')             # float, float
        self.gps_satellite_count =           DataSeries('time', 'Satellite Count')          # float, int
        self.gps_latitude =                  DataSeries('time', 'Latitude')                 # float, float
        self.gps_longitude =                 DataSeries('time', 'Longitude')                # float, float
        self.gps_ascent =                    DataSeries('time', 'Ascent')                   # float, float
        self.gps_ground_speed =              DataSeries('time', 'Ground Speed')             # float, float
        self.telemetrum_status =             DataSeries('time', 'Telemetrum Status')        # float, int
        self.telemetrum_current =            DataSeries('time', 'Telemetrum Current')       # float, float
        self.telemetrum_voltage =            DataSeries('time', 'Telemetrum Voltage')       # float, float
        self.stratologger_status =           DataSeries('time', 'Startologger Status')      # float, int
        self.stratologger_current =          DataSeries('time', 'Startologger Current')     # float, float
        self.stratologger_voltage =          DataSeries('time', 'Startologger Voltage')     # float, float
        self.camera_status =                 DataSeries('time', 'Camera Status')            # float, int
        self.camera_current =                DataSeries('time', 'Camera Current')           # float, float
        self.camera_voltage =                DataSeries('time', 'Camera Voltage')           # float, float
        self.battery_voltage =               DataSeries('time', 'Battery Voltage')          # float, float
        self.battery_temperature =           DataSeries('time', 'Battery Temperature')      # float, float

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

    # Before calling, make sure self.packet has valid data!
    def extract_packet_data(self):
        if self.packet.type == packet.PACKET_TYPE_HIGH_G_ACCELEROMETER:
            self.high_g_accelerometer_x.add_point(self.packet.timestamp, self.packet.high_g_accelerometer_x)
            self.high_g_accelerometer_y.add_point(self.packet.timestamp, self.packet.high_g_accelerometer_y)
            self.high_g_accelerometer_z.add_point(self.packet.timestamp, self.packet.high_g_accelerometer_z)
        elif self.packet.type == packet.PACKET_TYPE_GYROSCOPE:
            self.gyroscope_x.add_point(self.packet.timestamp, self.packet.gyroscope_x)
            self.gyroscope_y.add_point(self.packet.timestamp, self.packet.gyroscope_y)
            self.gyroscope_z.add_point(self.packet.timestamp, self.packet.gyroscope_z)
        elif self.packet.type == packet.PACKET_TYPE_ACCELEROMETER:
            self.accelerometer_x.add_point(self.packet.timestamp, self.packet.accelerometer_x)
            self.accelerometer_y.add_point(self.packet.timestamp, self.packet.accelerometer_y)
            self.accelerometer_z.add_point(self.packet.timestamp, self.packet.accelerometer_z)
        elif self.packet.type == packet.PACKET_TYPE_BAROMETER:
            print(f'{self.packet.timestamp} {self.packet.barometer_altitude}')
            self.barometer_altitude.add_point(self.packet.timestamp, self.packet.barometer_altitude)
        elif self.packet.type == packet.PACKET_TYPE_GPS:
            self.gps_altitude.add_point(self.packet.timestamp, self.packet.gps_altitude)
            self.gps_satellite_count.add_point(self.packet.timestamp, self.packet.gps_satellite_count)
            self.gps_latitude.add_point(self.packet.timestamp, self.packet.gps_latitude)
            self.gps_longitude.add_point(self.packet.timestamp, self.packet.gps_longitude)
            self.gps_ascent.add_point(self.packet.timestamp, self.packet.gps_ascent)
            self.gps_ground_speed.add_point(self.packet.timestamp, self.packet.gps_ground_speed)
        elif self.packet.type == packet.PACKET_TYPE_TELEMETRUM:
            self.telemetrum_status.add_point(self.packet.timestamp, self.packet.telemetrum_status)
            self.telemetrum_current.add_point(self.packet.timestamp, self.packet.telemetrum_current)
            self.telemetrum_voltage.add_point(self.packet.timestamp, self.packet.telemetrum_voltage)
        elif self.packet.type == packet.PACKET_TYPE_STRATOLOGGER:
            self.stratologger_status.add_point(self.packet.timestamp, self.packet.stratologger_status)
            self.stratologger_current.add_point(self.packet.timestamp, self.packet.stratologger_current)
            self.stratologger_voltage.add_point(self.packet.timestamp, self.packet.stratologger_voltage)
        elif self.packet.type == packet.PACKET_TYPE_CAMERA:
            self.camera_status.add_point(self.packet.timestamp, self.packet.camera_status)
            self.camera_current.add_point(self.packet.timestamp, self.packet.camera_current)
            self.camera_voltage.add_point(self.packet.timestamp, self.packet.camera_voltage)
        elif self.packet.type == packet.PACKET_TYPE_BATTERY:
            self.battery_voltage.add_point(self.packet.timestamp, self.packet.battery_voltage)
            self.battery_temperature.add_point(self.packet.timestamp, self.packet.battery_temperature)
    
    def update(self) -> None:
        if self.is_open():
            # Poll serial port and put anything there into data_buffer
            if self.port.in_waiting > 0:
                # print('data')
                self.data_buffer += self.port.read_all()
            # else:
            #     print('no data')
            bytes_to_q = max(0, min(len(self.data_buffer), packetlib._BUFFER_SIZE - self.buffer.size - 1))
            for i in range(bytes_to_q):
                packetlib.enqueue(ct.c_ubyte(self.data_buffer[i]))
            self.data_buffer = self.data_buffer[bytes_to_q:]

            # Update the packet
            old_size = 0
            while old_size - self.buffer.size != 0:
                #self.packet = self.packetPtr.contents
                old_size = self.buffer.size
                packetlib.process()
                if self.packet.is_ready == 1:
                    self.extract_packet_data()
                self.packet.is_ready = 0
                #packetlib.process()

            # for i in range(100):
            #     packetlib.process()
            #     if self.packet.is_ready == 1:
            #         self.extract_packet_data()
            #     self.packet.is_ready = 0

            # packetlib.process()
            # # print(self.buffer.size)
            # if self.packet.is_ready == 1:
            #     self.extract_packet_data()
            # self.packet.is_ready = 0

        # Update GUI
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
    
    def arm_telemetrum(self) -> None:
        p = packet.create_packet(packet.PACKET_TYPE_ARM_TELEMETRUM, time.time(), ())
        self.port.write(p)
        print(f'-> PACKET_TYPE_ARM_TELEMETRUM')
    
    def disarm_telemetrum(self) -> None:
        p = packet.create_packet(packet.PACKET_TYPE_DISARM_TELEMETRUM, time.time(), ())
        self.port.write(p)
        print(f'-> PACKET_TYPE_DISARM_TELEMETRUM')
    
    def arm_stratologger(self) -> None:
        p = packet.create_packet(packet.PACKET_TYPE_ARM_STRATOLOGGER, time.time(), ())
        self.port.write(p)
        print(f'-> PACKET_TYPE_ARM_STRATOLOGGER')
    
    def disarm_stratologger(self) -> None:
        p = packet.create_packet(packet.PACKET_TYPE_DISARM_STRATOLOGGER, time.time(), ())
        self.port.write(p)
        print(f'-> PACKET_TYPE_DISARM_STRATOLOGGER')
    
    def arm_cots_flight_computer(self) -> None:
        p = packet.create_packet(packet.PACKET_TYPE_ARM_CAMERA, time.time(), ())
        self.port.write(p)
        print(f'-> PACKET_TYPE_ARM_CAMERA')
    
    def disarm_cots_flight_computer(self) -> None:
        p = packet.create_packet(packet.PACKET_TYPE_DISARM_CAMERA, time.time(), ())
        self.port.write(p)
        print(f'-> PACKET_TYPE_DISARM_CAMERA')
