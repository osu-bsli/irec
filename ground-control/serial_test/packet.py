import struct

# Use for bitflags
PACKET_TYPE_ALTITUDE = 1
PACKET_TYPE_COORDINATES = 2
PACKET_TYPE_C = 4
PACKET_TYPE_D = 8

# Splits a packet type bitflag into multiple packet types.
# Code from <https://www.spatialtimes.com/2014/07/binary-flags-with-python/>
def get_packet_types(n):
    while n:
        b = n & (~n+1)
        yield b
        n ^= b

def create_packet(types: int, data: tuple, checksum: int) -> bytes:
    header = struct.pack('>h', types)
    footer = struct.pack('>h', checksum)

    body = bytes()
    type_flags: list[int] = get_packet_types(types)
    idx_data = 0
    for type_flag in type_flags:

        if type_flag == PACKET_TYPE_ALTITUDE:
            body = body + struct.pack('>f', data[idx_data])
            idx_data += 1
        
        elif type_flag == PACKET_TYPE_COORDINATES:
            body = body + struct.pack('>ff', data[idx_data], data[idx_data + 1])
            idx_data += 2
        
        elif type_flag == PACKET_TYPE_C:
            body = body + struct.pack('>i', data[idx_data])
            idx_data += 1
        
        elif type_flag == PACKET_TYPE_D:
            body = body + struct.pack('>?', data[idx_data])
            idx_data += 1
    
    return header + body + footer

def parse_packet(packet: bytes) -> tuple[int, dict[int], int]:
    result: dict[int] = {}

    header_bytes = packet[:2]
    packet = packet[2:]
    (header,) = struct.unpack('>h', header_bytes)

    type_flags: list[int] = get_packet_types(header)
    for type_flag in type_flags:

        if type_flag == PACKET_TYPE_ALTITUDE:
            result[PACKET_TYPE_ALTITUDE] = struct.unpack('>f', packet[:4])
            packet = packet[4:]
        
        elif type_flag == PACKET_TYPE_COORDINATES:
            result[PACKET_TYPE_COORDINATES] = struct.unpack('>ff', packet[:8])
            packet = packet[8:]
        
        elif type_flag == PACKET_TYPE_C:
            result[PACKET_TYPE_C] = struct.unpack('>i', packet[:4])
            packet = packet[4:]
        
        elif type_flag == PACKET_TYPE_D:
            result[PACKET_TYPE_D] = struct.unpack('>?', packet[:4])
            packet = packet[4:]
    
    # There should only be 2 bytes left.
    checksum = 0
    (checksum,) = struct.unpack('>h', packet)

    return (header, result, checksum)

packet = create_packet(PACKET_TYPE_ALTITUDE + PACKET_TYPE_COORDINATES, (42.0, 42.0, 42.0), 0)
print(packet.hex(sep=' '))
print(f'{packet[:2]} {packet[2:6]} {packet[6:14]} {packet[14:]}')
(header, result, checksum) = parse_packet(packet)
print(header)
print(result)
print(checksum)