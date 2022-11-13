import serial
import serial.tools.list_ports
import dearpygui.dearpygui as gui
from data_controllers import data_controller
from utils import config_util
import bidict

class SerialDataController(data_controller.DataController):

    def __init__(self, identifier: str) -> None:
        super().__init__(identifier)
        
        # Set default port values
        self.port = serial.Serial()
        self.port_name = ''
        self.port_baud_rate = 9600
        self.port_stop_bits = serial.STOPBITS_ONE
        self.port_parity = serial.PARITY_NONE
        self.port_byte_size = serial.EIGHTBITS

        # Widget tags:
        self.CONFIG_MENU_PORT_NAME = f'{self.identifier}.config_menu.port_name'
        self.CONFIG_MENU_PORT_BAUD_RATE = f'{self.identifier}.config_menu.port_baud_rate'
        self.CONFIG_MENU_PORT_STOP_BITS = f'{self.identifier}.config_menu.stop_bits'
        self.CONFIG_MENU_PORT_PARITY = f'{self.identifier}.config_menu.parity'
        self.CONFIG_MENU_PORT_BYTE_SIZE = f'{self.identifier}.config_menu.byte_size'

        # Load config
        config = config_util.get_config('config.toml')
        if self.identifier in config: # Configs are instance-specific.
            self.set_config(config[self.identifier])

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
    
    PORT_STOP_BITS_DISPLAY_VALUES = bidict.bidict({
        serial.STOPBITS_ONE: '1',
        serial.STOPBITS_ONE_POINT_FIVE: '1.5',
        serial.STOPBITS_TWO: '2',
    })
    PORT_PARITY_DISPLAY_VALUES = bidict.bidict({
        serial.PARITY_NONE: 'None',
        serial.PARITY_EVEN: 'Even',
        serial.PARITY_ODD: 'Odd',
        serial.PARITY_MARK: 'Mark',
        serial.PARITY_SPACE: 'Space',
    })
    PORT_BYTE_SIZE_DISPLAY_VALUES = bidict.bidict({
        serial.FIVEBITS: '5 bits',
        serial.SIXBITS: '6 bits',
        serial.SEVENBITS: '7 bits',
        serial.EIGHTBITS: '8 bits',
    })

    def add_config_menu(self) -> None:
        self.available_ports = []
        def rescan_ports() -> None:
            ports = serial.tools.list_ports.comports()
            self.available_ports = []
            for port, description, hardware_id in ports:
                self.available_ports.append(port)
            gui.configure_item(self.CONFIG_MENU_PORT_NAME, items=self.available_ports)

        with gui.group(horizontal=True):
            gui.add_text('Port:')
            gui.add_combo(
                tag=self.CONFIG_MENU_PORT_NAME,
                items=self.available_ports,
                default_value=self.port_name,
                width=128
            )
            btn = gui.add_button(label='Rescan ports', width=128, callback=rescan_ports)
            gui.configure_item(self.CONFIG_MENU_PORT_NAME, width=-(gui.get_item_width(btn) + 9)) # 1 + mvStyleVarItemSpacing x.

        with gui.group(horizontal=True):
            gui.add_text('Baud rate:')
            gui.add_input_int(
                tag=self.CONFIG_MENU_PORT_BAUD_RATE,
                default_value=self.port_baud_rate,
                width=-1
            )

        with gui.group(horizontal=True):
            gui.add_text('Stop bits:')
            gui.add_combo(
                tag=self.CONFIG_MENU_PORT_STOP_BITS,
                items=[x for y, x in SerialDataController.PORT_STOP_BITS_DISPLAY_VALUES.items()],
                default_value=SerialDataController.PORT_STOP_BITS_DISPLAY_VALUES[self.port_stop_bits],
                width=-1
            )

        with gui.group(horizontal=True):
            gui.add_text('Parity:')
            gui.add_combo(
                tag=self.CONFIG_MENU_PORT_PARITY,
                items=[x for y, x in SerialDataController.PORT_PARITY_DISPLAY_VALUES.items()],
                default_value=SerialDataController.PORT_PARITY_DISPLAY_VALUES[self.port_parity],
                width=-1
            )
            
        with gui.group(horizontal=True):
            gui.add_text('Byte size:')
            gui.add_combo(
                tag=self.CONFIG_MENU_PORT_BYTE_SIZE,
                items=[x for y, x in SerialDataController.PORT_BYTE_SIZE_DISPLAY_VALUES.items()],
                default_value=SerialDataController.PORT_BYTE_SIZE_DISPLAY_VALUES[self.port_byte_size],
                width=-1
            )
        
        rescan_ports()
    
    def apply_config(self) -> None:

        # Set port name
        self.port_name = gui.get_value(self.CONFIG_MENU_PORT_NAME)

        # Set port baud rate
        self.port_baud_rate = gui.get_value(self.CONFIG_MENU_PORT_BAUD_RATE)

        # Set port stop bits
        data = gui.get_value(self.CONFIG_MENU_PORT_STOP_BITS)
        if data in SerialDataController.PORT_STOP_BITS_DISPLAY_VALUES.inverse:
            self.port_stop_bits = SerialDataController.PORT_STOP_BITS_DISPLAY_VALUES.inverse[data]

        # Set port parity
        data = gui.get_value(self.CONFIG_MENU_PORT_PARITY)
        if data in SerialDataController.PORT_PARITY_DISPLAY_VALUES.inverse:
            self.port_parity = SerialDataController.PORT_PARITY_DISPLAY_VALUES.inverse[data]
        
        # Set port byte size
        data=gui.get_value(self.CONFIG_MENU_PORT_BYTE_SIZE)
        if data in SerialDataController.PORT_BYTE_SIZE_DISPLAY_VALUES.inverse:
            self.port_byte_size = SerialDataController.PORT_BYTE_SIZE_DISPLAY_VALUES.inverse[data]
        
        # Write config file
        config = config_util.get_config('config.toml') # Need to merge with existing config, not overwrite.
        config[self.identifier] = self.get_config()
        config_util.set_config('config.toml', config)

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
def test():

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

    # Test config ui
    test = SerialDataController()
    test.set_config({
        'port_name': 'COM1',
        'port_baud_rate': 9600,
        'port_stop_bits': serial.STOPBITS_ONE,
        'port_parity': serial.PARITY_NONE,
        'port_byte_size': serial.EIGHTBITS,
    })
    gui.create_context()
    gui.create_viewport(title='Iliad Ground Control', width=600, height=300)
    gui.setup_dearpygui()
    with gui.window():
        test.add_config_menu()
    gui.set_value(test.CONFIG_MENU_PORT_NAME, 'COM2')
    gui.set_value(test.CONFIG_MENU_PORT_BAUD_RATE, 0)
    gui.set_value(test.CONFIG_MENU_PORT_STOP_BITS, '1.5')
    gui.set_value(test.CONFIG_MENU_PORT_PARITY, 'Even')
    gui.set_value(test.CONFIG_MENU_PORT_BYTE_SIZE, '5 bits')
    for i in range(1000):
        test.update()
        gui.render_dearpygui_frame()
    test.apply_config()
    assert test.get_config == {
        'port_name': 'COM2',
        'port_baud_rate': 0,
        'port_stop_bits': serial.STOPBITS_ONE_POINT_FIVE,
        'port_parity': serial.PARITY_EVEN,
        'port_byte_size': serial.FIVEBITS,
    }
    test.close()
    gui.destroy_context()