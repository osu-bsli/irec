import serial
import serial.tools.list_ports
import dearpygui.dearpygui as gui
from . import data_controller

class SerialDataController(data_controller.DataController):

    # Widget tags
    TAG_CONFIG_MENU_PORT_COMBO = 'SDC.CONFIG_MENU.PORT_COMBO'

    def __init__(self) -> None:
        super().__init__()
        
        # Set default port values
        self.port = serial.Serial()
        self.port_name = ''
        self.port_baud_rate = 9600
        self.port_stop_bits = serial.STOPBITS_ONE
        self.port_parity = serial.PARITY_NONE
        self.port_byte_size = serial.EIGHTBITS

    # Returns a dictionary with different config options.
    def get_config(self) -> dict[str]:
        return {
            'port_name': self.port_name,                # string like 'COM1', 'tty0', etc.
            'port_baud_rate': self.port_baud_rate,      # int, like 9600 (in ui, use standard values, may allow custom)
            'port_stop_bits': self.port_stop_bits,      # int/float, one of [1, 1.5, 2]
            'port_parity': self.port_parity,            # string, one of ['N', 'E', 'O', 'M', 'S']
            'port_byte_size': self.port_byte_size,      # int, one of [5, 6, 7, 8]
        }
    
    # Sets config options from the dictionary passed in.
    def set_config(self, config: dict[str]) -> None:
        if 'port_name' in config:
            if type(config['port_name']) == str:
                self.port_name = config['port_name']

        if 'port_baud_rate' in config:
            if type(config['port_baud_rate']) == int:
                self.port_baud_rate = config['port_baud_rate']
        
        if 'port_stop_bits' in config:
            if config['port_stop_bits'] in [serial.STOPBITS_ONE, serial.STOPBITS_ONE_POINT_FIVE, serial.STOPBITS_TWO]:
                self.port_stop_bits = config['port_stop_bits']
        
        if 'port_parity' in config:
            if config['port_parity'] in [serial.PARITY_NONE, serial.PARITY_EVEN, serial.PARITY_ODD, serial.PARITY_MARK, serial.PARITY_SPACE]:
                self.port_parity = config['port_parity']
        
        if 'port_byte_size' in config:
            if config['port_byte_size'] in [serial.FIVEBITS, serial.SIXBITS, serial.SEVENBITS, serial.EIGHTBITS]:
                self.port_byte_size = config['port_byte_size']
    
    def add_config_menu(self) -> None:
        self.available_ports = []
        def rescan_ports() -> None:
            ports = serial.tools.list_ports.comports()
            self.available_ports = []
            for port, description, hardware_id in ports:
                self.available_ports.append(port)
            gui.configure_item(SerialDataController.TAG_CONFIG_MENU_PORT_COMBO, items=self.available_ports)

        with gui.group(horizontal=True):
            gui.add_text('Port:')
            gui.add_combo(items=self.available_ports, width=-1, tag=SerialDataController.TAG_CONFIG_MENU_PORT_COMBO)
        gui.add_button(label='Rescan ports', callback=rescan_ports)
        with gui.group(horizontal=True):
            gui.add_text('Baud rate:')
            gui.add_input_int(default_value=9600, width=-1)
        with gui.group(horizontal=True):
            gui.add_text('Stop bits:')
            gui.add_combo(items=['1', '1.5', '2'], default_value='1', width=-1)
        with gui.group(horizontal=True):
            gui.add_text('Parity:')
            gui.add_combo(items=['None', 'Even', 'Odd', 'Mark', 'Space'], default_value='None', width=-1)
        with gui.group(horizontal=True):
            gui.add_text('Byte size:')
            gui.add_combo(items=['5 bits', '6 bits', '7 bits', '8 bits'], default_value='8 bits', width=-1)
        
        rescan_ports()

    def open(self) -> None:
        try:
            self.port = serial.Serial(
                port=self.port_name,
                baudrate=self.port_baud_rate,
                stopbits=self.port_stop_bits,
                parity=self.port_parity,
                bytesize=self.port_byte_size
            )
        except serial.SerialException as e:
            error_message = f'Serial port \"{self.port_name}\" couldn\'t be opened.'
            raise self.DataControllerException(error_message) from e
    
    def is_open(self) -> bool:
        return self.port.is_open

    def close(self) -> None:
        if self.port.is_open:
            self.port.close()

    def update(self) -> None:
        pass

# Test cases
if __name__ == '__main__':

    # Test set_config()
    test = SerialDataController()
    config = {
        'port_name': 'COM1',
        'port_baud_rate': 9600,
        'port_stop_bits': serial.STOPBITS_ONE,
        'port_parity': serial.PARITY_NONE,
        'port_byte_size': serial.EIGHTBITS,
    }
    test.set_config(config)
    assert test.get_config() == config
    assert test.port_name == config['port_name']
    assert test.port_baud_rate == config['port_baud_rate']
    assert test.port_stop_bits == config['port_stop_bits']
    assert test.port_parity == config['port_parity']
    assert test.port_byte_size == config['port_byte_size']
    
    # Test exception on invalid open()
    was_exception = False
    try:
        test = SerialDataController()
        test.set_config({
            'port_name': 'qwertyuiop',
            'port_baud_rate': 9600,
            'port_stop_bits': serial.STOPBITS_ONE,
            'port_parity': serial.PARITY_NONE,
            'port_byte_size': serial.EIGHTBITS,
        })
        test.open()
        test.close()
    except SerialDataController.DataControllerException as e:
        was_exception = True
    assert was_exception == True