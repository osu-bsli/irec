import serial_data_controller
import serial
import struct
import packet_util
import crc

class IliadDataController(serial_data_controller.SerialDataController):

    def __init__(self) -> None:
        super().__init__()

        self.data_buffer = bytearray()
        self.checksum_calculator = crc.CrcCalculator(crc.Crc16.CCITT)
    
    def update(self) -> None:
        if self.is_open():
            
            # Poll serial port and put anything there into data_buffer
            if self.port.in_waiting > 0:
                data = self.port.read_all()
                self.data_buffer += bytearray(data)
            
            # If the buffer has enough data, try to parse some of it
            if len(self.data_buffer) > 10:
                
                self.idx_cursor = 0 # Current index in data_buffer.

                packet_types_bytes: bytes
                packet_types: list[int] = []
                packet_payload_bytes = bytearray()
                packet_payload: dict[int] = {}
                packet_checksum_bytes: bytes
                packet_checksum: int

                # Parse header:
                if len(self.data_buffer) - self.idx_cursor >= 2:
                    packet_types_bytes = self.data_buffer[self.idx_cursor:(self.idx_cursor + 2)]
                    (packet_types_raw,) = struct.unpack('>h', packet_types_bytes)
                    packet_types: list[int] = list(packet_util.get_packet_types(packet_types_raw))
                    self.idx_cursor += 2
                
                for packet_type in [ # TODO: Turn constants into an enum.
                    packet_util.PACKET_TYPE_ALTITUDE,
                    packet_util.PACKET_TYPE_COORDINATES,
                    packet_util.PACKET_TYPE_C,
                    packet_util.PACKET_TYPE_D,
                ]:
                    if packet_type in packet_types:
                        payload_size = packet_util.PAYLOAD_SIZE[packet_type]
                        payload_format = packet_util.PAYLOAD_FORMAT[packet_type]
                        if len(self.data_buffer) - self.idx_cursor >= payload_size:
                            payload_bytes = self.data_buffer[self.idx_cursor:(self.idx_cursor + payload_size)]
                            payload = struct.unpack(payload_format, payload_bytes)
                            self.idx_cursor += payload_size

                            packet_payload_bytes += payload_bytes
                            packet_payload[packet_type] = payload
                
                # Parse footer:
                if len(self.data_buffer) - self.idx_cursor >= 4:
                    packet_checksum_bytes = self.data_buffer[self.idx_cursor:(self.idx_cursor + 4)]
                    (packet_checksum,) = struct.unpack('>i', packet_checksum_bytes)
                    self.idx_cursor += 4
                
                # Check packet checksum:
                is_ok = False
                if self.checksum_calculator.verify_checksum(packet_types_bytes + packet_payload_bytes, packet_checksum):
                    is_ok = True
                
                if is_ok:
                    print(f'[OK] {packet_types_bytes.hex()} {packet_payload_bytes.hex()} {packet_checksum_bytes.hex()}')
                    print(f'\t{packet_types} {packet_payload} {packet_checksum}')
                else:
                    print(f'[BAD] {packet_types_bytes.hex()} {packet_payload_bytes.hex()} {packet_checksum_bytes.hex()}')
                    print(f'\tExpected {self.checksum_calculator.calculate_checksum(packet_types_bytes + packet_payload_bytes)}, got {packet_checksum}')

                if is_ok:
                    self.data_buffer = self.data_buffer[self.idx_cursor:]
                    self.idx_cursor = 0
                else:
                    self.data_buffer = self.data_buffer[1:]
                    self.idx_cursor = 0
                    # TODO: Need to track if we are in "network recover" state.
                
                # The basic algorithm for recovery is:
                # If crc doesn't match up, discard one byte at a time and try to parse again.
                




# Test cases
if __name__ == '__main__':

    # Test update()
    test = IliadDataController()
    config = {
        'port_name': 'COM2',
        'port_baud_rate': 9600,
        'port_stop_bits': serial.STOPBITS_ONE,
        'port_parity': serial.PARITY_NONE,
        'port_byte_size': serial.EIGHTBITS,
    }
    test.set_config(config)
    test.open()
    # for i in range(1000):
    try:
        while True:
            test.update()
    finally:
        test.close()
        print("cleaned up")
