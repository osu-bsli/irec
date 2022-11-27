"""
This is a simulator that receives arming commands and sends corresponding arm_status packets.
Also implements a parser for arming command packets.
"""

from utils import packet_util
import serial
import struct
import crc
import time

if __name__ == '__main__':

    arm_statuses: list[bool, bool, bool] = [False, False, False]

    data_buffer = bytearray()
    checksum_calculator = crc.CrcCalculator(crc.Crc16.CCITT)

    # Temporary variables to store data while we check the packet's checksum.
    _current_packet_types: int = None
    _current_arm_camera_data: tuple[float, bool] = None
    _current_arm_srad_fc_data: tuple[float, bool] = None
    _current_arm_cots_fc_data: tuple[float, bool] = None

    with serial.Serial(
        port='COM2',
        baudrate=9600,
        stopbits=serial.STOPBITS_ONE,
        parity=serial.PARITY_NONE,
        bytesize=serial.EIGHTBITS,
    ) as port:
        while True:

            # Poll serial port and put anything there into data_buffer
            if port.in_waiting > 0:
                data = port.read_all()
                data_buffer += bytearray(data)

            # If the buffer has enough data, try to parse some of it
            if len(data_buffer) > 0:
                
                idx_cursor = 0 # Current index in data_buffer.

                packet_types_bytes: bytes = None
                packet_types: list[int] = []
                packet_timestamp_bytes: bytes = None
                packet_timestamp: float = None
                packet_header_checksum_bytes: bytes = None
                packet_header_checksum: int = None
                packet_payload_bytes = bytearray()
                packet_payload: dict[int] = {}
                packet_checksum_bytes: bytes = None
                packet_checksum: int = None

                # Parse header:
                if len(data_buffer) - idx_cursor >= 10:
                    packet_types_bytes = data_buffer[idx_cursor:(idx_cursor + 2)]
                    (packet_types_raw,) = struct.unpack('>h', packet_types_bytes)
                    packet_types: list[int] = list(packet_util.get_packet_types(packet_types_raw))
                    idx_cursor += 2

                    packet_timestamp_bytes = data_buffer[idx_cursor:(idx_cursor + 4)]
                    (packet_timestamp,) = struct.unpack('>f', packet_timestamp_bytes)
                    idx_cursor += 4

                    packet_header_checksum_bytes = data_buffer[idx_cursor:(idx_cursor + 4)]
                    (packet_header_checksum,) = struct.unpack('>i', packet_header_checksum_bytes)
                    idx_cursor += 4

                    """
                    The basic algorithm for recovery is:
                    If crc doesn't match up, don't read the packet, discard one byte at a time and try to parse again.
                    """
                    if not checksum_calculator.verify_checksum(packet_types_bytes + packet_timestamp_bytes, packet_header_checksum):
                        # Packet is not ok.
                        data_buffer = data_buffer[1:]
                        idx_cursor = 0
                    else:
                        _current_packet_types = packet_types_raw
                
                        # Parse body:
                        for packet_type in [
                            packet_util.PACKET_TYPE_ARM_CAMERA,
                            packet_util.PACKET_TYPE_ARM_SRAD_FLIGHT_COMPUTER,
                            packet_util.PACKET_TYPE_ARM_COTS_FLIGHT_COMPUTER,
                        ]:
                            if packet_type in packet_types:
                                payload_size = packet_util.PAYLOAD_SIZE[packet_type]
                                payload_format = packet_util.PAYLOAD_FORMAT[packet_type]
                                if len(data_buffer) - idx_cursor >= payload_size:
                                    payload_bytes = data_buffer[idx_cursor:(idx_cursor + payload_size)]
                                    payload = struct.unpack(payload_format, payload_bytes)
                                    idx_cursor += payload_size

                                    packet_payload_bytes += payload_bytes
                                    packet_payload[packet_type] = payload
                                    
                                    if packet_type == packet_util.PACKET_TYPE_ARM_CAMERA:
                                        print(f'<- PACKET_TYPE_ARM_CAMERA {packet_timestamp} {payload[0]}')
                                        _current_arm_camera_data = (packet_timestamp, payload[0])
                                    elif packet_type == packet_util.PACKET_TYPE_ARM_SRAD_FLIGHT_COMPUTER:
                                        _current_arm_srad_fc_data = (packet_timestamp, payload[0])
                                        print(f'<- PACKET_TYPE_ARM_SRAD_FLIGHT_COMPUTER {packet_timestamp} {payload[0]}')
                                    elif packet_type == packet_util.PACKET_TYPE_ARM_COTS_FLIGHT_COMPUTER:
                                        _current_arm_cots_fc_data = (packet_timestamp, payload[0])
                                        print(f'<- PACKET_TYPE_ARM_COTS_FLIGHT_COMPUTER {packet_timestamp} {payload[0]}')
                        
                        # Parse footer:
                        if len(data_buffer) - idx_cursor >= 4:
                            packet_checksum_bytes = data_buffer[idx_cursor:(idx_cursor + 4)]
                            (packet_checksum,) = struct.unpack('>i', packet_checksum_bytes)
                            idx_cursor += 4

                            """
                            The basic algorithm for recovery is:
                            If crc doesn't match up, discard one byte at a time and try to parse again.
                            """
                            if not checksum_calculator.verify_checksum(packet_types_bytes + packet_timestamp_bytes + packet_header_checksum_bytes + packet_payload_bytes, packet_checksum):
                                # Packet is not ok.
                                data_buffer = data_buffer[1:]
                                idx_cursor = 0
                            else:
                                # Packet is ok.
                                data_buffer = data_buffer[idx_cursor:]
                                idx_cursor = 0

                                # Save the packet's data.
                                for current_packet_type in packet_util.get_packet_types(_current_packet_types):
                                    if current_packet_type == packet_util.PACKET_TYPE_ARM_CAMERA:
                                        arm_statuses[0] = _current_arm_camera_data[1]
                                    elif current_packet_type == packet_util.PACKET_TYPE_ARM_SRAD_FLIGHT_COMPUTER:
                                        arm_statuses[1] = _current_arm_srad_fc_data[1]
                                    elif current_packet_type == packet_util.PACKET_TYPE_ARM_COTS_FLIGHT_COMPUTER:
                                        arm_statuses[2] = _current_arm_cots_fc_data[1]
    
            time.sleep(1) # We send arm_status packets every second.
            port.write(
                packet_util.create_packet(
                    packet_util.PACKET_TYPE_ARM_STATUS,
                    time.time(),
                    (arm_statuses[0], arm_statuses[1], arm_statuses[2])
                )
            )
            print(f'-> PACKET_TYPE_ARM_STATUS {time.time()} {arm_statuses[0]} {arm_statuses[1]} {arm_statuses[2]}') # TODO: using time.time() again is not exactly correct.
