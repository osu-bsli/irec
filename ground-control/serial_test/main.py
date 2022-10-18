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
    payload = packet.create_packet(
        packet.PACKET_TYPE_ALTITUDE + packet.PACKET_TYPE_COORDINATES,
        (
            1.1,
            2.2,
            3.3,
        ),
        0
    )
    port.write(payload)
print('Sent')

