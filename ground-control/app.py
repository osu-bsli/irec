import dearpygui.dearpygui as gui
import serial
from data_controllers.iliad_data_controller import IliadDataController

class App:
    def __init__(self) -> None:
        # Start UI:
        gui.create_context()
        gui.create_viewport(title='Iliad Ground Control', width=600, height=300)
        gui.setup_dearpygui()

        with gui.window() as MAIN_WINDOW:
            gui.set_primary_window(MAIN_WINDOW, True)

        gui.show_viewport()
        gui.maximize_viewport()

        # Start serial ports and stuff:
        self.iliad = IliadDataController()
        self.config = {
            'port_name': 'COM2',
            'port_baud_rate': 9600,
            'port_stop_bits': serial.STOPBITS_ONE,
            'port_parity': serial.PARITY_NONE,
            'port_byte_size': serial.EIGHTBITS,
        }
        self.iliad.set_config(self.config)
        self.iliad.open()

    def update(self) -> None:
        self.iliad.update()

    def run(self) -> None:
        while gui.is_dearpygui_running():
            self.update()
            gui.render_dearpygui_frame()

        self.iliad.close()
        
        gui.destroy_context()