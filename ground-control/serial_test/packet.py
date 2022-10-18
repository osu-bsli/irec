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



packet = create_packet(PACKET_TYPE_ALTITUDE + PACKET_TYPE_COORDINATES, (42.0, 42.0, 42.0), 0)
print(packet.hex(sep=' '))
print(f'{packet[:2]} {packet[2:6]} {packet[6:14]} {packet[14:]}')
