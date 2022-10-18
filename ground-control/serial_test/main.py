import serial
import serial.tools.list_ports
import struct
import packet

def list_serial_ports():
    for device in serial.tools.list_ports.comports():
        print(f'{device.name}\t{device.description}')

list_serial_ports()

with serial.Serial(
    port='COM1',
    baudrate=9600,
    stopbits=serial.STOPBITS_ONE,
    parity=serial.PARITY_NONE,
    bytesize=serial.EIGHTBITS,
    # timeout=3,
    # write_timeout=3,
) as port:
    # x = port.write(bytes("Hello, world!\n", "utf-8"))
    header = 1
    data = 42.0
    checksum = header + data

    # payload = struct.pack('>hff', header, data, checksum)
    payload = struct.pack('>hf', header, data)
    port.write(bytes(payload))
print('Sent')

