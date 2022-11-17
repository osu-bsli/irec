from components.app_component import AppComponent
import dearpygui.dearpygui as gui

class Grapher(AppComponent):
    def __init__(self, identifier: str) -> None:
        super().__init__(identifier)
    
        # Returns a dictionary with different config options.
    def get_config(self) -> dict[str]:
        return {}
    
    # Sets config options from the dictionary passed in.
    def set_config(self, config: dict[str]) -> None:
        pass
    
    def add_config_menu(self) -> None:
        gui.add_text('No options available.')

    def apply_config(self) -> None:
        pass

    def update(self) -> None:
        pass