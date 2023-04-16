import struct
import crc

crc_calculator = crc.Calculator(crc.Crc16.CCITT)

# arming packets (not passed to payload)
PACKET_TYPE_ARM_TELEMETRUM = 0x01
PACKET_TYPE_ARM_STRATOLOGGER = 0x02
PACKET_TYPE_ARM_CAMERA = 0x03
# disarming packets (not passed to payload)
PACKET_TYPE_DISARM_TELEMETRUM = 0x04
PACKET_TYPE_DISARM_STRATOLOGGER = 0x05
PACKET_TYPE_DISARM_CAMERA = 0x06
# set packets (not passed to payload
PACKET_TYPE_SET_STARTING_ALTITUDE = 0x0A
# reset packets (not passed to payload)
PACKET_TYPE_RESET_STARTING_ALTITUDE = 0x0B

# packets passed to payload
PACKET_TYPE_HIGH_G_ACCELEROMETER = 0xF0
PACKET_TYPE_GYROSCOPE = 0xF1
PACKET_TYPE_ACCELEROMETER = 0xF2
PACKET_TYPE_BAROMETER = 0xF3
PACKET_TYPE_GPS = 0xF4
PACKET_TYPE_TELEMETRUM = 0xF5
PACKET_TYPE_STRATOLOGGER = 0xF6
PACKET_TYPE_CAMERA = 0xF7
PACKET_TYPE_BATTERY = 0xF8


def create_packet(type: int, time: float, data: tuple) -> bytes:
    header = struct.pack('<B', type)
    header_checksum = struct.pack('<H', crc_calculator.checksum(header))
    header_time = struct.pack('<f', time)

    body = bytes()
    if type == PACKET_TYPE_HIGH_G_ACCELEROMETER:
        body = body + struct.pack('<fff', data[0], data[1], data[2])

    elif type == PACKET_TYPE_GYROSCOPE:
        body = body + struct.pack('<fff', data[0], data[1], data[2])

    elif type == PACKET_TYPE_ACCELEROMETER:
        body = body + struct.pack('<fff', data[0], data[1], data[2])

    elif type == PACKET_TYPE_BAROMETER:
        body = body + struct.pack('<f', data[0])
        
    elif type == PACKET_TYPE_GPS:
        body = body + struct.pack('<fBffff', data[0], data[1], data[2], data[3], data[4], data[5])
        
    elif type == PACKET_TYPE_TELEMETRUM:
        body = body + struct.pack('<?ff', data[0], data[1], data[2])

    elif type == PACKET_TYPE_STRATOLOGGER:
        body = body + struct.pack('<?ff', data[0], data[1], data[2])

    elif type == PACKET_TYPE_CAMERA:
        body = body + struct.pack('<?ff', data[0], data[1], data[2])

    elif type == PACKET_TYPE_BATTERY:
        body = body + struct.pack('<ff', data[0], data[1])
    
    footer = struct.pack('<H', crc_calculator.checksum(header + header_checksum + header_time + body))

    return header + header_checksum + header_time + body + footer
