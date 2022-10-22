import serial
import serial.tools.list_ports
import struct
import packet_util
import crc

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

    port.write(packet_util.create_packet(
        packet_util.PACKET_TYPE_ALTITUDE,
        (
            42.0,
        )
    ))
    
    port.write(packet_util.create_packet(
        packet_util.PACKET_TYPE_COORDINATES,
        (
            -10.0,
            10.0,
        )
    ))
    
    port.write(packet_util.create_packet(
        packet_util.PACKET_TYPE_C,
        (
            32,
        )
    ))
    
    port.write(packet_util.create_packet(
        packet_util.PACKET_TYPE_D,
        (
            True,
        )
    ))

    port.write(packet_util.create_packet(
        packet_util.PACKET_TYPE_ALTITUDE + packet_util.PACKET_TYPE_COORDINATES,
        (
            1.1,
            2.2,
            3.3,
        )
    ))
    
    port.write(packet_util.create_packet(
        packet_util.PACKET_TYPE_ALTITUDE + packet_util.PACKET_TYPE_C,
        (
            1.1,
            100,
        )
    ))
    
    port.write(packet_util.create_packet(
        packet_util.PACKET_TYPE_ALTITUDE + packet_util.PACKET_TYPE_D,
        (
            1.1,
            False,
        )
    ))
    
    port.write(packet_util.create_packet(
        packet_util.PACKET_TYPE_COORDINATES + packet_util.PACKET_TYPE_C,
        (
            1.1,
            2.2,
            100,
        )
    ))
    
    port.write(packet_util.create_packet(
        packet_util.PACKET_TYPE_COORDINATES + packet_util.PACKET_TYPE_D,
        (
            1.1,
            2.2,
            False,
        )
    ))
    
    port.write(packet_util.create_packet(
        packet_util.PACKET_TYPE_C + packet_util.PACKET_TYPE_D,
        (
            365,
            True,
        )
    ))
    
    port.write(packet_util.create_packet(
        packet_util.PACKET_TYPE_ALTITUDE + packet_util.PACKET_TYPE_COORDINATES + packet_util.PACKET_TYPE_C,
        (
            1.1,
            2.2,
            3.3,
            100,
        )
    ))
    
    port.write(packet_util.create_packet(
        packet_util.PACKET_TYPE_ALTITUDE + packet_util.PACKET_TYPE_COORDINATES + packet_util.PACKET_TYPE_D,
        (
            1.1,
            2.2,
            3.3,
            False,
        )
    ))
    
    port.write(packet_util.create_packet(
        packet_util.PACKET_TYPE_ALTITUDE + packet_util.PACKET_TYPE_C + packet_util.PACKET_TYPE_D,
        (
            1.1,
            100,
            False,
        )
    ))
    
    port.write(packet_util.create_packet(
        packet_util.PACKET_TYPE_COORDINATES + packet_util.PACKET_TYPE_C + packet_util.PACKET_TYPE_D,
        (
            1.1,
            2.2,
            100,
            True,
        )
    ))
    
    port.write(packet_util.create_packet(
        packet_util.PACKET_TYPE_COORDINATES + packet_util.PACKET_TYPE_ALTITUDE + packet_util.PACKET_TYPE_C + packet_util.PACKET_TYPE_D,
        (
            1.1,
            2.2,
            3.3,
            400,
            False,
        )
    ))

print('Sent')

