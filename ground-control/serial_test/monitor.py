import serial
import serial.tools.list_ports
import struct
import packet

def list_serial_ports():
    for device in serial.tools.list_ports.comports():
        print(f'{device.name}\t{device.description}')

list_serial_ports()

with serial.Serial(
    port='COM2',
    baudrate=9600,
    stopbits=serial.STOPBITS_ONE,
    parity=serial.PARITY_NONE,
    bytesize=serial.EIGHTBITS,
    # timeout=3,
    # write_timeout=3,
) as port:

    packet_number = 0

    while not port.closed:

        packet: dict[str] = {
            'header': 0,
            'data': 0,
        }

        packet_number += 1
        print(f'Packet {packet_number}:')
        
        # while port.in_waiting <= 0:
        #     pass
        # bytes = port.read(2)
        # print(struct.unpack('>h', bytes))
        # bytes = port.read(4)
        # print(struct.unpack('>f', bytes))
        # continue

        while port.in_waiting <= 0:
            pass

        header_bytes = port.read(2)
        header = 0
        (header,) = struct.unpack('>h', header_bytes)
        packet['header'] = header

        if packet['header'] == 1:
            data_bytes = port.read(4)
            data = 0.0
            (data,) = struct.unpack('>f', data_bytes)
            packet['data'] = data
        else:
            print(f'Invalid header {packet["header"]}')

        print(f'\theader: {packet["header"]}')
        print(f'\tdata: {packet["data"]}')


print('Received')

