import serial

class SerialDataController:
    def __init__(self) -> None:
        
        # Set default port values
        self.port_name = ''
        self.port_baud_rate = 9600
        self.port_stopbits = serial.STOPBITS_ONE
        self.port_parity = serial.PARITY_NONE
        self.port_bytesize = serial.EIGHTBITS

    def get_config(self) -> dict[str]:
        return {
            'port_name': self.port_name,
            'port_baud_rate': self.port_baud_rate,
            'port_stopbits': self.port_stopbits,
            'port_parity': self.port_parity,
            'port_bytesize': self.port_bytesize,
        }
    
    def set_config(self, config: dict[str]):
        if 'port_name' in config:
            if config['port_name'] is str:
                self.port_name = config['port_name']

        if 'port_baud_rate' in config:
            if config['port_baud_rate'] is int:
                self.port_baud_rate = config['port_baud_rate']
        
        if 'port_stopbits' in config:
            if config['port_stopbits'] in [serial.STOPBITS_ONE, serial.STOPBITS_ONE_POINT_FIVE, serial.STOPBITS_TWO]:
                self.port_stopbits = config['port_stopbits']
        
        if 'port_parity' in config:
            if config['port_parity'] in [serial.PARITY_NONE, serial.PARITY_EVEN, serial.PARITY_ODD, serial.PARITY_MARK, serial.PARITY_SPACE]:
                self.port_parity = config['port_parity']
        
        if 'port_bytesize' in config:
            if config['port_bytesize'] in [serial.FIVEBITS, serial.SIXBITS, serial.SEVENBITS, serial.EIGHTBITS]:
                self.port_bytesize = config['port_bytesize']