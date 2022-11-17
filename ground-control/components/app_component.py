import dearpygui.dearpygui as gui

class AppComponent:
    def __init__(self, identifier: str) -> None:
        self.identifier = identifier
    
    # Returns a dictionary with different config options.
    def get_config(self) -> dict[str]:
        """
        Serializes this class's configuration into a dictionary.
        Implementation decides what values are correct/expected.
        """
        return {}
    
    # Sets config options from the dictionary passed in.
    def set_config(self, config: dict[str]) -> None:
        """
        Configures this class using `config`.
        Implementation decides what values are correct/expected.
        """
        pass
    
    def add_config_menu(self) -> None:
        """
        Called by `App` to build it's config menu UI.

        Should add UI widgets for configuring this class.
        """
        gui.add_text('No options available.')

    def apply_config(self) -> None:
        """
        Called by `App` when 'Apply' is clicked on the config menu.

        Should fetch values from this class's config menu and apply them.
        May also save them to a file for persistence.
        If so, the values should also be loaded in the constructor.
        """
        pass

    def update(self) -> None:
        """
        Called every frame.

        Any non event/callback based processing should be done here.
        """
        pass