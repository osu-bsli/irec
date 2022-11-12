from data_controllers.serial_data_controller import SerialDataController
import serial

def test_set_config():
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
    
def test_open_exception():
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
