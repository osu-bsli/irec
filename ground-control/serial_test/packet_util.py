import struct
import crc

crc_calculator = crc.CrcCalculator(crc.Crc16.CCITT)

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

def create_packet(types: int, data: tuple) -> bytes:
    header = struct.pack('>h', types)
    # footer = struct.pack('>h', checksum)

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
    
    checksum = crc_calculator.calculate_checksum(header + body)
    footer = struct.pack('>i', checksum)

    return header + body + footer
