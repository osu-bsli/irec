import serial
import serial.tools.list_ports
import struct
import packetlib.packet as packet
import crc

def is_front(item, list: list) -> bool:
    if len(list) > 0 and list[0] == item:
        return True
    return False

def list_serial_ports():
    for device in serial.tools.list_ports.comports():
        print(f'{device.name}\t{device.description}')

list_serial_ports()

crc_calculator = crc.CrcCalculator(crc.Crc16.CCITT)

with serial.Serial(
    port='COM2',
    baudrate=9600,
    stopbits=serial.STOPBITS_ONE,
    parity=serial.PARITY_NONE,
    bytesize=serial.EIGHTBITS,
    # timeout=3,
    # write_timeout=3,
) as port:

    packet_number = -1

    stream = bytearray()
    packet: dict[int] = {}
    packet_types: list[int] = [] # Queue of packet types for parsing each type's data sequentially.
    is_in_packet = False
    checksum_target = bytearray()

    while not port.closed:

        # packet: dict[str] = {
        #     'header': 0,
        #     'data': 0,
        # }

        # packet_number += 1
        # print(f'Packet {packet_number}:')
        
        # while port.in_waiting <= 0:
        #     pass
        # bytes = port.read(2)
        # print(struct.unpack('>h', bytes))
        # bytes = port.read(4)
        # print(struct.unpack('>f', bytes))
        # continue

        # while port.in_waiting <= 0:
        #     pass
        # bytes = port.read_all()
        # print(len(bytes))
        # (header, data, checksum) = packet.parse_packet(bytes)
        # print(data)

        # header_bytes = port.read(2)
        # print(struct.unpack('>h', header_bytes)[0])

        # data_bytes = port.read(4)
        # print(struct.unpack('>f', data_bytes)[0])

        # data_bytes = port.read(8)
        # print(struct.unpack('>ff', data_bytes))

        # footer_bytes = port.read(2)
        # print(struct.unpack('>h', footer_bytes)[0])

        while port.in_waiting <= 0:
            pass
        byte = port.read(1)
        stream += bytearray(byte)
        
        if not is_in_packet and len(stream) >= 2:
            is_in_packet = True
            header_bytes = stream[:2]
            stream = stream[2:]
            packet['type']: int = struct.unpack('>h', header_bytes)[0]

            packet_types = list(packet.get_packet_types(packet['type']))

            checksum_target.clear()
            checksum_target += bytearray(header_bytes)
            
        elif is_front(packet.PACKET_TYPE_ALTITUDE, packet_types) and len(stream) > 4:
            packet_types.pop(0)
            data_bytes = stream[:4]
            stream = stream[4:]
            packet[packet.PACKET_TYPE_ALTITUDE] = struct.unpack('>f', data_bytes)

            checksum_target += bytearray(data_bytes)

        elif is_front(packet.PACKET_TYPE_COORDINATES, packet_types) and len(stream) > 8:
            packet_types.pop(0)
            data_bytes = stream[:8]
            stream = stream[8:]
            packet[packet.PACKET_TYPE_COORDINATES] = struct.unpack('>ff', data_bytes)

            checksum_target += bytearray(data_bytes)
        
        elif is_front(packet.PACKET_TYPE_C, packet_types) and len(stream) > 4:
            packet_types.pop(0)
            data_bytes = stream[:4]
            stream = stream[4:]
            packet[packet.PACKET_TYPE_C] = struct.unpack('>i', data_bytes)

            checksum_target += bytearray(data_bytes)
        
        elif is_front(packet.PACKET_TYPE_D, packet_types) and len(stream) > 1:
            packet_types.pop(0)
            data_bytes = stream[:1]
            stream = stream[1:]
            packet[packet.PACKET_TYPE_D] = struct.unpack('>?', data_bytes)   

            checksum_target += bytearray(data_bytes)     

        elif is_in_packet and len(packet_types) <= 0 and len(stream) >= 4:
            footer_bytes = stream[:4]
            stream = stream[4:]
            packet['footer'] = struct.unpack('>i', footer_bytes)[0]

            if crc_calculator.verify_checksum(checksum_target, packet['footer']):
                print('[CHECKSUM OK]', end=' ')
            else:
                print(f'[CHECKSUM BAD, EXPECTED {crc_calculator.calculate_checksum(checksum_target)}')
            
            print(packet)

            stream = bytearray()
            packet: dict[int] = {}
            packet_types: list[int] = []
            is_in_packet = False


print('Received')

