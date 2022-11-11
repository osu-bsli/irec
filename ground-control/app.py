import dearpygui.dearpygui as gui
import serial
from data_controllers.iliad_data_controller import IliadDataController

class App:

    # Widget tags
    TAG_MAIN_WINDOW = 'GCS.MAIN_WINDOW'
    TAG_MAIN_MENU = 'GCS.MAIN_MENU'
    TAG_CONFIG_WINDOW = 'GCS.CONFIG_WINDOW'

    def __init__(self) -> None:

        # Start serial ports and stuff:
        self.iliad = IliadDataController()
        # self.config = {
        #     'port_name': 'COM2',
        #     'port_baud_rate': 9600,
        #     'port_stop_bits': serial.STOPBITS_ONE,
        #     'port_parity': serial.PARITY_NONE,
        #     'port_byte_size': serial.EIGHTBITS,
        # }
        # self.iliad.set_config(self.config)
        # self.iliad.open()

        # Start UI:
        gui.create_context()
        gui.create_viewport(title='Iliad Ground Control', width=600, height=300)
        gui.setup_dearpygui()

        with gui.font_registry():
            primary_font = gui.add_font('assets/fonts/open_sans/OpenSans-VariableFont_wdth,wght.ttf', 16)
            gui.bind_font(primary_font)

        # Init config menu:
        with gui.window(label='Config', tag=App.TAG_CONFIG_WINDOW, min_size=(512, 512)):
            # Add categories and corresponding child windows:
            with gui.tree_node(label='General'):
                with gui.tree_node(label='Controls'):
                    gui.add_text('No options available.')
                with gui.tree_node(label='Visuals'):
                    gui.add_text('No options available.')
                with gui.tree_node(label='Misc'):
                    gui.add_text('No options available.')
            with gui.tree_node(label='Grapher'):
                gui.add_text('No options available.')
            with gui.tree_node(label='Iliad Data Controller'):
                self.iliad.add_config_menu()
        gui.hide_item(App.TAG_CONFIG_WINDOW)

        with gui.viewport_menu_bar(tag=App.TAG_MAIN_MENU):
            with gui.menu(label='Options'):
                gui.add_menu_item(label='Config', callback=lambda: gui.show_item(App.TAG_CONFIG_WINDOW))
            with gui.menu(label='Tools'):
                gui.add_menu_item(label='Packet Inspector', callback=None)
                gui.add_menu_item(label='GUI Demo', callback=gui.show_imgui_demo)
                gui.add_menu_item(label='Graphs Demo', callback=gui.show_implot_demo)
                gui.add_menu_item(label='Font Manager', callback=gui.show_font_manager)
            with gui.menu(label='View'):
                gui.add_menu_item(label='Save layout', callback=None)
                gui.add_menu_item(label='Load layout', callback=None)
            with gui.menu(label='Help'):
                gui.add_menu_item(label='Docs', callback=None)
                gui.add_menu_item(label='About', callback=None)

        with gui.window(tag=App.TAG_MAIN_WINDOW):
            gui.set_primary_window(App.TAG_MAIN_WINDOW, True)

        gui.show_viewport()
        gui.maximize_viewport()

    def update(self) -> None:
        self.iliad.update()

    def run(self) -> None:
        while gui.is_dearpygui_running():
            self.update()
            gui.render_dearpygui_frame()

        self.iliad.close()
        
        gui.destroy_context()