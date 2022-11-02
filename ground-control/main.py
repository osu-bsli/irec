import serial
import serial.tools.list_ports
import struct
import utils.packet_util
import crc
from serial_test.iliad_data_controller import IliadDataController

def list_serial_ports():
    for device in serial.tools.list_ports.comports():
        print(f'{device.name}\t{device.description}')

iliad = IliadDataController()
config = {
    'port_name': 'COM2',
    'port_baud_rate': 9600,
    'port_stop_bits': serial.STOPBITS_ONE,
    'port_parity': serial.PARITY_NONE,
    'port_byte_size': serial.EIGHTBITS,
}
iliad.set_config(config)
iliad.open()
iliad.close()
