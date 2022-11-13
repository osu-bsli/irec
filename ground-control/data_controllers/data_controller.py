import dearpygui.dearpygui as gui

class DataController:
    """
    Generic data controller class for reading/writing to a port/connection.
    """
    def __init__(self, identifier: str) -> None:
        self.identifier = identifier
        pass
    
    # Raise when we can't open().
    class DataControllerException(Exception):
        """
        Generic exception for DataController so people using it know what to catch.

        This is usually raised when DataController.open() fails.
        """
        pass

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
    
    def open(self) -> None:
        """
        Opens the data source, or initializes it, or whatever.
        """
        raise DataController.DataControllerException('Generic data controller cannot be opened.')
    
    def is_open(self) -> bool:
        """
        Checks if this is open.
        """
        return False
    
    def close(self) -> None:
        """
        Closes the data source, or cleans it up, or whatever.
        """
        pass

    def update(self) -> None:
        """
        Called every frame.

        Any non event/callback based processing should be done here.
        """
        pass
