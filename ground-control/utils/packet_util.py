import struct
import crc

crc_calculator = crc.Calculator(crc.Crc16.CCITT)

# Use for bitflags
PACKET_TYPE_ARM_STATUS = 1
PACKET_TYPE_ALTITUDE = 2
PACKET_TYPE_ACCELERATION = 3
PACKET_TYPE_GPS_COORDINATES = 4
PACKET_TYPE_BOARD_TEMPERATURE = 5
PACKET_TYPE_BOARD_VOLTAGE = 6
PACKET_TYPE_BOARD_CURRENT = 7
PACKET_TYPE_BATTERY_VOLTAGE = 8
PACKET_TYPE_MAGNETOMETER = 9
PACKET_TYPE_GYROSCOPE = 10
PACKET_TYPE_GPS_SATELLITES = 11
PACKET_TYPE_GPS_GROUND_SPEED = 12
# Arm commands. These are only to be sent from ground, so we don't need to parse them in IliadDataController.
PACKET_TYPE_ARM_CAMERA = 4096
PACKET_TYPE_ARM_SRAD_FLIGHT_COMPUTER = 8192
PACKET_TYPE_ARM_COTS_FLIGHT_COMPUTER = 16384

PAYLOAD_SIZE = {
    PACKET_TYPE_ARM_STATUS: 3,
    PACKET_TYPE_ALTITUDE: 8,
    PACKET_TYPE_ACCELERATION: 12,
    PACKET_TYPE_GPS_COORDINATES: 8,
    PACKET_TYPE_BOARD_TEMPERATURE: 16,
    PACKET_TYPE_BOARD_VOLTAGE: 16,
    PACKET_TYPE_BOARD_CURRENT: 16,
    PACKET_TYPE_BATTERY_VOLTAGE: 12,
    PACKET_TYPE_MAGNETOMETER: 12,
    PACKET_TYPE_GYROSCOPE: 12,
    PACKET_TYPE_GPS_SATELLITES: 2,
    PACKET_TYPE_GPS_GROUND_SPEED: 4,
    PACKET_TYPE_ARM_CAMERA: 1,
    PACKET_TYPE_ARM_SRAD_FLIGHT_COMPUTER: 1,
    PACKET_TYPE_ARM_COTS_FLIGHT_COMPUTER: 1
}

PAYLOAD_FORMAT = {
    PACKET_TYPE_ARM_STATUS: ">???",
    PACKET_TYPE_ALTITUDE: '>ff',
    PACKET_TYPE_ACCELERATION: '>fff',
    PACKET_TYPE_GPS_COORDINATES: '>ff',
    PACKET_TYPE_BOARD_TEMPERATURE: '>ffff',
    PACKET_TYPE_BOARD_VOLTAGE: '>ffff',
    PACKET_TYPE_BOARD_CURRENT: '>ffff',
    PACKET_TYPE_BATTERY_VOLTAGE: '>fff',
    PACKET_TYPE_MAGNETOMETER: '>fff',
    PACKET_TYPE_GYROSCOPE: '>fff',
    PACKET_TYPE_GPS_SATELLITES: '>h',
    PACKET_TYPE_GPS_GROUND_SPEED: '>f',
    PACKET_TYPE_ARM_CAMERA: '?',
    PACKET_TYPE_ARM_SRAD_FLIGHT_COMPUTER: '?',
    PACKET_TYPE_ARM_COTS_FLIGHT_COMPUTER: '?'
}

# Splits a packet type bitflag into multiple packet types.
# Code from <https://www.spatialtimes.com/2014/07/binary-flags-with-python/>
def get_packet_types(n):
    if n > 0:
        while n:
            b = n & (~n+1)
            yield b
            n ^= b

def create_packet(type: int, time: float, data: tuple) -> bytes:
    header = struct.pack('>b', type)
    header_checksum = struct.pack('>H', crc_calculator.checksum(header))
    header_time = struct.pack('>f', time)

    body = bytes()
    idx_data = 0
    if type == PACKET_TYPE_ARM_STATUS:
        body = body + struct.pack('>???', data[idx_data], data[idx_data + 1], data[idx_data + 2])
        idx_data += 3

    elif type == PACKET_TYPE_ALTITUDE:
        body = body + struct.pack('>ff', data[idx_data], data[idx_data + 1])
        idx_data += 2

    elif type == PACKET_TYPE_ACCELERATION:
        body = body + struct.pack('>fff', data[idx_data], data[idx_data + 1], data[idx_data + 2])
        idx_data += 3
        
    elif type == PACKET_TYPE_GPS_COORDINATES:
        body = body + struct.pack('>ff', data[idx_data], data[idx_data + 1])
        idx_data += 2
        
    elif type == PACKET_TYPE_BOARD_TEMPERATURE:
        body = body + struct.pack('>ffff', data[idx_data], data[idx_data + 1], data[idx_data + 2], data[idx_data + 3])
        idx_data += 4

    elif type == PACKET_TYPE_BOARD_VOLTAGE:
        body = body + struct.pack('>ffff', data[idx_data], data[idx_data + 1], data[idx_data + 2], data[idx_data + 3])
        idx_data += 4

    elif type == PACKET_TYPE_BOARD_CURRENT:
        body = body + struct.pack('>ffff', data[idx_data], data[idx_data + 1], data[idx_data + 2], data[idx_data + 3])
        idx_data += 4

    elif type == PACKET_TYPE_BATTERY_VOLTAGE:
        body = body + struct.pack('>fff', data[idx_data], data[idx_data + 1], data[idx_data + 2])
        idx_data += 3

    elif type == PACKET_TYPE_MAGNETOMETER:
        body = body + struct.pack('>fff', data[idx_data], data[idx_data + 1], data[idx_data + 2])
        idx_data += 3

    elif type == PACKET_TYPE_GYROSCOPE:
        body = body + struct.pack('>fff', data[idx_data], data[idx_data + 1], data[idx_data + 2])
        idx_data += 3

    elif type == PACKET_TYPE_GPS_SATELLITES:
        body = body + struct.pack('>h', data[idx_data])
        idx_data += 1

    elif type == PACKET_TYPE_GPS_GROUND_SPEED:
        body = body + struct.pack('>f', data[idx_data])
        idx_data += 1
        
    elif type == PACKET_TYPE_ARM_CAMERA:
        body = body + struct.pack('>?', data[idx_data])
        idx_data += 1
        
    elif type == PACKET_TYPE_ARM_SRAD_FLIGHT_COMPUTER:
        body = body + struct.pack('>?', data[idx_data])
        idx_data += 1
        
    elif type == PACKET_TYPE_ARM_COTS_FLIGHT_COMPUTER:
        body = body + struct.pack('>?', data[idx_data])
        idx_data += 1
    
    packet_checksum = crc_calculator.checksum(header + header_checksum + header_time + body)
    footer = struct.pack('>H', packet_checksum)

    return header + header_checksum + header_time + body + footer


def create_packet_mixed(types: int, time: float, data: tuple) -> bytes:
    header = struct.pack('>hf', types, time)
    header_checksum = struct.pack('>i', crc_calculator.checksum(header))

    body = bytes()
    type_flags: list[int] = get_packet_types(types)
    idx_data = 0
    for type_flag in type_flags:
        if type_flag == PACKET_TYPE_ARM_STATUS:
            body = body + struct.pack('>???', data[idx_data], data[idx_data + 1], data[idx_data + 2])
            idx_data += 3

        elif type_flag == PACKET_TYPE_ALTITUDE:
            body = body + struct.pack('>ff', data[idx_data], data[idx_data + 1])
            idx_data += 2

        elif type_flag == PACKET_TYPE_ACCELERATION:
            body = body + struct.pack('>fff', data[idx_data], data[idx_data + 1], data[idx_data + 2])
            idx_data += 3
        
        elif type_flag == PACKET_TYPE_GPS_COORDINATES:
            body = body + struct.pack('>ff', data[idx_data], data[idx_data + 1])
            idx_data += 2
        
        elif type_flag == PACKET_TYPE_BOARD_TEMPERATURE:
            body = body + struct.pack('>ffff', data[idx_data], data[idx_data + 1], data[idx_data + 2], data[idx_data + 3])
            idx_data += 4

        elif type_flag == PACKET_TYPE_BOARD_VOLTAGE:
            body = body + struct.pack('>ffff', data[idx_data], data[idx_data + 1], data[idx_data + 2], data[idx_data + 3])
            idx_data += 4

        elif type_flag == PACKET_TYPE_BOARD_CURRENT:
            body = body + struct.pack('>ffff', data[idx_data], data[idx_data + 1], data[idx_data + 2], data[idx_data + 3])
            idx_data += 4

        elif type_flag == PACKET_TYPE_BATTERY_VOLTAGE:
            body = body + struct.pack('>fff', data[idx_data], data[idx_data + 1], data[idx_data + 2])
            idx_data += 3

        elif type_flag == PACKET_TYPE_MAGNETOMETER:
            body = body + struct.pack('>fff', data[idx_data], data[idx_data + 1], data[idx_data + 2])
            idx_data += 3

        elif type_flag == PACKET_TYPE_GYROSCOPE:
            body = body + struct.pack('>fff', data[idx_data], data[idx_data + 1], data[idx_data + 2])
            idx_data += 3

        elif type_flag == PACKET_TYPE_GPS_SATELLITES:
            body = body + struct.pack('>h', data[idx_data])
            idx_data += 1

        elif type_flag == PACKET_TYPE_GPS_GROUND_SPEED:
            body = body + struct.pack('>f', data[idx_data])
            idx_data += 1
        
        elif type_flag == PACKET_TYPE_ARM_CAMERA:
            body = body + struct.pack('>?', data[idx_data])
            idx_data += 1
        
        elif type_flag == PACKET_TYPE_ARM_SRAD_FLIGHT_COMPUTER:
            body = body + struct.pack('>?', data[idx_data])
            idx_data += 1
        
        elif type_flag == PACKET_TYPE_ARM_COTS_FLIGHT_COMPUTER:
            body = body + struct.pack('>?', data[idx_data])
            idx_data += 1
    
    packet_checksum = crc_calculator.checksum(header + header_checksum + body)
    footer = struct.pack('>i', packet_checksum)

    return header + header_checksum + body + footer
