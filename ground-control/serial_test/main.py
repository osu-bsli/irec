import serial
import serial.tools.list_ports
import struct
import packet_util
import crc

def list_serial_ports():
    for device in serial.tools.list_ports.comports():
        print(f'{device.name}\t{device.description}')

list_serial_ports()

