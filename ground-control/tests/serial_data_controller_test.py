from data_controllers.serial_data_controller import SerialDataController
import serial
import dearpygui.dearpygui as gui

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

def test_config_ui():
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