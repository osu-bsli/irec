import dearpygui.dearpygui as gui
import tomli
from data_controllers.iliad_data_controller import IliadDataController
from grapher.grapher import Grapher

class App:

    # Widget tags
    TAG_MAIN_WINDOW = 'app.main_window'
    TAG_MAIN_MENU = 'app.main_menu'
    TAG_CONFIG_WINDOW = 'app.config_window'

    def __init__(self) -> None:

        # Start serial ports and stuff:
        self.iliad = IliadDataController('iliad_data_controller')

        # Start UI:
        gui.create_context()
        gui.create_viewport(title='Iliad Ground Control', width=600, height=300)
        gui.setup_dearpygui()

        with gui.font_registry():
            primary_font = gui.add_font('assets/fonts/open_sans/OpenSans-VariableFont_wdth,wght.ttf', 16)
            gui.bind_font(primary_font)


        with gui.window(tag=App.TAG_MAIN_WINDOW):

            with gui.menu_bar(tag=App.TAG_MAIN_MENU):
                with gui.menu(label='Options'):
                    gui.add_menu_item(label='Config', callback=lambda: gui.show_item(App.TAG_CONFIG_WINDOW))
                with gui.menu(label='Tools'):
                    gui.add_menu_item(label='Packet Inspector', callback=None)
                    gui.add_menu_item(label='GUI Demo', callback=gui.show_imgui_demo)
                    gui.add_menu_item(label='Graphs Demo', callback=gui.show_implot_demo)
                    gui.add_menu_item(label='Font Manager', callback=gui.show_font_manager)
                    gui.add_menu_item(label='Style Editor', callback=gui.show_style_editor)
                with gui.menu(label='View'):
                    gui.add_menu_item(label='Save layout', callback=None)
                    gui.add_menu_item(label='Load layout', callback=None)
                with gui.menu(label='Help'):
                    gui.add_menu_item(label='Docs', callback=None)
                    gui.add_menu_item(label='About', callback=None)
            gui.set_primary_window(App.TAG_MAIN_WINDOW, True)
            self.grapher = Grapher('grapher')

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
            
            with gui.group(horizontal=True):

                def on_apply_config():
                    # self.grapher.apply_config()
                    self.iliad.apply_config()

                gui.add_button(label='Cancel', callback=lambda: gui.hide_item(App.TAG_CONFIG_WINDOW))
                gui.add_button(label='Apply', callback=on_apply_config)
        gui.hide_item(App.TAG_CONFIG_WINDOW)

        gui.show_viewport()
        gui.maximize_viewport()

    def update(self) -> None:
        """
        Called every frame.

        Calls `update()` on all components.
        """
        self.iliad.update()
        self.grapher.update()

    def run(self) -> None:
        """
        Starts the main event loop.
        """
        while gui.is_dearpygui_running():
            self.update()
            gui.render_dearpygui_frame()

        self.iliad.close()
        
        gui.destroy_context()